# 공격 벡터
- [Electron application 구조](#electron-application-구조)
    - [Electron Security Option](#electron-security-option)
    - [Electron Structure Diagram](#electron-structure-diagram)
- [STRIDE 위협 모델링](#stride-위협-모델링)
- [Attack Tree](#attack-tree)
---

## Electron application 구조

Electron은 크게 Main Process와 Renderer Process가 존재합니다.

`Main Process`는 하나의 application에 하나만 존재할 수 있으며 nodejs API를 호출할 수 있습니다. 

`Renderer Process`는 Chromium을 기반으로 동작하고 하나의 application에 여러 Renderer Process가 존재할 수 있습니다. Renderer Process는 nodejs API와 직접적으로 호출할 수 없고 Main Process에 IPC 요청을 통해서만 호출할 수 있습니다.

### Electron Security Option

Electron에는 크로미움의 sandbox 옵션과 같은 여러 보안 옵션이 존재합니다. 이는 기본적으로 활성화되어 있으며 개발자가 필요에 따라 비활성화 시킬 수 있습니다.

1. nodeIntegration
    - nodeIntegration이 활성화되어 있을 경우 Renderer Process가 nodejs API에 직접적으로 접근할 수 있습니다. 
    - Electron 5.0 이후로 기본적으로 비활성화되어 있습니다.
2. contextIsolation
     - contextIsolation이 활성화되어 있을 경우 Main Process와 Renderer Process의 컨텍스트가 분리됩니다.
     - 비활성화되어 있을 경우 Main Process와 Renderer Process의 컨텍스트가 분리되지 않아 Prototype Pullotion과 같은 공격을 통해 Renderer Process에서 Main Process에 영향을 줄 수 있습니다. 
      - Electron 12.0 이후로 기본적으로 활성화되어 있습니다.
3. nodeIntegrationInSubFrames 
     - nodeIntegrationInSubFrames이 활성화되어 있을 경우 iframe과 같은 subframe에서 nodejs API와 통신할 수 있습니다.
     - 기본적으로 비활성화되어 있습니다.
4. webSecurity
     - webSecurity이 비활성화되어 있는 경우 기본 크롬 브라우저에서 다양한 보안 기능이 해제됩니다. SOP를 비활성화하고 HTTPS 페이지가 HTTP 오리진의 콘텐츠를 로드할 수 있도록 합니다.
5. sandbox
     - 기존 크로미움의 sandbox 옵션과 동일합니다.
     - Electron 20.0 이후로 기본적으로 모든 Renderer Process에서 활성화되어 있습니다.

### Electron Structure Diagram

Electron은 다음과 같은 과정을 거쳐서 작동합니다.
1. 메인프로세스에서 각 개발자가 설정한 BrowserWindows에 설정한 Option에 맞춰 렌더러 프로세스를 시작합니다.
2. 렌더러 프로세스에서는 IPC를 통해 메인프로세스와 정보를 가져오고 Chromium을 통하여 사용자에게 보여지는 Renderer를 구성합니다.
4. 사용자와 렌더러는 계속해서 상호작용을 하고 렌더러 프로세스는 계속해서 데이터를 IPC를 통하여 가져오거나 Web API를 통하여 외부에서 정보를 가져옵니다.
5. 이때 메인프로세스는 렌더러 프로세스에서 요청한 정보를 컴퓨터 내부의 자원을 가져와야 하는 경우도 있습니다. 이때 NodeAPI를 사용하여 컴퓨터 자원을 가져옵니다.

Electron의 위의 동작을 다이어그램으로 정리하면 아래와 같습니다.

<img src="https://user-images.githubusercontent.com/66944342/207488500-2a0618b8-5f0d-4af4-bf43-3019ccd65555.png" width=80%>

다이어그램을 통해 옵션에 따른 Main Process와 Renderer Process의 상호작용을 한눈에 볼 수 있습니다. 

## STRIDE 위협 모델링

| 위협 종류                 | 공격으로 인한 결과  |     
| ------------------       | ------------------------- | 
Spoofing                   |     거짓된 권한을 이용하여 시스템의 접근 권한을 획득
Tampering                  |     불법적으로 데이터를 수정
Repudiation                |     사용자가 수행한 행동에 대한 부인
Information Disclosure     |     유출되서는 안되는 개인 정보 유출
Denial of Service          |     시스템 또는 애플리케이션이 정상적으로 수행되지 않도록 함
Elevation of Privilege     |     제한된 권한을 가진 사용자가 다른 사용자의 권한을 습득

| Name |Additional Threat Derivation  | STRIDE  |     
| ---- | -------------------------    |  :----: |
Main Process |  IPC내에서 보내는 데이터에 대한 부족한 필터링으로 인한 Cross-site Script 발생하여 NodeJS 호출후 Code Execution 가능 | |
| | 부족한 필터링으로 인한 OpenExternal함수에 file 스킴 사용가능하여 특정파일 동작  | S, E |
| | IPC내에서 보내는 데이터에 대한 부족한 필터링으로 인한 Cross-site Script 발생하여 NodeJS 호출후 Code Execution 가능  | S, E  | 
Renderer Process | 필터링 부족으로 인한 Cross-site Script 발생  | T |
|| ContextIsolation 옵션이 꺼져있을때 Prototype Pollution으로 인한 인증 우회  | S, T, E |
|| ContextIsolation 옵션이 꺼져있고 nodeAPI를 불러오는 부분이 중간에 포함되어 있을때 `__Webpack_require__` 노출하여 Code Execution 발생  | T, I, E |
|| NodeIntegration 혹은 NodeIntegrationSubFrame이 켜져있고 Require를 지우지않았을 경우 Require를 통한 NodeJS를 호출하여 Code Execution 발생  | E |
|| Electron의 낮은 버전으로 인하여 낮은 Chromium Version 사용시 Chromium취약점 발생  | E |
||Chrome Security Option의 설정이 부족할 경우 취약점 발생(Ex: SOP, Allow Local Resource) | I | 
||XSS가 발생하는 페이지에서 IPC를 호출하는 함수에 접근가능할 경우 의도치 않은 동작 발생 | T, D |
||유저 정보에 대한 암호화 부재로 인한 유저 정보노출 | R, I |
App Backend | 웹 API 호출시에 교차검증 부재로 인한 API 오남용 | E |
|| DeepLink로 인한 로직버그 | S, D, E |
NodeJS API  | Electron의 낮은 버전으로 인하여 낮은 버전의 NodeJS 사용시 취약점 발생 | E | 
|| 낮은 NodeJS Module을 설치하여 사용할 경우 취약점 발생 | E |

## Attack Tree

위의 STRIDE 위협 모델링을 통해 정리한 위협들을 공격 백터로 분류하여 최종적인 Attack Tree를 그리면 아래와 같습니다.
<img src="https://user-images.githubusercontent.com/66944342/207555988-78214490-fb2c-4b2c-a3ec-54b15fabc7c3.png" width=80%>

Root 노드를 Electron Application Exploit으로 지정하고 Root 노드를 이루는 가장 큰 공격 백터 두가지를 `Electron Process`와 이와 통신하여 여러 데이터를 서버에서 처리하는 `Web Backend Server`로 나눴습니다.

그리고 Exploit을 성공시키기 위해서 가장 먼저 필요한 조건들인 XSS등을 나열하고 이에 따라 계속 노드를 나누어 결과적으로 마지막 노드에 도달했을시에 RCE, Information Leak등의 어떤 공격 결과를 얻을 수 있는지 표현했습니다.
