# 연구 배경 및 목표

## 목차

- [1. 연구배경](#1-연구-배경)
  - [1.1. 산업 및 시장상황](#11-산업-및-시장상황)
    - [1.1.1. 개발자 수요](#111-개발자-수요)
    - [1.1.2. 개발자 생태계 앱에 대한 점유율](#112-개발자-생태계-앱에-대한-점유율)
    - [1.1.3. 발생할 수 있는 침투상황](#113-발생할-수-있는-침투상황)
  - [1.2. 연구 범위](#12-연구-범위)
    - [1.2.1. IDE](#121-IDE)
    - [1.2.2. 협업](#122-협업)
    - [1.2.3. 화상회의](#123-화상회의)
    - [1.2.4. 형상관리](#124-형상관리)
    - [1.2.5. 가상화](#125-가상화)
    - [1.2.6. Database-Manager](#126-Database-Manager)
    - [1.2.7. 에디터](#127-에디터)
  - [1.3. 연구 목표](#13-연구-목표)

---

## 1. 연구 배경

개발자들이 사용하는 애플리케이션들에서 침투상황 발생에 대해 연구하고, 개발 업계 보안성 향상에 이바지 하고자 연구를 진행하였습니다.

### 1.1. 산업 및 시장상황

코로나 19 펜데믹 상황에서 비대면 환경에서의 생활이 크게 증가하게 되었습니다. 그에 따라 어느 직업군에 상관없이 비대면으로 진행되는 업무 또한 그 빈도가 크게 증가하게 되었습니다. 그러한 상황이 맞물림에 따라 빅테크 산업의 발전과 개발자의 수요 또한 증가하게 되고, 개발자들이 사용하는 앱들에 대한 점유율도 큰 폭으로 상승하는 모습을 포착 할 수 있었습니다.

#### 1.1.1. 개발자 수요

![alt](https://i.imgur.com/a1V7olL.png)
_[출처:IT조선]_

코로나 19 펜데믹 상황으로 인해 대부분의 기업의 수익이 감소함에 따라 고용 감축이 실행되는 상황 속에서도 비대면 상황에 큰 기여를 할 수 있는 개발자 고용에 대한 수요는 오히려 증가하는 모습을 볼 수 있었습니다.

#### 1.1.2. 개발자 생태계 앱에 대한 점유율

![alt](https://i.imgur.com/Vbtok2V.png)
_[출처:비즈조선일보]_
![alt](https://i.imgur.com/eC44dNn.png)
_[출처:insights.stackoverflow]_

대표적인 협업앱인 [노션](http://notion.es)의 경우는 2021년 ~ 2022년 사이에 한국 시장에서 점유율이 263% 까지 상승하는 모습을 볼 수 있었고, IDE(통합개발환경) 분야에서의 대표적인 앱인 Visual Studio Code 의 경우는 코로나 19가 시작된 2020 년 이후로 상승폭이 더 증가한 모습을 볼 수 있습니다.

#### 1.1.3. 발생할 수 있는 침투상황

![alt](https://i.imgur.com/nr8qfRi.png)
_[출처: 보안뉴스]_
![alt](https://i.imgur.com/b3I0oWR.png)
_[출처: TechM]_

### 1.2. 연구 범위

본 단락에서는 취약점 분석 연구를 진행할 연구 표본을 개발 업무 분야별로 나누어 정리하였습니다.

#### 1.2.1. IDE

- [Visual Studio Code](https://code.visualstudio.com/)

#### 1.2.2. 협업

- [Notion](http://notion.es)

- [JANDI](https://www.jandi.com/landing/kr/downloadhttps://www.microsoft.com/en-us/microsoft-teams/group-chat-software)

- [MS Teams](https://www.microsoft.com/en-us/microsoft-teams/group-chat-software)

- [Figma](https://www.figma.com/)

- [Slack](https://slack.com/intl/ko-kr/)

- [Discord](https://discord.com/)

- [Mattermost](https://mattermost.com/)

#### 1.2.3. 화상회의

- [zoom](https://zoom.us/)

- [What's APP : Microsoft Store 를 통해 설치](#)

- [Skype](https://skype.daesung.com/main.asp)

#### 1.2.4. 형상관리

- [Github Desktop](https://circleci.com/github-and-circleci/?utm_source=google&utm_medium=sem&utm_campaign=sem-google-dg--japac-en-githubDesktop-maxConv-auth-nb&utm_term=g_e-github%20desktop_c__rsa2_20220322&utm_content=sem-google-dg--japac-en-githubDesktop-maxConv-auth-nb_keyword-text_rsa-githubDesktop_mixed-&gclid=CjwKCAiA-dCcBhBQEiwAeWidtUxGWEGBPLKFirkF7rGNcDq2riibzEAvVXEGX11iRf5BZOAn0TnDXxoC6HgQAvD_BwE)

- [Gitkraken](https://www.gitkraken.com/)

- [SourceTree](https://www.sourcetreeapp.com/)

#### 1.2.5. 가상화

- [Docker](https://www.docker.com/products/docker-desktop/)

#### 1.2.6. Database-Manager

- [Beekeeper-Studio](https://www.beekeeperstudio.io/)

- [Azure Data Studio](https://www.datadoghq.com/dg/monitor/azure-benefits/?utm_source=advertisement&utm_medium=search&utm_campaign=dg-google-infra-apac-azure-broad&utm_keyword=azure&utm_matchtype=p&utm_campaignid=18130030043&utm_adgroupid=142915819840&gclid=CjwKCAiA-dCcBhBQEiwAeWidtWob5PElnLPuGlhbxMgJ-YVD5tod7Osz1bHPNlbFpsU5jFLYZrnetRoCpR8QAvD_BwE)

#### 1.2.7. 에디터

- [Obsidian](https://obsidian.md/)

- [Notable](https://notable.app/)

- [InkDrop](https://www.inkdrop.app/)

- [Left](https://hundredrabbits.itch.io/left)

- [Yank](https://github.com/purocean/yn)

- [RunJS](https://runjs.app/)

### 1.3. 연구 목표

- 개발자 앱을 개발하는 개발자들이 본인의 코드를 점검할 수 있도록 체크리스트 및 솔루션 제공

- 보안 담당자들을 위해 개발자 관련 앱들에 대한 분석 방법론 제공

- 궁극적으로 개발자 생태계 보안성 향상 도모
