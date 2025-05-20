# flutter_naver_login
[![Build Status](https://img.shields.io/badge/pub-v2.1.0-success.svg)](https://pub.dev/packages/flutter_naver_login)
[![Build Status](https://img.shields.io/badge/naverAosSDK-v5.10.0-success.svg)](https://github.com/naver/naveridlogin-sdk-android)
[![Build Status](https://img.shields.io/badge/naverIosSDK-v5.0.0-success.svg)](https://github.com/naver/naveridlogin-sdk-ios-swift)
[![Build Status](https://img.shields.io/badge/build-passing-success.svg)](https://travis-ci.org/roughike/flutter_naver_login)


Android와 iOS에서 네이버 로그인 SDK를 사용하기 위한 Flutter 플러그인입니다.

## 설치

### 1. 의존성 추가
`pubspec.yaml` 파일에 다음 내용을 추가하세요:

```yaml
dependencies:
  flutter_naver_login: ^2.1.0
```

### 2. 플랫폼 설정

#### Android
1. `android/app/src/main/res/values/strings.xml` 파일에 다음 내용을 추가하세요:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="client_id">[client_id]</string>
    <string name="client_secret">[client_secret]</string>
    <string name="client_name">[client_name]</string>
</resources>
```

2. `android/app/src/main/AndroidManifest.xml` 파일을 수정하세요:

```xml
<application
    android:name="io.flutter.app.FlutterApplication"
    android:label="your_app_name"
    android:icon="@mipmap/ic_launcher">
    <!-- 중요: task affinity가 필요하지 않은 경우 android:taskAffinity="" 라인을 제거하세요 -->
    <meta-data
        android:name="com.naver.sdk.clientId"
        android:value="@string/client_id" />
    <meta-data
        android:name="com.naver.sdk.clientSecret"
        android:value="@string/client_secret" />
    <meta-data
        android:name="com.naver.sdk.clientName"
        android:value="@string/client_name" />
</application>
```

> **참고**: AndroidManifest.xml에서 `android:taskAffinity=""` 라인이 보인다면, task affinity 기능이 특별히 필요한 경우가 아니라면 제거하세요.

3. MainActivity에서 `FlutterFragmentActivity`를 사용하세요:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity()
```

#### iOS
1. pods 설치:
```bash
cd ios
pod install
```

2. `ios/Runner/Info.plist` 파일을 수정하세요:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>[UrlScheme]</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>naversearchapp</string>
    <string>naversearchthirdlogin</string>
</array>

<key>naverServiceAppUrlScheme</key>
<string>[UrlScheme]</string>
<key>naverConsumerKey</key>
<string>[ConsumerKey]</string>
<key>naverConsumerSecret</key>
<string>[ConsumerSecret]</string>
<key>naverServiceAppName</key>
<string>[ServiceAppName]</string>
```

3. AppDelegate를 수정하세요:

```swift
import NaverThirdPartyLogin

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var applicationResult = false
        if (!applicationResult) {
           applicationResult = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
        }
        if (!applicationResult) {
           applicationResult = super.application(app, open: url, options: options)
        }
        return applicationResult
    }
}
```

## 사용 방법

### 타입

#### NaverLoginResult
```dart
class NaverLoginResult {
  final NaverLoginStatus status;  // 로그인 상태
  final NaverAccountResult? account;  // 계정 정보
}
```

#### NaverToken
```dart
class NaverToken {
  final String accessToken;  // 액세스 토큰
  final String refreshToken;  // 리프레시 토큰
  final String tokenType;  // 토큰 타입
  final String expiresAt;  // 만료 시간
  
  bool isValid();  // 토큰 유효성 검사
}
```

#### NaverAccountResult
```dart
class NaverAccountResult {
  final String id;  // 사용자 ID
  final String nickname;  // 닉네임
  final String name;  // 이름
  final String email;  // 이메일
  final String gender;  // 성별
  final String age;  // 나이
  final String birthday;  // 생일
  final String birthyear;  // 출생년도
  final String profileImage;  // 프로필 이미지
  final String mobile;  // 휴대폰 번호
  final String mobileE164;  // E164 형식의 휴대폰 번호
}
```

#### NaverLoginStatus
```dart
enum NaverLoginStatus {
  loggedIn,  // 로그인됨
  loggedOut,  // 로그아웃됨
  error  // 에러
}
```

### API 사용 예제

#### 로그인
```dart
try {
  final NaverLoginResult res = await FlutterNaverLogin.logIn();
  if (res.status == NaverLoginStatus.loggedIn) {
    // 로그인 성공
    final account = res.account;
    print('사용자 이름: ${account?.name}');
  }
} catch (error) {
  print('로그인 실패: $error');
}
```

#### 현재 액세스 토큰 가져오기
```dart
try {
  final NaverToken token = await FlutterNaverLogin.getCurrentAccessToken();
  if (token.isValid()) {
    print('액세스 토큰: ${token.accessToken}');
    print('리프레시 토큰: ${token.refreshToken}');
    print('토큰 타입: ${token.tokenType}');
    print('만료 시간: ${token.expiresAt}');
  }
} catch (error) {
  print('토큰 가져오기 실패: $error');
}
```

#### 현재 계정 정보 가져오기
```dart
try {
  final NaverAccountResult account = await FlutterNaverLogin.getCurrentAccount();
  print('사용자 이름: ${account.name}');
  print('이메일: ${account.email}');
  print('프로필 이미지: ${account.profileImage}');
} catch (error) {
  print('계정 정보 가져오기 실패: $error');
}
```

#### 로그아웃
```dart
try {
  final NaverLoginResult res = await FlutterNaverLogin.logOut();
  if (res.status == NaverLoginStatus.loggedOut) {
    // 로그아웃 성공
  }
} catch (error) {
  print('로그아웃 실패: $error');
}
```

#### 로그아웃 및 토큰 삭제
```dart
try {
  final NaverLoginResult res = await FlutterNaverLogin.logOutAndDeleteToken();
  if (res.status == NaverLoginStatus.loggedOut) {
    // 로그아웃 및 토큰 삭제 성공
  }
} catch (error) {
  print('로그아웃 및 토큰 삭제 실패: $error');
}
```

## 문제 해결

### iOS 문제

1. **CocoaPods 버전 에러**
   - 해결방법: Podfile에 최소 배포 타겟을 지정하세요:
   ```ruby
   platform :ios, '10.0'
   ```

2. **빌드 시스템 에러**
   - 해결방법: Xcode에서 File > Project Settings로 이동하여 Build System을 "Legacy Build System"으로 변경하세요

3. **링커 에러**
   - 해결방법: 빌드 폴더를 정리하고 다시 빌드하세요:
   ```bash
   cd ios
   pod deintegrate
   pod install
   ```

### Android 문제

1. **뒤로가기 버튼 문제**
   - 해결방법: `shouldAutomaticallyHandleOnBackPressed`가 포함된 `MainActivity` 코드를 사용하세요

2. **Proguard 문제**
   - 해결방법: `proguard-rules.pro` 파일에 제공된 Proguard 규칙을 추가하세요

## 기여하기

이슈나 풀 리퀘스트를 통해 프로젝트에 기여해주세요.

## 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다. 자세한 내용은 LICENSE 파일을 참조하세요. 