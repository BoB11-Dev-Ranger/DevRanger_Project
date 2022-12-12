# 분석 방법론

- [1. 코드 탐색](#1-코드-탐색)

  - [1.1. Electron 보안옵션](#11-Electron-보안옵션)
  - [1.2. IPC 사용여부](#12-IPC-사용여부)
  - [1.3. iframe 옵션](#13-iframe-옵션)
  - [1.4. 딥링크 핸들러](#14-딥링크-핸들러)

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
![](https://user-images.githubusercontent.com/112851717/206965418-ed0c2775-0c78-4fd8-9ba7-53c56e5b028a.png)


asar unpacking을 방지한 asar파일의 hexdump는 아래와 같습니다.
![](https://user-images.githubusercontent.com/112851717/206965411-3fb00030-e26d-4421-b521-b0e67830ef1f.png)
위의 정상적인 asar파일과 달리 `{".codesign":{"size":-1000,"offset":"0"}`이 추가되어 있는 것을 볼 수 있습니다. 본 파일을 일반적인 방법으로 unpack하면 아래와 같은 에러가 발생합니다.
![](https://user-images.githubusercontent.com/112851717/206966052-c5bb8d3c-bbc2-4389-a9d6-7cef5df4146c.png)

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
![](https://user-images.githubusercontent.com/112851717/206973232-ae1fd5d9-ae09-41e5-88ff-b058c8a09962.png)

### 1.2. Electron 보안옵션

### 1.3. IPC 사용여부

### 1.4. iframe 옵션

### 1.5. 딥링크 핸들러

## 2. Chrome Exploit

## 3. 서드파티모듈

## 4. CodeQL
