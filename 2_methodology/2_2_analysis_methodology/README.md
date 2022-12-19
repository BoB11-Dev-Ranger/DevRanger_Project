# 분석 방법론

- [1. 코드 탐색](#1-코드-탐색)

  - [1.1. asar 코드 언패킹](#11-asar-코드-언패킹)
  - [1.2. Electron 보안옵션](#12-Electron-보안옵션)
  - [1.3. IPC 사용여부](#13-IPC-사용여부)
  - [1.4. `require` 함수의 사용가능 여부](#14-require-함수의-사용가능-여부)
  - [1.5. 딥링크 핸들러](#15-딥링크-핸들러)

- [2. Chrome Exploit](#2-Chrome-Exploit)

  - [2.1. 필요조건](#21-필요조건)
  - [2.2. 환경구축](#22-환경구축)
  - [2.3. 공격 및 분석방식](#23-공격-및-분석방식)

- [3. 서드파티모듈](#3-서드파티모듈)

- [4. CodeQL](#3-CodeQL)

---

본 문서에서는 저희가 취약점에 관하여 연구한 내용들을 토대로 이와 같은 분야의 앱들에서 어떻게 더 효율적으로 분석이 이루어질 수 있을지 분석 방법론을 소개하도록 하겠습니다.

## 1. 코드 탐색

프로젝트를 진행하면서 저희는 대다수의 개발자 생태계 앱들이 Electron 프레임워크 기반으로 제작되었다는 점을 눈여겨 볼 수 있었습니다.

Electron 프레임워크 기반으로 제작된 앱의 특징은 여러가지가 있겠지만, 그 중에서도 해당 앱이 구동되는 javascript 코드가 패키지 안에 동봉되어야 실행이 가능하다는 점이었습니다.

### 1.1. asar 코드 언패킹

우선 앱을 이루는 javascript 코드는 아래와 같은 `.asar` 확장의 압축파일에 담겨있습니다.

![](https://i.imgur.com/ApMFeuH.png)

해당 파일은 단순 unpack 프로그램으로는 열리지 않으며, Electron 제조사에서 제공하는 [asar unpacker](https://github.com/electron/asar) npm 패키지를 이용하여야 합니다.

단순히 언패킹을 진행한다면 아래와 같이 javascript 파일들이 보이는 것이 정상입니다.

![](https://i.imgur.com/88QMk2i.png)

하지만, 저희가 분석한 앱들 중에는 아무래도 코드가 그대로 추출되는 것을 방지하기 위해 asar unpacking 을 방지하는 기법을 적용한 벤더도 존재하였습니다.

정상적으로 unpack되는 asar파일의 hexdump는 아래와 같습니다.

<img src="https://user-images.githubusercontent.com/112851717/206965418-ed0c2775-0c78-4fd8-9ba7-53c56e5b028a.png" width=80%>

asar unpacking을 방지한 asar파일의 hexdump는 아래와 같습니다.

<img src="https://user-images.githubusercontent.com/112851717/206965411-3fb00030-e26d-4421-b521-b0e67830ef1f.png" width=80%>

위의 정상적인 asar파일과 달리 `{".codesign":{"size":-1000,"offset":"0"}`이 추가되어 있는 것을 볼 수 있습니다. 본 파일을 일반적인 방법으로 unpack하면 아래와 같은 에러가 발생합니다.

<img src="https://user-images.githubusercontent.com/112851717/206966052-c5bb8d3c-bbc2-4389-a9d6-7cef5df4146c.png" width=80%>

brute fource를 통해 `.codesign`의 `size` 값을 찾을 수 있습니다.

brute fource를 통해 `.codesign size` 값을 찾은 후에 `app.asar.unpacked`이 있는 폴더에서 unpack을 하면 정상적으로 unpack한 결과를 얻을 수 있습니다.

```python
# unpack_asar.py
import os
from threading import Thread
def brute(_min, _max):
    for i in range(_min,_max):
        tmp_data = b''
        with open('./app.asar', 'rb') as f:
            data = f.read()
            tmp_data = data[:46]
            tmp_data += bytes(str(i).encode())
            tmp_data += data[51:]
        with open(f'./work_space/{i}.asar', 'wb') as f:
            f.write(tmp_data)
        os.system(f'cp -r app.asar.unpacked ./work_space/{i}.asar.unpacked')
        a = os.system(f'npx asar extract ./work_space/{i}.asar is_unpackapp 2> /dev/null')
        if os.listdir().count('is_unpackapp'):
            return
        else:
            os.system(f'rm -rf ./work_space/{i}.asar ./work_space/{i}.asar.unpacked')

if __name__ == "__main__":
    n = 1000
    os.mkdir('./work_space')
    threads = []
    for i in range(0,20):
        b = i*n
        t = Thread(target=brute, args=(b,b+1000))
        t.start()
        threads.append(t)
    for thread in threads:
        thread.join()
```

<img src="https://user-images.githubusercontent.com/112851717/206973232-ae1fd5d9-ae09-41e5-88ff-b058c8a09962.png" width=80%>

### 1.2. Electron 보안옵션

아무 이상 없이 unpack 을 한 소스를 대상으로는 소스에 대한 난독화 또는 빌딩 여부에 상관 없이 Renderer process 에 대한 Electron 보안옵션을 체크할 수 있습니다.

해당 보안 옵션이 중요한 이유는 보안옵션에 따라서 그 뒤에 진행해나갈 공격 방식이 천차만별로 달라지기 때문입니다.

상세 보안 옵션은 [링크](https://www.electronjs.org/docs/latest/tutorial/security) 를 참고하시길 바랍니다.

본 문서를 작성하는 2022년 12월 13일 기준으로 최신 Electron 버전은 20 버전으로 존재하는 대표적 보안옵션은 아래와 같습니다.

| 종류                     | 기능 요약                                                                                                                                         |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| NodeIntegration          | Renderer Process 에서 Node.js API 를 사용할 수 있음                                                                                               |
| ContextIsolation         | MainProcess 로직과 Renderer Process 로직을 논리적으로 분리함                                                                                      |
| Sandbox                  | [Chrome Sandbox](https://chromium.googlesource.com/chromium/src/+/HEAD/docs/design/sandbox.md) 과 같이 Electron 앱과 OS 의 리소스를 서로 격리시킴 |
| NodeIntegratinoSubFrames | top frame 은 node API 사용이 불가하더라도, iframe 에서는 node API 를 사용할 수 있게 허용할 수 있는 옵션                                           |

해당 옵션을 분석하는 방식은 코드 분석으로 진행하여도 가능하오나, 아래 소스를 보시면 해당 보안 옵션은 [BrowserWindow 함수](https://www.electronjs.org/docs/latest/api/browser-window) 로 Renderer Process 객체를 생성하는 부분에서 사용된다는 **고정적 특징** 이 존재합니다.

```javascript
// RendererProcess_Example.js
_browser = new BrowserWindow({
  webPreferences: {
    nodeIntegration: true,
    contextIsolation: false,
    enableRemoteModule: true,
  },
});
```

그러므로 해당 부분을 트레이싱 하면 비교적 취약한 부분을 탐색하는데 용이합니다.

하지만 저희 Dev Ranger 팀은 이러한 패턴을 파악하여 손쉽게 CodeQL 을 통해 취약 옵션이 적용되어있는 부분을 탐색할 수 있도록 쿼리를 제작하였습니다.

아래는 수많은 보안 옵션 중, `nodeIntegration` 이 취약한 부분을 탐색하는 쿼리로 소스가 빌드되었거나 난독화 된 소스에서도 신속하고 정확한 스캐닝이 가능합니다.

```javascript
/**
 * @kind problem
 * @id js/selectNodeIntegration
 * @name selectNodeIntegration
 * @description 앱 내에서 NodeJS API 사용가능
 * @problem.severity error
 * @precision high
 */

import javascript

//nodeIntegration: 0!
predicate isVulnNodeIntegration(Property props, Label label, UnaryExpr unexpr){
    // label 이 동일하고
    label.getName()="nodeIntegration" and props.getAChild() = label
    and
    // 속성이 취약한 Prop 이면 true
    unexpr.toString()="!0" and props.getAChild()=unexpr
}
from Property props, Label label, UnaryExpr unexpr
where isVulnNodeIntegration(props, label, unexpr)
select props, "NodeIntegration is enabled"

```

### 1.3. IPC 사용여부

[IPC](https://www.electronjs.org/docs/latest/api/ipc-main) 란 Electron 에 존재하는 Main Process 와 Renderer Process 사이에서 검증된 통신을 할 수 있도록 개발자 측에서 미리 정의해둔 함수 및 모듈입니다.

![](https://i.imgur.com/CbkbIfD.png)

위 사진은 IPC 가 동작하는 간략한 예시 입니다. 만약 Renderer 측에서 알림창을 그려주길 원하면, 앱은 Main Process 에 미리 정의되어있는 알림창 띄우기 함수를 사용해야만합니다. 이것이 개발자가 보안을 위해 적용한 일종의 룰이라고 생각하면 됩니다.

이는 `contextIsolation` 옵션이 활성화 되어있을 때, Main Process 와 통신할 수 있는 유일한 소통창구가 되는데 만약 이러한 함수 정의에 취약점이 존재한다면 `contextIsolation` 보안옵션이 활성화되어 안전한 상황에서도 XSS 및 RCE 같은 침투 상황이 발생할 수 있는 것입니다.

이러한 IPC 는 아래와 같이 `ipcMain` 및 `ipcRenderer` 모듈을 import 또는 require 하는 부분에 정의되어있는 경우가 많습니다.

```javascript
import { ipcMain } from "electron";
// or
import { ipcRenderer } from "electron";
```

아래는 Dev Ranger 팀의 취약점 연구 결과로 발견한 취약하게 정의된 IPC 함수의 예시입니다.

본 함수는 사용자의 개인 설정을 조작할 수 있는 IPC 함수로, 공격 페이로드를 통해 해당 `settings-change` 함수를 트리거 시키면 공격자 마음대로 사용자의 설정을 조작할 수 있는 것입니다.

```javascript
ipcMain.on("settings-change", _onSettingsChange);
function _onSettingsChange(event, data) {
  logger.warn(`${FILE_NAME}_onSettingsChange()`, data);
  const settingsBrowser = _browser.settingsBrowser;
  if (settingsBrowser) {
    if (!data.useDirectDownload) {
      data.downloadPath = "";
    }
    if (data.autoStart) {
      _setting.enableAutoLaunch();
    } else if (!data.autoStart) {
      _setting.disableAutoLaunch();
    }
    _setting.saveSetting(data);
    settingsBrowser.webContents.send("saved-success");
  }
}
```

### 1.4. `require` 함수의 사용가능 여부

(nodeIntegration, **webpack_require** , nodeRequire 등등 서술 예정)

`nodeIntegraion` 활성화가 되어있는 경우, node module 을 불러올 수 있는 함수인 `require` 함수의 존재는 취약점 분석에서 굉장히 크리티컬한 요소입니다.

![](https://i.imgur.com/gSNU9Xq.png)

![](https://i.imgur.com/5BXqSoZ.png)

그렇기에 규모가 큰 벤더같은 경우에는 `require` 함수를 frame 별로 사용 가능한 영역을 나누거나, 난독화를 해놓는 등의 패턴을 보여줍니다.

![](https://i.imgur.com/l9LBbYv.png)

그러므로 분석하는 입장에서는 현재 window 즉, frame 에서 사용할 수 있는 함수를 파악하는 것이 중요합니다.

Visual Studio Code 의 경우에는 사용자와의 상호작용에서 자유로운 top frame 에서만 `nodeRequire` 이라는 이름으로 `require` 함수를 대체하여 사용하는 모습을 보여주었습니다.

![](https://i.imgur.com/1p8zuN0.png)

만약 사용가능한 `require` 계열의 함수가 존재하지 않는다면, 강제로 불러올 수 있는 방법이 존재합니다.

`Sandbox = true, contextIsolation = false` 일 때, electron 내장 함수를 사용하는 사용자 정의 함수 또는 어떤 경로로든지 electron 내장 함수를 사용을 하게 되면, 그 때부터 `window` 객체에 `__webpack_require__` 라는 특수한 `require` 함수가 세팅되게 됩니다.

저희가 분석한 특정 벤더에는 아래와 같이 electron 내장 함수를 부를 수 있는 특수 케이스가 존재했습니다.

```javascript
top.__electronApi.copyText(""); // __webpack_require__ 세팅됨
/*
  ... etc
*/
top.window
  .__webpack_require__("module")
  ._load("child_process")
  .execSync("/System/Applications/Calculator.app/Contents/MacOS/Calculator");
```

`copyText` 라는 함수를 호출하게 되면, `__webpack_require__` 함수가 생기게 되고 결론적으로는 원격 코드 실행을 일으킬 수 있다는 것입니다.

그 외에도, `require` 가 제한된 iframe 에서 `postMessage` 함수로 top 에 있는 `require` 을 이용하는 방법 등의 다양한 경로가 존재합니다.

### 1.5. 딥링크 핸들러

Electron 앱의 경우는 어떠한 OS나 플랫폼에도 구애받지 않기위한 크로스플랫폼이라는 특성을 갖고 있습니다.

그러한 크로스 플랫폼을 가능하게 해주는 기능 중 하나가 [딥링크 기능](https://www.electronjs.org/docs/latest/tutorial/launch-app-from-url-in-another-app) 입니다.

예를 들면, skype 앱의 경우에는 딥링크를 아래와 같이 활용하고 있습니다.

`skype://<username>?<action>`

이와 같은 URL 형식을 전달하면, skype 앱을 굳이 클릭해서 열지않아도 해당 user 에 대해 원하는 action 을 하도록 유도할 수 있습니다. `skype://devranger?call` 이라는 URL 을 주면 통화하는 화면으로 바로 넘어가도록 유도할 수 있는 것입니다.

이러한 딥링크는 편리성이라는 장점을 갖고있는 반면에 Zero Click 취약점을 유도할 수 있는 좋은 도구가 되기도 합니다.

예를 들면, 현재 패치된 [RunJS](https://runjs.app/) 의 경우 딥링크 핸들러가 패치되기 이전에 아래와 같은 딥링크 기능이 존재했습니다.

`runjs://<something>?script=<javascript code encoded with base64>`

위 URL 에서 보이듯이 script 인자에 base64 로 인코딩한 자바스크립트 코드를 전달해주면, RunJS 앱에서 해당 javascript 코드를 바로 실행시킵니다.

해당 기능은 RunJS 측에서 공식적으로 공개한 기능은 명백하게 아니지만, `<appname>://` 으로 시작하는 URL 을 파싱하는 **딥링크 핸들러** 기능이 어딘가에는 분명 정의되어있다는 Electron 앱의 특성 및 패턴을 파악하고 분석을 하여 발굴 해낼 수 있었던 취약점입니다.

이러한 딥링크 핸들러는 정의 패턴이 앱마다 굉장히 천차만별이고, 정의 위치 또한 일정하지 않기 때문에 CodeQL 로 핸들러 위치를 신속히 파악하는 것이 굉장히 중요합니다. 아래는 그에 대한 예시 쿼리문입니다.

```javascript
  /**
 * @name Empty block
 * @kind problem
 * @problem.severity warning
 * @id javascript/example/empty-block
 */
import javascript

from DataFlow::MethodCallNode startFunc
, string arg1StartFunc
, ExprStmt expr
, string scheme
where
    startFunc.getMethodName() = "startsWith"
    and arg1StartFunc = startFunc.getArgument(0).getStringValue()
    and arg1StartFunc.regexpMatch("^.*://.*$")

    and scheme = expr.getAToken().toString()
    and not scheme.regexpMatch("^.*"+arg1StartFunc+".*$")
    and scheme.regexpMatch("^.*://.*$")

select startFunc.getArgument(0), "to" , scheme
```

## 2. Chrome Exploit

Electron 보안 옵션 중, `nodeIntegration` 이 비활성화 되어있어서 node API 를 사용할 수 없으며, `sandbox` 또한 걸려있을 경우 위에 서술한 분석방법은 대부분은 효용이 없는 방법이 될 것입니다.

그러나 이런 경우에 앱이 낮은 버전의 Electron 프레임워크를 사용하여, 그에 종속되는 Chrome 엔진 버전 또한 낮을 경우 기존에 공개된 1-day Chrome Exploitation 을 이용하거나 개량하여 Exploit 이 가능할 수 있습니다.

### 2.1. 필요조건

우선 현재 Exploit 하고자하는 Electron 내의 Chrome 엔진 버전에 대한 취약점이 존재해야합니다.
해당 취약점에 대해서는 직접 디버깅하거나 퍼징하여 찾거나, 기존에 존재하는 Chromium Exploitation 또는 [Chromium Bug](https://bugs.chromium.org/p/chromium/issues/list) 를 개량하는 방식 등이 존재합니다.

각 OS 별 Electron 디버깅 가능환경은 다음과 같습니다.

| OS      | Debugger                                                                                              |
| ------- | ----------------------------------------------------------------------------------------------------- |
| Windows | [windbg](https://learn.microsoft.com/ko-kr/windows-hardware/drivers/debugger/debugger-download-tools) |
| Linux   | [gdb](https://www.sourceware.org/gdb/)                                                                |
| Mac     | [lldb](https://lldb.llvm.org/)                                                                        |

### 2.2. 환경구축

분석을 하기위한 환경 구축은 다음과 같습니다.

우선 버전파악에 초점을 맞추어야합니다. 각 앱의 Electron 버전과 Chrome 엔진 버전은 앱의 `개발자도구 - Network` 탭에 들어가면, 앱이 통신하면서 header 로 전달하는 **User-Agent** 를 통해 파악할 수 있습니다.

<img src="https://i.imgur.com/MeBdWml.png" alt="" style="width:70%"></img>

![](https://i.imgur.com/e29ksUb.png)

버전 확인에 성공하였다면, 이제 그것에 맞는 [디버깅 심볼](https://github.com/electron/electron/releases) 을 가져오면 분석 준비가 완료됩니다.

<img src="https://i.imgur.com/qEYUOIE.png" style="width:40%"></img>

[자세한 환경구축 방법](https://github.com/BoB11-Dev-Ranger/DevRanger_Project/blob/main/2_methodology/2_2_analysis_methodology/electron_environment.md)

### 2.3. 공격 및 분석방식

Chrome Exploitation 을 이용한 공격 루트에는 [1.2.](#12-electron-보안옵션)에서 설명한 옵션들이 다 활성화되어있다는 가정하에, `Sandbox` 옵션에 따라 크게 두 가지로 구분할 수 있습니다.

#### 2.3.1. `Sandbox` 보안옵션이 활성화 되어있을 때

`Sandbox` 옵션이 활성화 되어있는 경우, 앱 내에서 보안 옵션을 강제로 조작하여 취약점 트리거로 연계할 수 있습니다.

예를 들면, 아래와 같이 Renderer Process 에 `ContextIsolation` 과 `Sandbox` 옵션이 걸려있을 경우, 해당 프로세스는 **Main Process** 와 **Node API** 에 접근이 불가합니다.

![](https://i.imgur.com/lZSDEPg.png)

이 때, 해당 앱에 존재하는 Chrome 취약점을 이용하여 Exploit 을 진행하면, 아래와 같이 `ContextIsolation` 을 비활성화 하고, `NodeIntegration` 옵션을 강제 활성화 하여 **Main Process** 및 **Node API** 를 연결 시킬 수 있습니다.

![](https://i.imgur.com/bqNFdVk.png)

이러한 결과를 낼 수 있도록 Dev Ranger 팀이 사용한 방법 중 하나는 아래와 같습니다.

![](https://i.imgur.com/soz8108.png)

Chrome Exploitation 을 통해 **Fake Object** 를 생성하여 앱에 존재하는 `window` 객체의 주소를 leak 할 수 있는 경우, 디버깅을 통해 각 보안옵션에 대한 offset 을 구해낼 수 있습니다. 그 후에는 offset 을 이용하여 옵션들을 조작하면 성공적으로 Exploit 을 진행할 수 있습니다.

단, Electron 버전 별로 offset 이 굉장히 달라지기 때문에 [2.2. 환경구축](#22-환경구축) 의 환경을 기반으로한 디버깅이 필수적입니다.

그리고 보안옵션 중에서도 `ContextIsolation` 을 비활성화 시키는 경우에는 [1. 코드 분석](#1-코드-탐색) 과 동반하여 **Prototype Pollution** 공격 또한 가능함을 발견할 수 있었습니다.

[각 보안 옵션의 offset을 구하고 Electron 디버깅하는 방법](https://github.com/BoB11-Dev-Ranger/DevRanger_Project/blob/main/2_methodology/2_2_analysis_methodology/electron_debugging.md)

#### 2.3.2. `Sandbox` 보안옵션이 비활성화 되어있을 때

`Sandbox` 옵션이 비활성화 되어있는 경우에는 OS 의 리소스를 자유롭게 사용가능하다는 점에 의거하여, 메모리에 쉘코드를 쓰는 쪽으로 Exploit 을 진행합니다. 이는 `Sandbox` 옵션이 활성화되었을 때, 일일히 offset 을 알아내서 Exploit 하는 것보다 조금 더 심플하다는 장점이 있습니다.

Dev Ranger 팀의 경우에는 V8 에 자체 내장되어있는 [WASM](https://chromium.googlesource.com/v8/v8/+/refs/heads/main/src/wasm/wasm-objects.h) 객체를 할당 받는 접근을 하였습니다. WASM 객체를 할당받게 되면 해당 메모리 영역은 웹어셈을 읽고,쓰고,실행하기 위해 **Read/Write/Execute** 권한을 갖게 됩니다.

저희는 이러한 메모리 영역에 쉘코드를 입혀서 Remote Code Execution 을 트리거하는 방식을 사용하였습니다.

추가적인 연구결과로는 V8 프로세스 메모리에 존재하는 일반 함수의 코드를 덮어씌워도 같은 취약점을 트리거할 수 있다는 결론을 낼 수 있었습니다.

## 3. 서드파티모듈

서드파티모듈은 Visual Studio Code 의 확장프로그램, Figma 에서 사용할 수 있는 플러그인 등과 같이 앱에서 확장하여 사용할 수 있는 툴을 의미 합니다.

이러한 툴들 자체에 취약점이 존재하거나 툴이 동작하는 iframe, 즉 Renderer 프로세스에 대한 보안 처리가 미흡하게 되면 툴이 실행되고 있는 앱의 보안설정이 잘 되있더라고 하여도 취약점을 발생시킬 수 있습니다.

Dev Ranger 팀에서 발굴한 Visual Studio Code 의 Git lens 취약점을 예로 들어보면 다음과 같습니다.

[연구페이지](https://blog.sonarsource.com/securing-developer-tools-git-integrations/) 를 보면, git의 config 파일에 잘못된 커맨드를 실행하도록 입력해놓으면 git 관련 명령들을 수행할 때마다 shell 명령이 실행되도록 유도할 수 있었습니다.

이러한 취약점에 대한 별다른 조치없이 git lens 확장프로그램은 잘못된 config 파일에 설정되어있는 커맨드를 실행하는 상황이었습니다.

더하여, 확장프로그램 모두를 실행할 수 없도록 제한하는 Visual Studio Code 제한모드에서 조차도 git lens 는 실행이 가능하였기에 위에서 설명한 딥링크 취약점과 연계하여 악성 git repository 를 연결시킨 후, 원격 코드 실행까지 실행시키는 취약점을 발굴할 수 있었습니다. 이는 최종적으로 [CVE-2022-44110](https://cve.report/CVE-2022-44110) 의 CVE Number 를 받을 수 있었습니다.

이처럼 앱 자체 말고도 서드파티모듈을 통한 취약점 발생 루트도 있음을 인지하여야 합니다.

## 4. CodeQL

[CodeQL](https://github.com/github/codeql) 은 C/C++ 또는 자바스크립트 등으로 작성한 코드에 대해 사전에 정의한 취약점 패턴이 감지가 되는지 AST 파싱 방식을 이용하여 취약점 위험을 탐지하는 프로그램입니다.

Dev Ranger 팀은 프로젝트가 어느정도 진전이 되고, 다양한 취약점들이 발굴 된 시점에 수많은 벤더에 대해 취약점 연구를 효율적으로 하기위해 CodeQL 을 사용하였습니다.

실제로 CodeQL 은 일일히 모든 파일에 코드 패턴을 대조하는 단순 비교작업과는 다르게 AST 토큰을 통해 작업이 이루어지다보니 굉장히 신속하고 정확한 코드 위협 탐지에 효과적이었습니다.

프로젝트 후반부에는 저희가 제작한 CodeQL 쿼리들이 Beekeeper-Studio, Obsidian 등의 취약점을 식별하는데에 큰 기여를 할 수 있었습니다.

사용한 쿼리 예제는 [CodeQL 쿼리](../Queries/) 에 정리하였습니다.
