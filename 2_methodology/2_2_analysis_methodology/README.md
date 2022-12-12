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

(figma 내용)

### 1.2. Electron 보안옵션

### 1.3. IPC 사용여부

### 1.4. iframe 옵션

### 1.5. 딥링크 핸들러

## 2. Chrome Exploit

## 3. 서드파티모듈

## 4. CodeQL
