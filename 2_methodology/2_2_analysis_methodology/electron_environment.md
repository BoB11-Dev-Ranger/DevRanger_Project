## 환경구축

버전 확인에 성공하였다면, Electron파일과 버전에 맞는 디버깅 심볼 을 가져옵니다.

![alt](https://camo.githubusercontent.com/4a10dd6074d5ea49a39047176598ae1f893d57b43002dd3e1f09396b751541a6/68747470733a2f2f692e696d6775722e636f6d2f714559554f49452e706e67)

저희는 Electron 분석을 할때 사용하였던 v14.2.9기준으로 설명하겠습니다.

먼저 자신의 OS와 아키텍쳐에 맞게 파일을 다운받습니다. 저희는 Linux 기준으로 디버깅할것이기 떄문에 `electron-v14.2.9-linux-x64-debug.zip`와 `electron-v14.2.9-linux-x64.zip`을 다운받겠습니다.

![alt](https://i.imgur.com/jrjeBUw.png)

다운이 완료되면 파일을 폴더에 압축 해제합니다.

그리고 다음 명령어를 쳐서 Electron을 실행시킵니다.

![alt](https://i.imgur.com/nhCqwRx.png)

그리고 다른 Terminal에서 `ps -af` 명령어를 작성합니다.

![alt](https://i.imgur.com/n7Pam4J.png)

그럼 다음과 같은 화면을 볼수 있습니다.

그중 type이 renderer인 부분의 pid를 통해 gdb에 연결합니다.

이후 Electron Symbols을 불러오면 분석을 위한 준비는 끝입니다.

![alt](https://i.imgur.com/rOSqL7Z.png)
![alt](https://i.imgur.com/oI9mDPo.png)

다음과 같이 `p blink` 명령어를 입력하였을떄 `Attempt to use a type name as an expression`이 결과로 나오면 성공적으로 심볼을 부른것 입니다.