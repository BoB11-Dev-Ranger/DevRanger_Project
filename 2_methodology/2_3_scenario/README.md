# 예상 침투 시나리오

## 목차

- [1. IDE를 활용한 침투 시나리오](#1-IDE를-활용한-침투-시나리오)
  - [1.1. 파일 렌더링에서 발생하는 XSS](#1.1-파일-렌더링에서-발생하는-XSS)
  - [1.2. 파일명에서 발생하는 XSS](#1.2-파일명에서-발생하는-XSS)
- [2. 협업앱을 활용한 침투 시나리오](#2-협업앱을-활용한-침투-시나리오)
  - [2.1. 채팅 앱에서 발생하는 XSS](#2.1-채팅-기능에서-발생하는-XSS)
  - [2.2. 문서 앱에서 발생하는 XSS](#2.2-문서-기능에서-발생하는-XSS)

---

## 1-IDE를-활용한-침투-시나리오

IDE에서 발생하는 RCE 취약점은 대부분 파일 렌더링에서 발생하는 XSS 및 파일명에서 발생하는 XSS에 의해 트리거 됩니다.

### 1.1-파일-렌더링에서-발생하는-XSS
파일 렌더링에서 발생하는 XSS는 주로 md 파일이나 html 파일등을 렌더링하여 사용자에게 보여주는 기능을 가진 IDE에서 발생합니다. 파일 내에 데이터를 제대로 처리하지 않은 상태로 html로 변환하여 렌더링하면 해당 파일 내에 존재하는 임의의 자바스크립트 코드가 실행되는 것입니다.

<img width="800" alt="image" src="https://user-images.githubusercontent.com/63496362/208237359-dc2820f1-0437-4e88-b807-6249358e4f8c.png">

따라서 공격자는 정상적인 소스 파일에 RCE 페이로드가 삽입된 md 파일을 포함하여 배포하는 것으로, 해당 파일을 다운로드하고 취약점이 존재하는 IDE로 오픈하는 피해자의 시스템에 침투할 수 있습니다. 이때 피해자가 삽입된 악성 스크립트를 사전에 발견하고 다운로드를 중지하거나, 파일을 오픈한 이후 발견하여 시스템 침투에 대응하는 것을 막기 위해 다음과 같은 트릭을 이용할 수도 있습니다.


> 안<img src="data:image/jpeg;base64," onerror="alert(1)">녕

위에 "안녕" 텍스트는 렌더링된 상태에서는 어떠한 특이점도 없는 텍스트입니다.

> `안<img src="data:image/jpeg;base64," onerror="alert(1)">녕`

하지만 실제로 텍스트 파일로 확인할 경우 다음과 같이 은닉된 자바스크립트가 존재합니다. 해당 텍스트가 포함된 md 파일을 취약점이 존재하는 IDE에서 오픈할 경우 실제로 해당 스크립트가 실행됩니다. 만약 RCE 페이로드가 삽입되었다면, 피해자는 자신이 오픈한 md 파일에 악성 스크립트가 삽입되었다는 사실을 알지 못한채로 공격자에게 시스템 침투를 허용할 것 입니다. 

<img width="800" alt="image" src="https://user-images.githubusercontent.com/63496362/207413812-377e4564-6733-4be7-8d5e-cdc6daf607c9.png">

특히 github에서는 `<img src="data:image/jpeg;base64,">` 다음과 같이 src에 data:image가 들어갈 경우 엑스박스를 생성하지 않습니다. 따라서 피해자는 github를 통한 파일 미리보기로 md 파일에 악성 스크립트가 삽입되어 있다는 사실을 파악할 수 없습니다.


### 1.2-파일명에서-발생하는-XSS

파일명에서 발생하는 XSS는 IDE가 파일명을 표시할때, 적절한 처리를 하지않아 발생하게 됩니다. 파일명 XSS는 파일명에 페이로드를 삽입해야되기 때문에 `>, <`등을 파일명에 사용할 수 없는 Windows 시스템에서는 공격에 제한이 있을 수 있습니다. 또한 파일명 길이에는 제한이 있기 때문에 복잡한 페이로드는 바로 삽입할 수 없습니다. 이 경우 다음과 같은 방법을 이용할 수 있습니다.

> `eval(document.getElementById("a").innerHTML)`

파일 내부에 악성 스크립트를 삽입하고 해당 스크립트를 `document.getElementById`등과 같은 함수를 통해 가져와서 `eval`명령어로 실행시키는 트리거 스크립트를 이용하면 Chromium Exploit과 같이 긴 길이의 페이로드도 실행할 수 있습니다. 이때 파일 내 데이터가 어떤 요소에 있는지에 따라서 트리거 스크립트는 달라지므로 이는 대상 앱 분석을 통해 알아내야 합니다.


## 2-협업앱을-활용한-침투-시나리오

협업앱이 제공하는 대표적인 기능으로는 채팅과 문서 등이 있습니다. RCE 취약점이 트리거되는 벡터 역시 사용자 간 채팅에서 발생하는 XSS와 문서 렌더링에서 발생하는 XSS가 대부분입니다.

### 2.1-채팅-기능에서-발생하는-XSS

채팅 기능에서 발생하는 XSS를 이용하면 악성 스크립트가 삽입된 채팅을 피해자에게 보내는 것으로 RCE가 가능합니다. 이때 단순히 채팅의 context에서 XSS 취약점이 발생하는 것이 아닌 닉네임 등과 같은 다른 데이터를 불러오는 과정에서 XSS가 발생하는 유형이 존재합니다. 이 경우 `1.2-파일명에서-발생하는-XSS` 스크립트와 동일하게 `document.getElementById`과 `eval` 함수를 사용하거나 이와 비슷한 다른 함수를 사용하는 것으로 길이 제한을 우회할 수 있습니다.

또한 대상 채팅 앱에 메시지 삭제, 채팅방 탈퇴 기능이 있는 경우 해당 기능을 동작시키는 스크립트를 사용함으로써, RCE가 트리거되는 즉시, 악성 스크립트가 삽입된 공격자의 메시지를 삭제하거나 채팅방을 탈퇴하는 것으로 침투피해 사실을 은닉할 수 있습니다.

### 2.2-문서-기능에서-발생하는-XSS

`2.2-문서-기능에서-발생하는-XSS` 유형은 `1.1-파일-렌더링에서-발생하는-XSS` 유형과 동일하게, 사용자가 만든 문서를 렌더링하는 과정에서 적절한 처리가 이루어지지 않아 발생합니다. 공격자는 이 유형의 취약점을 통해 다음과 같은 방법으로 피해자의 시스템에 침투할 수 있습니다.

* 피해자의 워크스페이스에서 악성 스크립트가 삽입된 문서를 생성
* 자신의 워크스페이스에서 악성 스크립트가 삽입된 문서를 생성하고 피해자가 해당 문서를 확인하도록 유도
* 대상 앱에 문서를 오픈하는 기능의 Deeplink가 존재한다면, 악성 스크립트가 삽입된 문서의 DeepLink URL을 피해자가 클릭하도록 유도

만약 RCE를 트리거하기 위해 사용자의 상호작용이 필요할 경우, 공격자는 악성 스크립트 뿐만 아니라 HTML, CSS 코드를 삽입하여 사용자의 클릭을 유도할 수 있습니다.

<img width="800" alt="image" src="https://user-images.githubusercontent.com/63496362/208243819-2d450f2a-6afd-4669-b41a-f5fbba9f70ab.png">

특히 다음과 같이 대상 협업툴의 에러 페이지를 모방할 경우 피해자는 해당 문서에 악성 스크립트가 존재한다는 사실을 알아차리기 더욱 어렵습니다.
