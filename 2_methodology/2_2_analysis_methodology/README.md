# 분석 방법론

- [1. 코드 탐색](#1-코드-탐색)

  - [1.1. asar 코드 언패킹](#11-asar-코드-언패킹)
  - [1.2. Electron 보안옵션](#12-Electron-보안옵션)
  - [1.3. IPC 사용여부](#13-IPC-사용여부)
  - [1.4. iframe 옵션](#14-iframe-옵션)
  - [1.5. 딥링크 핸들러](#15-딥링크-핸들러)

- [2. Chrome Exploit](#2-Chrome-Exploit)

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

### 1.4. iframe 옵션

### 1.5. 딥링크 핸들러

Electron 앱의 경우는 어떠한 OS나 플랫폼에도 구애받지 않기위한 크로스플랫폼이라는 특성을 갖고 있습니다.

그러한 크로스 플랫폼을 가능하게 해주는 기능 중 하나가 [딥링크 기능](https://www.electronjs.org/docs/latest/tutorial/launch-app-from-url-in-another-app) 입니다.

예를 들면,
## 2. Chrome Exploit

## 3. 서드파티모듈

## 4. CodeQL
