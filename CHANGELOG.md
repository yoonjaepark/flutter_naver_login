## 2.0.0
* Upgrade flutter plugin template to latest
  * Add iOS PrivacyInfo.xcprivacy
  * Migrate to Swift
  * Support Xcode 16
  * Update min iOS version to 12 which is [Flutter supported minimum iOS version](https://docs.flutter.dev/deployment/ios#review-xcode-project-settings)
* Upgrade naver ios sdk to 4.2.3
  * [Changelog](https://github.com/naver/naveridlogin-sdk-ios/releases)
  * Fix [Xcode 16 error](https://developers.naver.com/forum/posts/36188)
* Upgrade naver android sdk to 5.10.0
  * [Changelog](https://github.com/naver/naveridlogin-sdk-android/releases)
  * Update target sdk version to 34

## 1.9.0
* update naver sdk 5.9.0
* remove naver sdk aar file, and get it from maven
* support proguard
* add workaround android device back button on FlutterFragmentActivity [flutter/#117061](https://github.com/flutter/flutter/issues/117061)
* migrate example to [AGP declarative plugins block](https://docs.flutter.dev/release/breaking-changes/flutter-gradle-plugin-apply)

## 1.8.0
* naver sdk 5.4.0
* fix issues

## 1.7.0
* naver sdk 5.2.0
* android kotlinX dependencies 

## 1.6.0
* Add User Information (mobile, birthyear, mobileE164)

## 1.5.0
* refreshAccessTokenWithRefreshToken method
* add ios expiresAt

## 1.4.0
* ios guide reademe update

## 1.3.1
* minor bugfix

## 1.3.0
* naver login sdk 5.0.1 Update
* example update

## 1.2.4
* Added logOutAndDeleteToken method instead of logout
* ios prefix k to naver
* remove ios http allow info

## 1.2.3
* refreshToken
* example ios build error fix

## 1.2.2

* null type Exception
* android naver sdk 4.2.6 update
* naverLoginResult.status error code update

## 1.2.1

* flutter 2.0.3 migration, update to null safety

## 1.2.0

* flutter 1.12 migration

## 1.1.1

* readme update

## 1.1.0

* build.gradle update
* readme update
* android logout fix

## 1.0.1

* ios13 background error fix

## 1.0.0

* ios13 pod version update

## 0.3.4

* Readme.md

## 0.3.3

* ios Naver App login enable

## 0.3.2

* ios Naver App login disable

## 0.3.1

* Android Login Cancle error fix

## 0.3.0

* migrate to AndroidX

## 0.2.1

* Readme.md

## 0.2.0

* ios issue add Readme.md

## 0.1.3

* ios swift to object-c

## 0.1.2

* ios build issue list add readme.md

## 0.1.1

* pod spec change.

## 0.1.0

* ios swift5 support.
* readme add for ios cocoapods.
* ios dependency Alamofire (5.0.0-beta.6) vesion update

## 0.0.1

* Initial release.
