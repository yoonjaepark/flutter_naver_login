# flutter_naver_login
[![Build Status](https://img.shields.io/badge/pub-v2.1.1-success.svg)](https://pub.dev/packages/flutter_naver_login)
[![Build Status](https://img.shields.io/badge/naverAosSDK-v5.10.0-success.svg)](https://github.com/naver/naveridlogin-sdk-android)
[![Build Status](https://img.shields.io/badge/naverIosSDK-v5.0.0-success.svg)](https://github.com/naver/naveridlogin-sdk-ios-swift)
[![Build Status](https://img.shields.io/badge/build-passing-success.svg)](https://travis-ci.org/roughike/flutter_naver_login)

A Flutter plugin for using the native Naver Login SDKs on Android and iOS.

## AndroidX support

- for [AndroidX Flutter projects](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility)

## Migration 
[from pre-2.1.0 to 2.1.0](#migration-guide).

## Installation

### 1. Add dependency
Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_naver_login: ^2.1.0
```

### 2. Platform Setup

#### Android
1. Add the following to your `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="client_id">[client_id]</string>
    <string name="client_secret">[client_secret]</string>
    <string name="client_name">[client_name]</string>
</resources>
```

2. Update your `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:name="io.flutter.app.FlutterApplication"
    android:label="your_app_name"
    android:icon="@mipmap/ic_launcher">
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

3. Use `FlutterFragmentActivity` in your MainActivity:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity()
```

#### iOS
1. Install pods:
```bash
cd ios
pod install
```

2. Update your `ios/Runner/Info.plist`:

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

<key>NidUrlScheme</key>
<string>[UrlScheme]</string>
<key>NidClientID</key>
<string>[ConsumerKey]</string>
<key>NidClientSecret</key>
<string>[ConsumerSecret]</string>
<key>NidAppName</key>
<string>[ServiceAppName]</string>
```

3. Update your AppDelegate:

```swift
import NidThirdPartyLogin

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (NidOAuth.shared.handleURL(url) == true) { // If the URL was passed from the Naver app
          return true
        }
     		
        // Handle URLs coming from other apps
        return false
    }
}
```

## Migration Guide

### iOS Migration from pre-2.1.0 to 2.1.0

#### 1. Update Info.plist

##### Before 2.1.0:
```xml
<key>naverServiceAppUrlScheme</key>
<string>[UrlScheme]</string>
<key>naverConsumerKey</key>
<string>[ConsumerKey]</string>
<key>naverConsumerSecret</key>
<string>[ConsumerSecret]</string>
<key>naverServiceAppName</key>
<string>[ServiceAppName]</string>
```

##### After 2.1.0:
```xml
<key>NidUrlScheme</key>
<string>[UrlScheme]</string>
<key>NidClientID</key>
<string>[ConsumerKey]</string>
<key>NidClientSecret</key>
<string>[ConsumerSecret]</string>
<key>NidAppName</key>
<string>[ServiceAppName]</string>
```

#### 2. Update AppDelegate

##### Before 2.1.0:
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

##### After 2.1.0:
```swift
import NidThirdPartyLogin

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (NidOAuth.shared.handleURL(url) == true) { // If the URL was passed from the Naver app
          return true
        }
        
        // Handle URLs coming from other apps
        return false
    }
}
```

#### 3. Migration Process

```bash
cd ios
pod deintegrate
pod install
flutter clean
flutter pub get
```

## Usage

### Types

#### NaverLoginResult
```dart
class NaverLoginResult {
  final NaverLoginStatus status;
  final NaverAccountResult? account;
}
```

#### NaverToken
```dart
class NaverToken {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String expiresAt;
  
  bool isValid();
}
```

#### NaverAccountResult
```dart
class NaverAccountResult {
  final String id;
  final String nickname;
  final String name;
  final String email;
  final String gender;
  final String age;
  final String birthday;
  final String birthyear;
  final String profileImage;
  final String mobile;
  final String mobileE164;
}
```

#### NaverLoginStatus
```dart
enum NaverLoginStatus {
  loggedIn,
  loggedOut,
  error
}
```

### API Examples

#### Login
```dart
try {
  final NaverLoginResult res = await FlutterNaverLogin.logIn();
  if (res.status == NaverLoginStatus.loggedIn) {
    // Login successful
    final account = res.account;
    print('User name: ${account?.name}');
  }
} catch (error) {
  print('Login failed: $error');
}
```

#### Get Current Access Token
```dart
try {
  final NaverToken token = await FlutterNaverLogin.getCurrentAccessToken();
  if (token.isValid()) {
    print('Access Token: ${token.accessToken}');
    print('Refresh Token: ${token.refreshToken}');
    print('Token Type: ${token.tokenType}');
    print('Expires At: ${token.expiresAt}');
  }
} catch (error) {
  print('Failed to get token: $error');
}
```

#### Get Current Account
```dart
try {
  final NaverAccountResult account = await FlutterNaverLogin.getCurrentAccount();
  print('User name: ${account.name}');
  print('User email: ${account.email}');
  print('User profile: ${account.profileImage}');
} catch (error) {
  print('Failed to get account: $error');
}
```

#### Logout
```dart
try {
  final NaverLoginResult res = await FlutterNaverLogin.logOut();
  if (res.status == NaverLoginStatus.loggedOut) {
    // Logout successful
  }
} catch (error) {
  print('Logout failed: $error');
}
```

#### Logout and Delete Token
```dart
try {
  final NaverLoginResult res = await FlutterNaverLogin.logOutAndDeleteToken();
  if (res.status == NaverLoginStatus.loggedOut) {
    // Logout and token deletion successful
  }
} catch (error) {
  print('Logout and token deletion failed: $error');
}
```

## Troubleshooting

### iOS Issues

1. **CocoaPods Version Error**
   - Solution: Update your Podfile to specify the minimum deployment target:
   ```ruby
   platform :ios, '13.0' // https://github.com/naver/naveridlogin-sdk-ios-swift
   ```

2. **Build System Error**
   - Solution: In Xcode, go to File > Project Settings and change Build System to "Legacy Build System"

3. **Linker Error**
   - Solution: Clean the build folder and rebuild:
   ```bash
   cd ios
   pod deintegrate
   pod install
   ```

### Android Issues

1. **Back Button Issue**
   - Solution: Use the provided `MainActivity` code with `shouldAutomaticallyHandleOnBackPressed`

2. **Proguard Issues**
   - Solution: Add the provided Proguard rules to your `proguard-rules.pro` file

## Contributing

Feel free to contribute to this project by submitting issues or pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
