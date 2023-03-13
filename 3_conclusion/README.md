# 프로젝트 성과

## 목차

- [1. 개발자 생태계 앱 개발 체크리스트](#1-개발자-생태계-앱-개발-체크리스트)
- [2. CodeQL 자동 코드 검사 솔루션](#2-CodeQL-자동-코드-검사-솔루션)
- [3. 취약점 제보 및 코드패치](#3-취약점-제보-및-코드패치)
  - [3.1. 취약점 제보 결과](#31-취약점-제보-결과)

---

## 1. 개발자 생태계 앱 개발 체크리스트

저희는 연구한 내용을 토대로 다음 3가지 부분에서 취약점이 발생할수 있다고 판단하여 3가지 부분을 기준으로 다음과 같은 체크리스트를 구성하였습니다.

- Main Process에서 발생할수 있는 취약점
- Renderer Process에서 발생할수 있는 취약점
- 외부와 통신할때 사용할수 있는 API를 이용한 취약점

| Electron Application Development Security CheckList                                                                    |         |        |                    |
| ---------------------------------------------------------------------------------------------------------------------- | :-----: | :----: | :----------------: |
| **Main Process**                                                                                                       | **Yes** | **No** | **Not Applicable** | 
| IPC에서 처리하는 데이터는 안전한가?                                                                                    |         |        |                    |
| DeepLink를 통해 가져온 데이터의 처리는 안전한가?                                                                       |         |        |                    |
| OpenExternal과 같은 악용될수 있는 함수를 사용하는 코드에서의 필터링과 같은 작업은 유효한가?                            |         |        |                    |     |
| **Renderer Process**                                                                                                   | **Yes** | **No** | **Not Applicable** |
| Cross-site Scripting이 발생할수 있는가?                                                                                |         |        |                    |
| 사용자에게 직접적으로 보여지는 페이지에서 NodeIntegration혹은 NodeIntegrationInSubFrame Option이 비활성화 되어 있는가? |         |        |                    |
| Local Resource에 접근할 경우 안전하게 처리하는가?                                                                      |         |        |                    |
| Electron WebPreference Option인 sandbox가 켜져있는가?                                                                  |         |        |                    |
| Electron WebPreference Option인 webSecurity가 켜져있는가?                                                              |         |        |                    |
| Electron WebPreference Option인 allowRunningInsecureContent가 꺼져있는가?                                              |         |        |                    |
| 사용하고 있는 Electron의 Chromium이 안전한가?                                                                          |         |        |                    |
| 사용하고 있는 Electron의 NodeJS는 안전한가?                                                                            |         |        |                    |
| ContextIsolation을 비활성화된 페이지에서 Prototype Pollution 취약점을 통한 인증 우회에서 안전한가?                     |         |        |                    |
| ContextIsolation이 비활성화된 페이지에서 webview tag를 사용할수 없도록 막아두었는가?                                   |         |        |                    |
| webview tag를 사용할 경우 allowpopups option을 사용할수 없게 하였는가?                                                 |         |        |                    |
| webview tag를 사용할 경우 인증된 옵션과 파라미터를 사용하는가?                                                         |         |        |                    |
| **Web Backend**                                                                                                        | **Yes** | **No** | **Not Applicable** |
| App과 통신하는 API에서 Logic버그가 발생할수 있는가?                                                                    |         |        |                    |
| API를 통해서 보낸 데이터는 안전한가?                                                                                   |         |        |                    |

다음과 같은 체크리스트를 거칠경우 대부분의 취약점은 방지가 가능합니다.

## 2. CodeQL 자동 코드 검사 솔루션

발굴한 취약점들을 토대로 제작한 CodeQL 쿼리를 기반으로 하여 보안에 관하여 지식이 전무한 개발자들도 본인의 코드를 손쉽게 체크할 수 있도록 [CodeQL 자동 코드 분석 솔루션](https://github.com/BoB11-Dev-Ranger/CodeQL-Service) 을 제작하여 배포하였습니다.

본 솔루션은 Mono Repository 시스템 구성으로 이루어져있어서, 단일 리포지토리 하나만으로도 클라이언트 및 서버를 손쉽게 구성할 수 있습니다.

또한, Typescript 를 통한 엄격한 타입 규정을 통해 추후 일부 팀이나 단체에서 커스텀 하여 사용하기도 편리합니다.

![alt](https://i.imgur.com/uhsbU8K.png)

![alt](https://i.imgur.com/ThPjzNS.png)

해당 솔루션 빌드 후, 작동시키면 위와 같이 본인의 레포지토리를 업로드 하여 Dev Ranger 의 CodeQL 쿼리에 기반한 코드 위험성 분석을 진행할 수 있습니다.

위 사진과 같이 위험성 정보와 소스 위치를 통해 본인의 소스에 대한 위험성을 교차검증 할 수 있다는 장점이 있습니다.

## 3. 취약점 제보 및 코드패치

### 3.1. 취약점 제보 결과

| 벤더               | 취약점                    | 적용 플랫폼         | 최종 결과                                           |
| ------------------ | ------------------------- | ------------------- | --------------------------------------------------- |
| Visual Studio Code | 원격코드실행              | Mac                 | [CVE-2022-44110](https://cve.report/CVE-2022-44110) |
| Notion             | 원격코드실행 1            | Windows             | **버그바운티 ≈$2,000**                              |
| Notion             | 원격코드실행 2            | Windows, Mac        | 제보 진행중                                         |
| Notion             | CSRF를 통한 민감정보 누출 | Windows, Mac        | 제보 진행중                                         |
| JANDI              | 원격코드실행 1            | Windows, Mac        | **버그바운티 ≈$1,000**                              |
| JANDI              | 원격코드실행 2            | Windows, Mac        | **버그바운티 ≈$1,000**                              |
| JANDI              | 원격코드실행 3            | Windows, Mac        | **버그바운티 ≈$1,000**                              |
| Obsidian           | 로컬 파일 누출            | Windows, Mac, Linux | [CVE-2022-44791](https://cve.report/CVE-2022-44791) |
| RunJS              | 원격코드실행              | Windows, Mac, Linux | **패치완료**                                        |
| Beekeeper-Studio   | 원격코드실행              | Windows, Mac, Linux | [CVE-2022-43143](https://cve.report/CVE-2022-43143) |
| Left               | 원격코드실행 1            | Windows, Mac, Linux | [CVE-2022-44110](https://cve.report/CVE-2022-44110) |
| Left               | 원격코드실행 2            | Windows, Mac, Linux | 제보 진행중                                         |
| Mermaid            | 민감정보누출              | Windows, Mac, Linux | **패치완료**                                         |
| Figma              | 서비스 거부               | Windows, Mac        | 제보 진행중                                         |
| Microsoft Teams    | 서비스 거부               | Windows, Mac        | 제보 진행중                                         |
| Visual Studio Code | 서비스 거부               | Windows, Mac, Linux | 제보 진행중                                         |
### 3.2. 취약점 제보 결과 Eng Ver
| Vendor               | Vulnerability                    | Affected Platform         | Result                                           |
| ------------------ | ------------------------- | ------------------- | --------------------------------------------------- |
| Visual Studio Code | Remote Code Execution              | Mac                 | [CVE-2022-44110](https://cve.report/CVE-2022-44110) |
| Notion             | Remote Code Execution            | Windows             | ** ≈$2,000**                              |
| Notion             | Remote Code Execution            | Windows, Mac        | 제보 진행중                                         |
| Notion             | Sensitive Data Exposure | Windows, Mac        | 제보 진행중                                         |
| JANDI              | Remote Code Execution            | Windows, Mac        | ** ≈$1,000**                              |
| JANDI              | Remote Code Execution            | Windows, Mac        | ** ≈$1,000**                              |
| JANDI              | Remote Code Execution           | Windows, Mac        | ** ≈$1,000**                              |
| Obsidian           | Local File Disclosure            | Windows, Mac, Linux | [CVE-2022-44791](https://cve.report/CVE-2022-44791) |
| RunJS              | Remote Code Execution              | Windows, Mac, Linux | **Patched**                                        |
| Beekeeper-Studio   | Remote Code Execution              | Windows, Mac, Linux | [CVE-2022-43143](https://cve.report/CVE-2022-43143) |
| Left               | Remote Code Execution            | Windows, Mac, Linux | [CVE-2022-44110](https://cve.report/CVE-2022-44110) |
| Left               | Remote Code Execution            | Windows, Mac, Linux | 제보 진행중                                         |
| Mermaid            | Sensitive Data Exposure              | Windows, Mac, Linux | **Patched**                                         |
| Figma              | Denial Of Service               | Windows, Mac        | 제보 진행중                                         |
| Microsoft Teams    | Denial Of Service               | Windows, Mac        | 제보 진행중                                         |
| Visual Studio Code | Denial Of Service               | Windows, Mac, Linux | 제보 진행중                                         |
