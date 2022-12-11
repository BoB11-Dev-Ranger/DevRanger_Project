# 선행 연구

## 목차

- [1. Electron 기반 협업 프로그램 취약점 분석](#1-Electron-기반-협업-프로그램-취약점-분석)

  - [1.1. 요약](#11-요약)

- [2. ElectroVolt:Pwning Popular Desktop apps while uncovering new attack surface on Electron](#2-ElectroVoltPwning-Popular-Desktop-apps-while-uncovering-new-attack-surface-on-Electron)

  - [2.1. 요약](#21-요약)

- [3. Hector Peralta:Debug and exploit of Electron applications](#3-Hector-PeraltaDebug-and-exploit-of-Electron-applications)

---

## 1. Electron 기반 협업 프로그램 취약점 분석

[논문](http://www.koreascience.or.kr/article/JAKO202125141272152.pdf)

### 1.1. 요약

Electron 에서 사용되는 보안 옵션을 중점으로 애플리케이션 취약점에 대하여 평가하였다. 국내에서 유명한 애플리케이션을 지정하여 연구를 진행하였으며, 이에 대해 취약점 스캐닝을 해주는 툴인 [electrogravity](https://github.com/doyensec/electronegativity) 를 개선하는 쪽으로 연구 결론을 마무리하였다.

## 2. ElectroVolt:Pwning Popular Desktop apps while uncovering new attack surface on Electron

[2022 BlackHat 발표자료](https://i.blackhat.com/USA-22/Thursday/US-22-Purani-ElectroVolt-Pwning-Popular-Desktop-Apps.pdf)

### 2.1. 요약

ElectroVolt 연구팀이 [Discord](https://discord.com/), [VSCODE](https://code.visualstudio.com/) 등의 Electron 앱에 대하여 취약점 분석 및 발굴한 과정에 대해 발표한 내용이다. 기존에 존재하던 `NodeIntegration`, `ContextIsolation` 뿐만이 아니라 `Sandbox` 등을 비롯한 최신 Electron 보안 옵션에 대해서도 취약점 분석을 진행하여 해당 앱들에 대한 보안 조치가 어떻게 되어야하는지 제시를 하는 계기가 되었다.

## 3. Hector Peralta:Debug and exploit of Electron applications

[2022 PoC 발표자료 : 저작권으로 인한 배포 불가](#)
