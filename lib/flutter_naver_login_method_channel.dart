/// flutter_naver_login_method_channel.dart
///
/// 네이버 로그인의 플랫폼 특화 구현을 제공하는 파일입니다.
/// MethodChannel을 통해 네이티브 코드와 통신하는 구현체를 정의합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';

import 'flutter_naver_login_platform_interface.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

/// [FlutterNaverLoginPlatform]을 구현하는 클래스로, MethodChannel을 사용하여 네이티브 코드와 통신합니다.
class MethodChannelFlutterNaverLogin extends FlutterNaverLoginPlatform {
  /// 네이티브 플랫폼과 통신하기 위한 MethodChannel
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_naver_login');

  /// 네이버 로그인을 수행하는 메서드
  @override
  Future<NaverLoginResult> logIn() async {
    try {
      final raw = await methodChannel.invokeMethod('logIn');
      final result = Map<String, dynamic>.from(raw);
      return NaverLoginResult.fromMap(result);
    } on PlatformException catch (e) {
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    }
  }

  /// 네이버 로그아웃을 수행하는 메서드
  @override
  Future<NaverLoginResult> logOut() async {
    try {
      await methodChannel.invokeMethod('logOut');
      return NaverLoginResult(status: NaverLoginStatus.loggedOut);
    } on PlatformException catch (e) {
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    }
  }

  /// 네이버 로그아웃 및 토큰 삭제를 수행하는 메서드
  @override
  Future<NaverLoginResult> logOutAndDeleteToken() async {
    try {
      await methodChannel.invokeMethod('logoutAndDeleteToken');
      return NaverLoginResult(status: NaverLoginStatus.loggedOut);
    } on PlatformException catch (e) {
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    }
  }

  /// 현재 로그인된 네이버 계정 정보를 조회하는 메서드
  @override
  Future<NaverAccountResult> getCurrentAccount() async {
    try {
      final result = await methodChannel.invokeMethod<Map>('getCurrentAccount');
      if (result == null) {
        return NaverAccountResult();
      }
      return NaverAccountResult.fromMap(
        result['account'] is Map
            ? Map<String, dynamic>.from(result['account'])
            : {},
      );
    } on PlatformException {
      return NaverAccountResult();
    }
  }

  /// 현재 로그인 상태를 확인하는 메서드
  @override
  Future<bool> isLoggedIn() async {
    final result = await methodChannel.invokeMethod<bool>('isLoggedIn');
    return result ?? false;
  }

  /// 현재 액세스 토큰 정보를 조회하는 메서드
  @override
  Future<NaverToken> getCurrentAccessToken() async {
    try {
      final result = await methodChannel.invokeMethod<Map>(
        'getCurrentAccessToken',
      );
      if (result == null) {
        return NaverToken.empty();
      }
      // 여기서 내부 accessToken만 넘겨야 함!
      final accessTokenMap = result['accessToken'];
      if (accessTokenMap is Map) {
        return NaverToken.fromMap(
          Map<String, dynamic>.from(accessTokenMap),
        );
      } else {
        return NaverToken.empty();
      }
    } on PlatformException {
      return NaverToken.empty();
    }
  }

  /// 리프레시 토큰을 사용하여 액세스 토큰을 갱신하는 메서드
  @override
  Future<NaverToken> refreshAccessTokenWithRefreshToken() async {
    try {
      final result = await methodChannel.invokeMethod<Map>(
        'refreshAccessTokenWithRefreshToken',
      );
      if (result == null) {
        return NaverToken.empty();
      }
      return NaverToken.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException {
      return NaverToken.empty();
    }
  }
}
