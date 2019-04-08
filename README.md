# flutter_naver_login

[![pub package](https://img.shields.io/pub/v/flutter_facebook_login.svg)](https://pub.dartlang.org/packages/flutter_facebook_login)
 [![Build Status](https://travis-ci.org/roughike/flutter_facebook_login.svg?branch=master)](https://travis-ci.org/roughike/flutter_facebook_login) 
 [![Coverage Status](https://coveralls.io/repos/github/roughike/flutter_facebook_login/badge.svg)](https://coveralls.io/github/roughike/flutter_facebook_login)

A Flutter plugin for using the native Naver Login SDKs on Android and iOS.

## AndroidX support

* for [AndroidX Flutter projects](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility), use versions 2.0.0 and up.

## Installation

To get things up and running, you'll have to declare a pubspec dependency in your Flutter project.
Also some minimal Android & iOS specific configuration must be done, otherise your app will crash.

### On your Flutter project

See the [installation instructions on pub](https://pub.dartlang.org/packages/flutter_naver_login#-installing-tab-).

### Android

This assumes that you've done the _"Associate Your Package Name and Default Class with Your App"_ and
 _"Provide the Development and Release Key Hashes for Your App"_ in the [the Facebook Login documentation for Android site](https://developers.facebook.com/docs/facebook-login/android).

After you've done that, find out what your _Facebook App ID_ is. You can find your Facebook App ID in your Facebook App's dashboard in the Facebook developer console.

Once you have the Facebook App ID figured out, youll have to do two things.

First, copy-paste the following to your strings resource file. If you don't have one, just create it.

**\<your project root\>/android/app/src/main/res/values/strings.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Your App Name here.</string>

    <!-- Replace "000000000000" with your Facebook App ID here. -->
    <string name="facebook_app_id">000000000000</string>

    <!--
      Replace "000000000000" with your Facebook App ID here.
      **NOTE**: The scheme needs to start with `fb` and then your ID.
    -->
    <string name="fb_login_protocol_scheme">fb000000000000</string>
</resources>
```

Then you'll just have to copy-paste the following to your _Android Manifest_:

**\<package root>/android/src/main/kotlin/com/example/flutter_naver_login/AndroidManifest.xml**

```kotlin
    private val OAUTH_CLIENT_ID = "OAUTH_CLIENT_ID"
    private val OAUTH_CLIENT_SECRET = "OAUTH_CLIENT_SECRET"
    private val OAUTH_CLIENT_NAME = "OAUTH_CLIENT_NAME"

```

A sample of a complete AndroidManifest file can be found [here](https://github.com/roughike/flutter_facebook_login/blob/master/example/android/app/src/main/AndroidManifest.xml#L39-L56).

Done!

### iOS

This assumes that you've done the _"Register and Configure Your App with Naver"_ step in the
[the Naver Login documentation for iOS site](https://developers.naver.com/docs/login/ios/).
(**Note**: you can skip "Step 2: Set up Your Development Environment").

After you've done that, find out what your Naver App Client ID is. You can find your Client ID, Client Secret, URL_SCHEME,  in your Naver App's dashboard in the Naver developer.

```xml
    <key>LSApplicationQueriesSchemes</key>
	<array>
		<string>naversearchapp</string>
		<string>naversearchthirdlogin</string>
	</array>

	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
		<key>NSExceptionDomains</key>
		<dict>
			<key>naver.com</key>
			<dict>
				<key>NSExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
				<key>NSIncludesSubdomains</key>
				<true/>
			</dict>
			<key>naver.net</key>
			<dict>
				<key>NSExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
				<key>NSIncludesSubdomains</key>
				<true/>
			</dict>
		</dict>
	</dict>

```


**\<package root\>ios/Pods/naveridlogin-sdk-ios/NaverThirdPartyLogin.framework/Headers/NaverThirdPartyConstantsForApp.h**

```swift

#define kServiceAppUrlScheme    @"kServiceAppUrlScheme"

#define kConsumerKey            @"kConsumerKey"
#define kConsumerSecret         @"kConsumerSecret"
#define kServiceAppName         @"kServiceAppName"

```

A sample of a complete Info.plist file can be found [here](https://github.com/roughike/flutter_facebook_login/blob/master/example/ios/Runner/Info.plist#L49-L70).

Done!

## How do I use it?

The library tries to closely match the native Android & iOS login SDK APIs where possible. For complete API documentation, just see the [source code](https://github.com/roughike/flutter_facebook_login/blob/master/lib/flutter_facebook_login.dart). Everything is documented there.

Since sample code is worth more than one page of documentation, here are the usual cases covered:

```dart
import 'package:flutter_naver_login/flutter_naver_login.dart';

NaverLoginResult res = await FlutterNaverLogin.logIn();
final NaverLoginResult result = await FlutterNaverLogin.logIn();
switch (result.status) {
    case KakaoLoginStatus.loggedIn:
    case KakaoLoginStatus.loggedOut:
    setState(() {
        isLogin = res.loginStatus.isLogin;
        accesToken = res.loginStatus.accesToken;
        tokenType = res.loginStatus.tokenType;
    });
    break;
    break;
    case KakaoLoginStatus.error:
        _updateMessage('This is Naver error message : ${result.errorMessage}');
    break;
}
```

### Getting the Naver profile of a signed in user

```dart
NaverLoginResult res = await FlutterNaverLogin.getProfile();
print(res.profileStatus.name);
setState(() {
    name = res.profileStatus.name;
});
```

The `profile` variable will now contain the following information:
  
```dart
final String nickname;
final String id;
final String name;
final String email;
final String gender;
final String age;
final String birthday;
final String profileImage;
```
