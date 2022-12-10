# 프로젝트 성과

## 목차

- [1. 개발자 생태계 앱 개발 체크리스트](#1-개발자-생태계-앱-개발-체크리스트)
- [2. CodeQL 자동 코드 검사 솔루션](#2-CodeQL-자동-코드-검사-솔루션)
- [3. 취약점 제보 및 코드패치](#3-취약점-제보-및-코드패치)
  - [3.1. 취약점 제보 결과](#31-취약점-제보-결과)
  - [3.2. 코드패치 결과](#32-코드패치-결과)

---

## 1. 개발자 생태계 앱 개발 체크리스트

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

| 벤더               | 취약점         | 적용 플랫폼         | 최종 결과                                           |
| ------------------ | -------------- | ------------------- | --------------------------------------------------- |
| Visual Studio Code | 원격코드실행   | Mac                 | [CVE-2022-44110](https://cve.report/CVE-2022-44110) |
| Notion             | 원격코드실행 1 | Windows             | **버그바운티 $1850**                                |
| Notion             | 원격코드실행 2 | Windows, Mac        | 제보 진행중                                         |
| Notion             | 원격코드실행 3 | Windows, Mac        | 제보 진행중                                         |
| JANDI              | 원격코드실행 1 | Windows, Mac        | 제보 진행중                                         |
| JANDI              | 원격코드실행 2 | Windows, Mac        | 제보 진행중                                         |
| Obsidian           | 로컬 파일 누출 | Windows, Mac, Linux | [CVE-2022-44791](https://cve.report/CVE-2022-44791) |
| RunJS              | 원격코드실행   | Windows, Mac, Linux | 패치 완료                                           |
| Beekeeper-Studio   | 원격코드실행   | Windows, Mac, Linux | [CVE-2022-43143](https://cve.report/CVE-2022-43143) |
| Left               | 원격코드실행   | Windows, Mac, Linux | [CVE-2022-44110](https://cve.report/CVE-2022-44110) |
| Left               | 원격코드실행   | Windows, Mac, Linux | 제보 진행중                                         |
| Mermaid            | 민감정보누출   | Windows, Mac, Linux | 제보 진행중                                         |
| Microsoft Teams    | XSS            | Windows, Mac        | 제보 진행중                                         |

### 3.2. 코드패치 결과

대부분 앱의 경우 오픈소스로 운용하지않는 경우가 많아서 오픈소스로 운용되는 소스에 대해서만 패치 현황을 남깁니다.

#### 3.2.1. Beekeeper-Studio
