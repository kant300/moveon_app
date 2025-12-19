<!-- 로고 (React 스타일: 작게) -->
<p align="center">
  <img src="https://github.com/kant300/moveon/blob/parkoaksun/src/main/resources/static/img/%EB%AC%B4%EB%B8%8C%EC%98%A8%EB%A1%9C%EA%B3%A0-crop.png?raw=true" width="120" />
</p>

<h1 align="center">🏙️ mOveOn (MoveOn)</h1>

<p align="center">
  공공데이터와 GPS를 활용한 <b>지역 정착 지원 생활정보 통합 플랫폼</b><br/>
  이사 후 필요한 생활·안전·교통 정보를 하나의 앱에서 제공합니다.
</p>

---

## 👨‍💻 프로젝트 소개
**무브온(MoveOn)** 은 1인가구, 신혼부부, 직장 발령자 등  
새로운 지역으로 이주한 사용자가 빠르게 정착할 수 있도록  
**공공데이터 API + 지도 + 위치 기반 정보(GPS)** 를 결합해  
생활 정보를 통합 제공하는 Flutter 기반 모바일 애플리케이션입니다.

---

## 🧩 기획 목표
- 분산된 지역 생활 정보를 **하나의 플랫폼에서 통합 제공**
- 공공데이터 API와 지도 연동을 통해 **신뢰성 있고 최신화된 정보 제공**
- 사용자가 직관적으로 활용할 수 있는 **간편 UI/UX 설계로 접근성 강화**

---

## 🎯 기대 효과
- 공공데이터와 GPS를 결합한 **맞춤형 생활 서비스 및 데이터 기반 비즈니스 모델 창출**
- 정보 탐색 시간 단축을 통한 **사용자 스트레스 감소**
- **안전한 주거 환경 조성** 및 **교통 약자 지원 강화**
- 사용자 위치 기반 공공데이터 활용을 통한 **새로운 정보 창출**

---

## 🕰 개발 개요

| 구분 | 내용 |
|------|------|
| **개발기간** | 2025.10.26 ~ 2025.11.27 |
| **플랫폼** | Flutter (Android / iOS) |
| **사용기술** | Flutter(Dart), 지도 SDK / WebView, 공공데이터 API, GPS(Geolocator), Dio, SharedPreferences |
| **기획·디자인** | Figma (UI/UX) |
| **협업/도구** | GitHub, Android Studio, VS Code |

---

## 📱 주요 화면

### 🔐 회원 · 게스트 온보딩

<img width="1168" height="622" alt="member,guest" src="https://github.com/user-attachments/assets/c7be8911-b3c6-46d2-9b05-8e4b90e2b001" />

- 회원 / 게스트 접속
- 주소 입력
- 관심(즐겨찾기) 선택  
- 회원은 **첫 가입 시 관심 정보 설정**

---

### 🏠 메인 화면

<img width="282" height="605" alt="hoom" src="https://github.com/user-attachments/assets/9e6081d4-00f0-431c-82a6-1c430f345d95" />

- 위치 기반 날씨 정보 제공
- 안전 정보(CCTV, 성범죄자 등) 요약 표시
- 정착 Check-list 현황 확인
- 즐겨찾기 기능을 통한 빠른 접근

---

### 📂 메뉴 화면

<img width="279" height="604" alt="menu" src="https://github.com/user-attachments/assets/2b5a0c40-0e65-49be-8adb-2a0b5a1cffa2" />

- 생활 / 안전 / 교통 카테고리 분류
- 공공데이터 기반 정보 메뉴 제공
- 즐겨찾기 등록 및 관리

---

### 🗺️ 지도 기능 통합

<img width="275" height="599" alt="map" src="https://github.com/user-attachments/assets/5a2cea36-8660-46ec-8cf4-2c3563e62018" />


- 공공데이터를 활용한 지도 정보 표시
- 주변 시설 위치 확인
- **이동 시간 계산 기능 구현**
- 지도 기반 생활 정보 통합 제공

---

## ⚙️ 주요 기능 정리
- 회원 / 게스트 온보딩 (주소·관심 입력)
- 공공데이터 기반 지도 기능 구현
- 주변 시설 이동 시간 계산
- 개인 정착 체크리스트 기능
- 위치 기반 날씨 정보 제공
- 기본 레이아웃 및 화면 구조 설계
- Git 기반 협업 및 통합 관리

---

## 🧭 프로젝트 구조

```bash
moveon_app/
├── android/
├── ios/
├── linux/
├── macos/
├── assets/
├── lib/
│   ├── living/
│   ├── safety/
│   ├── weather/
│   ├── member/
│   ├── screens/
│   │   └── onboarding/
│   ├── widgets/
│   │
│   ├── Checklist.dart
│   ├── ExpandableCategoryList.dart
│   ├── Home.dart
│   ├── Map.dart
│   ├── Menu.dart
│   ├── MyPage.dart
│   ├── Setting.dart
│   ├── NotFound.dart
│   └── main.dart
│
├── img/                # README용 이미지
│   ├── hoom.png
│   ├── menu.png
│   ├── map.png
│   └── member_guest.png
├── test/
└── pubspec.yaml
