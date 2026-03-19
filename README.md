# Nearly - 러닝 메이트 모집 앱

> 내 주변 러너들과 함께 달리세요



<프로젝트 개요>

Nearly는 위치 기반으로 러닝 메이트를 모집하고, 코스를 직접 그려 공유하며 함께 달릴 수 있는 iOS 앱입니다.  
혼자 달리기 외로운 러너들을 위해 근처의 러닝 모임을 쉽게 찾고 참여할 수 있도록 만들었습니다.


| 항목 | 내용 |
|------|------|
| 개발 기간 | 2026.01 ~ 2026.03 (약 2개월) |
| 개발 인원 | 1인 (개인 프로젝트) |
| 배포 상태 | AppStore 배포 준비 중 |



<사용 기술>

| 분류 | 기술 |
|------|------|
| Language | Swift |
| UI Framework | SwiftUI |
| 지도 | MapKit |
| 인증 | Google Sign-In, KakaoSDK, Naver Login |
| DB | Firebase Realtime Database |
| 위치 | CoreLocation |
| 아키텍처 | MVVM |



<주요 기능>

<img width="300" alt="Simulator Screenshot - iPhone 17 Pro - 2026-03-15 at 14 59 36" src="https://github.com/user-attachments/assets/41f9d698-8a8d-439a-9054-d37cdf0ad145" />

1. 소셜 로그인
- Google, 카카오, 네이버 3가지 소셜 로그인 지원
- `UserDefaults`를 활용한 로그인 플랫폼 상태 유지
- 신규 유저 / 기존 유저 분기 처리

<p>
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-03-19 at 15 02 52" src="https://github.com/user-attachments/assets/c60c1b43-33aa-40b6-92fd-459e98c7a4fc" width: "200" />

<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-03-19 at 15 05 39" src="https://github.com/user-attachments/assets/21729528-8768-4732-88d3-46b8716c782a" width: "200" />

<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-03-19 at 15 08 27" src="https://github.com/user-attachments/assets/110298d6-71f6-4f2f-9768-1f023fd70514" width: "200" />

<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-03-19 at 15 05 43" src="https://github.com/user-attachments/assets/22f9216e-fa2b-467d-ae1b-552c3d026f5e" width: "200" />
</p>

2. 러닝 모집글
- 모집글 작성 / 조회 / 삭제
- Firebase Realtime Database 기반 실시간 데이터 관리
- 모집글 참여 / 참여 취소 토글

3. 푸시알림(FCM + CloudFunctions)
- 누군가 내 모집글에 참여하면 작성자에게 실시간 푸시 알림 발송
- Firebase Cloud Functions로 DB 변경 감지 후 자동화
- APNs 연동 및 FCM 토큰 관리

4. 지도 기반 코스 설정
- 모집 위치 설정: 지도를 탭하여 집결 위치 핀 설정
- 코스 드로잉: 드래그 제스처로 러닝 경로를 직접 지도에 그리기
- `MapPolyline`을 활용한 경로 시각화

5. 러닝 트래킹
- 실시간 GPS 경로 추적 및 지도 표시
- 거리 / 시간 / 속도 실시간 측정
- 러닝 기록 히스토리 저장

6. 위치 기반 서비스
- `CoreLocation`을 통한 현재 위치 획득
- `MKReverseGeocodingRequest`로 좌표 → 주소 변환 (역지오코딩)



<아키텍처>

```
Nearly
├── Model
│   ├── User.swift
│   ├── Recruit.swift
│   ├── Run.swift
│   ├── UserLocation.swift
│   └── Coordinate.swift
│
├── Manager (ViewModel)
│   ├── UserManager.swift         # 유저 상태 관리 및 Firebase 연동
│   ├── RecruitManager.swift      # 모집글 상태 관리 및 Firebase 연동
│   ├── LocationManager.swift     # 위치 권한 및 GPS 업데이트
│   ├── RunningViewModel.swift    # 러닝 타이머 및 기록 관리
│   └── AppStateViewModel.swift   # 앱 전체 화면 상태 관리
│
├── View
│   ├── RootView.swift            # 로그인 / 프로필 / 메인 분기
│   ├── LoginView.swift           # 로그인
│   ├── ProfileView.swift         # 위치 확인 및 프로필 생성
│   ├── MainView.swift            # 게시글 리스트
│   ├── RecruitView.swift
│   ├── RecruitDetailView.swift
│   ├── AddRecruitView.swift      # 게시글 추가
│   ├── MeetMapView.swift         # 집결지 설정 지도
│   ├── RouteMapView.swift        # 코스 드로잉 지도
│   ├── RunningView.swift         # 러닝 타이머
│   └── MapView.swift             # 위치 확인
│
└── Service
    ├── GeocodingService.swift    # 역지오코딩
    ├── TimeService.swift         # 날짜 포맷
    └── ColorManager.swift        # 앱 컬러 정의
```



