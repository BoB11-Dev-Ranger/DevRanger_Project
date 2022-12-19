## 구축한 환경으로 Option값 변경하기

실제로 저희가 구축한 환경에서 직접 해보면 다음과 같습니다.

1. Preload.js의 주소 알아내기

    ContextIsolation이나 NodeIntegration의 주소를 알기 위해서는 ContextIsolation이나 NodeIntegration의 값이 저장되어 있는 WebPreference의 주소를 알아야합니다.

    저희는 주소를 알기 위해서 WebPreference에 정의되어 있는 Preload Option을 이용하여 주소를 알아내었습니다.

    Preload Option은 Renderer가 생성되면 시작하는 파일의 위치를 정의해주는 Option으로 String형태로 되어 있어서 다른 Option의 주소를 찾는것보다 쉽다고 판단하여 Preload Option을 이용하였습니다.
    ![alt](https://i.imgur.com/9ZJqhmD.png)
    현재 preload.js를 검색하고 문장이 시작하는 곳이 preload option의 주소입니다. 그뒤 preload.js의 주소가 위치한곳을 검색한뒤 WebPreference+preload offset의 주소를 구하였습니다.

2. WebPreference의 주소를 구하기
![alt](https://i.imgur.com/9emrUzV.png)
`p &(*('blink::web_pref::WebPreferences' * )0)->preload`을 이용하여 preload와 WebPreference간의 Offset을 구할수 있습니다.

    그리고 preload Option은 string 객체이기 때문에 String이 저장되어 있는 주소 앞에 capacity와 문자열의 길이가 저장되어있습니다. 때문에 다음과 같이 계산합니다.`(preload Address) - (offset) - 0x10`이 WebPreference의 주소입니다.

3. 구한 WebPreference를 통해 NodeIntegration과 ContextIsolation, NodeIntegrationInSubFrames의 주소를 구하기
![alt](https://i.imgur.com/6uhgPId.png)

4. ContextIsolation을 끄고 NodeIntegration과 NodeIntegrationInSubFrames을 켜서 Node API에 접근하기

    현재 NodeIntegration은 꺼져있고 NodeIntegrationInsubframes또한 꺼져있기 때문에 Node API에 접근할수 없습니다.

    ![alt](https://i.imgur.com/JT6C9Ee.png)

    먼저 NodeIntegration을 켜도록 하겠습니다.

    ![alt](https://i.imgur.com/AxDpDpb.png)

    ![alt](https://i.imgur.com/4QhxjKd.png)
    현재 contextisolation의 값을 보면 1로 활성화 되어 있는 것을 볼 수 있습니다.
    이를 0으로 변경합니다.
    그리고 NodeIntegrationInSubFrames를 켜도록 합니다.
    ![alt](https://i.imgur.com/SpLAzid.png)

    이제 마지막으로 새로운 iframe을 만듭니다. 
    ```html
    var aIframe = document.createElement("iframe");

    aIframe.setAttribute("id","id값");
    aIframe.setAttribute("name","name값");

    aIframe.style.width = "200px";
    aIframe.style.height = "100px";
    aIframe.src = "https://example.com";

    document.getElementsByTagName("body")[0].appendChild(aIframe);
    ```
    ![alt](https://i.imgur.com/rjgAor5.png)
    만든 iframe에 접근하면 require함수가 존재하여 NodeAPI를 사용할수 있게 되었습니다.

    ![alt](https://i.imgur.com/CeYA8Qt.png)

이렇게 해서 Option의 값을 변경하면 Node API를 불러올수 있는것을 알게되었습니다. 