/// flutter_naver_login_method_channel.dart
///
/// 네이버 로그인의 플랫폼 특화 구현을 제공하는 파일입니다.
/// MethodChannel을 통해 네이티브 코드와 통신하는 구현체를 정의합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_naver_login_platform_interface.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

/// [FlutterNaverLoginPlatform]을 구현하는 클래스로, MethodChannel을 사용하여 네이티브 코드와 통신합니다.
class MethodChannelFlutterNaverLogin extends FlutterNaverLoginPlatform {
  /// 네이티브 플랫폼과 통신하기 위한 MethodChannel
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_naver_login');

  @override
  Future<void> initSdk({
    required String clientId,
    required String clientName,
    required String clientSecret,
    String loginBehavior = 'web',
  }) async {
    try {
      await methodChannel.invokeMethod('initSdk', {
        'clientId': clientId,
        'clientName': clientName,
        'clientSecret': clientSecret,
        'loginBehavior': loginBehavior,
      });
    } on PlatformException catch (e) {
      print("Platform exception: ${e.message}");
      throw Exception(e.message);
    }
  }

  /// 네이버 로그인을 수행하는 메서드
  @override
  Future<NaverLoginResult> logIn() async {
    try {
      final raw = await methodChannel.invokeMethod('logIn');
      if (raw == null) {
        return NaverLoginResult(
          status: NaverLoginStatus.error,
          errorMessage: 'Login failed: No result returned',
        );
      }

      final result = Map<String, dynamic>.from(raw);

      final status = result['status'] as String?;
      if (status == 'error') {
        return NaverLoginResult(
          status: NaverLoginStatus.error,
          errorMessage: result['errorMessage'],
        );
      }

      return NaverLoginResult.fromMap(result);
    } on PlatformException catch (e) {
      print("🔥 Platform exception during login: ${e.message}");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      print("🔥 Unexpected error during login: $e");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 네이버 로그아웃을 수행하는 메서드
  @override
  Future<NaverLoginResult> logOut() async {
    try {
      print("🔥 Starting logout process");
      final result = await methodChannel.invokeMethod('logOut');
      print("🔥 Logout result: $result");

      if (result == null) {
        print("🔥 Logout returned null");
        return NaverLoginResult(
          status: NaverLoginStatus.error,
          errorMessage: 'Logout failed: No result returned',
        );
      }

      if (result is Map) {
        final map = Map<String, dynamic>.from(result);
        if (map['status'] == 'error') {
          print("🔥 Logout error: ${map['errorMessage']}");
          return NaverLoginResult(
            status: NaverLoginStatus.error,
            errorMessage: map['errorMessage'],
          );
        }
      }

      return NaverLoginResult(status: NaverLoginStatus.loggedOut);
    } on PlatformException catch (e) {
      print("🔥 Platform exception during logout: ${e.message}");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      print("🔥 Unexpected error during logout: $e");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 네이버 로그아웃 및 토큰 삭제를 수행하는 메서드
  @override
  Future<NaverLoginResult> logOutAndDeleteToken() async {
    try {
      print("🔥 Starting logout and token deletion");
      final result = await methodChannel.invokeMethod('logOutAndDeleteToken');
      print("🔥 Logout and token deletion result: $result");

      if (result == null) {
        print("🔥 Logout and token deletion returned null");
        return NaverLoginResult(
          status: NaverLoginStatus.error,
          errorMessage: 'Logout and token deletion failed: No result returned',
        );
      }

      if (result is Map) {
        final map = Map<String, dynamic>.from(result);
        if (map['status'] == 'error') {
          print("🔥 Logout and token deletion error: ${map['errorMessage']}");
          return NaverLoginResult(
            status: NaverLoginStatus.error,
            errorMessage: map['errorMessage'],
          );
        }
      }

      return NaverLoginResult(status: NaverLoginStatus.loggedOut);
    } on PlatformException catch (e) {
      print(
        "Platform exception during logout and token deletion: ${e.message}",
      );
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      print("Unexpected error during logout and token deletion: $e");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 현재 로그인된 네이버 계정 정보를 조회하는 메서드
  @override
  Future<NaverLoginResult> getCurrentAccount() async {
    try {
      final result = await methodChannel.invokeMethod<Map>('getCurrentAccount');

      if (result == null) {
        print("No account info returned");
        return NaverLoginResult(status: NaverLoginStatus.loggedOut);
      }

      final status = result['status'] as String?;
      if (status == 'error') {
        print("Get account error: ${result['errorMessage']}");
        return NaverLoginResult(
          status: NaverLoginStatus.error,
          errorMessage: result['errorMessage'],
        );
      }

      if (status == 'loggedOut') {
        print("User is logged out");
        return NaverLoginResult(status: NaverLoginStatus.loggedOut);
      }

      return NaverLoginResult(
        status: NaverLoginStatus.loggedIn,
        account: NaverLoginResult.fromMap(result).account,
      );
    } on PlatformException catch (e) {
      print("Platform exception getting account: ${e.message}");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      print("Unexpected error getting account: $e");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 현재 로그인 상태를 확인하는 메서드
  @override
  Future<bool> isLoggedIn() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isLoggedIn');
      return result ?? false;
    } on PlatformException catch (e) {
      print("Platform exception checking login status: ${e.message}");
      return false;
    } catch (e) {
      print("Unexpected error checking login status: $e");
      return false;
    }
  }

  /// 현재 액세스 토큰 정보를 조회하는 메서드
  @override
  Future<NaverLoginResult> getCurrentAccessToken() async {
    try {
      final result = await methodChannel.invokeMethod<Map>(
        'getCurrentAccessToken',
      );
      if (result == null) {
        return NaverLoginResult(status: NaverLoginStatus.loggedOut);
      }

      // status 체크 추가
      final status = result['status'] as String?;
      if (status == 'loggedOut') {
        return NaverLoginResult(status: NaverLoginStatus.loggedOut);
      }

      if (status == 'error') {
        return NaverLoginResult(
          status: NaverLoginStatus.error,
          errorMessage: result['errorMessage'],
        );
      }

      // loggedIn 상태일 때만 accessToken 처리
      if (status == 'loggedIn') {
        return NaverLoginResult(
          status: NaverLoginStatus.loggedIn,
          accessToken: NaverLoginResult.fromMap(result).accessToken,
        );
      }

      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: 'Unexpected status: $status',
      );
    } on PlatformException catch (e) {
      print("Platform exception: ${e.message}");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      print("Unexpected error: $e");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 리프레시 토큰을 사용하여 액세스 토큰을 갱신하는 메서드
  @override
  Future<NaverLoginResult> refreshAccessTokenWithRefreshToken() async {
    try {
      final result = await methodChannel.invokeMethod<Map>(
        'refreshAccessTokenWithRefreshToken',
      );
      if (result == null) {
        print("No result returned from token refresh");
        return NaverLoginResult(
          status: NaverLoginStatus.error,
          errorMessage: 'Token refresh failed: No result returned',
        );
      }

      final status = result['status'] as String?;
      if (status == 'error') {
        print("Token refresh error: ${result['errorMessage']}");
        return NaverLoginResult(
          status: NaverLoginStatus.error,
          errorMessage: result['errorMessage'],
        );
      }

      return NaverLoginResult.fromMap(result);
    } on PlatformException catch (e) {
      print("Platform exception refreshing token: ${e.message}");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      print("Unexpected error refreshing token: $e");
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
