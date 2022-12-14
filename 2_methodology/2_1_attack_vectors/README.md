# 공격 벡터

---

(위협 모델링 및 공격벡터 산정 등의 과정 기재 예정)
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
Electron의 동작 구조를 다이어그램으로 정리하면 아래와 같습니다.
<img src="https://user-images.githubusercontent.com/66944342/207488500-2a0618b8-5f0d-4af4-bf43-3019ccd65555.png" width=80%>