<기술적 도전 및 트러블슈팅>

1. CLLocationCoordinate2D Firebase 파싱 문제

- 문제  
Firebase에서 데이터를 가져올 때 `CLLocationCoordinate2D`를 직접 캐스팅하려 해 항상 `nil`이 반환되는 버그가 있었습니다.

```
// CLLocationCoordinate2D는 AnyObject 캐스팅 불가
let meetingLocation = value["meetingLocation"] as? CLLocationCoordinate2D
```

- 해결
Firebase에서 딕셔너리로 먼저 받은 후 직접 좌표를 초기화하도록 수정했습니다.

```
// 딕셔너리로 파싱 후 직접 초기화
if let loc = value["meetingLocation"] as? [String: Any],
   let lat = loc["lat"] as? Double,
   let lon = loc["lon"] as? Double {
    meetingLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
}
```

---

2. 비동기 위치 업데이트 타이밍 문제

- 문제  
`requestLocation()` 호출 직후 `userLocation`을 읽으면 위치가 아직 들어오기 전이라 항상 `nil`이었습니다.

```
// 비동기 결과를 동기적으로 읽으려 함
locationManager.requestLocation()
userManager.user.userLocation = locationManager.userLocation // nil!
```

- 해결
`.onChange`로 위치가 실제로 업데이트된 시점에 반응하도록 수정했습니다.

```
// 위치 업데이트 감지 후 처리
.onChange(of: locationManager.userLocation) { _, newLocation in
    guard let newLocation else { return }
    userManager.user.userLocation = newLocation
    isPresented = false
}
```

3. 드래그 제스처 조건 처리

- 문제
`RouteMapView`에서 드로잉 모드가 꺼져 있어도 드래그 제스처가 작동해 의도치 않게 좌표가 추가되는 문제가 있었습니다.

- 해결
제스처 핸들러 내부에서 `isDrawingMode` 조건을 추가해 드로잉 모드일 때만 좌표를 기록하도록 수정했습니다.

```
.onChanged { value in
    guard isDrawingMode else { return }
    // 좌표 추가 로직
}
```

4. FCM 토큰 발급 타이밍 문제

- 문제
앱 최초 실행 시 FCM 토큰은 네트워크 비동기로 발급되는데, 사용자가 토큰 발급 전에 로그인 버튼을 누르면 UserDefaults에 토큰이 없어 저장에 실패했습니다.

```
swift// didReceiveRegistrationToken이 아직 호출되지 않은 상태
func saveToken() {
    guard let token = UserDefaults.standard.string(forKey: "fcmToken") else { return } // nil
}
```

- 해결
didReceiveRegistrationToken에서 즉시 UserDefaults에 저장하고, 로그인 시점에 꺼내 사용하도록 순서를 분리했습니다.

```
swift// AppDelegate - 토큰 도착 즉시 저장
func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let token = fcmToken else { return }
    UserDefaults.standard.set(token, forKey: "fcmToken")
}
```

```
// 로그인 성공 후 꺼내서 DB 저장
func saveToken() {
    guard let token = UserDefaults.standard.string(forKey: "fcmToken") else { return }
    self.user.fcmToken = token
}
```


5. Firebase participants 데이터 구조 설계

- 문제
참여자를 배열로 저장하면 Cloud Functions의 onCreate 트리거가 개별 참여를 감지하지 못하고 배열 전체가 덮어씌워질 때만 트리거되는 문제가 있었습니다.

- 해결
참여자를 딕셔너리 구조로 변경해 개별 노드 생성 시 트리거가 정확히 발동하도록 수정했습니다.

```
swift// 변경 전 - 배열 전체 덮어쓰기
ref.child("participants").setValue(updatedParticipants)

// 변경 후 - 개별 노드 추가/삭제
ref.child("participants").child(userId).setValue(true)  // 참여
ref.child("participants").child(userId).removeValue()   // 취소
Cloud Functions에서 정확한 트리거:
javascriptexports.sendJoinNotification = onValueCreated(
    { ref: "/recruits/{postId}/participants/{userId}", instance: "..." },
    async (event) => {
        // 작성자에게 푸시 발송
    }
);
```



<참여도>

| 항목 | 내용 |
|------|------|
| 개발 인원 | 1인 (개인 프로젝트) |
| 기여도 | 기획 / 설계 / 개발 100% |
