/// flutter_naver_login_platform_interface.dart
///
/// 네이버 로그인 SDK의 플랫폼 인터페이스를 정의하는 파일입니다.
/// 이 파일은 플랫폼별 구현의 기본 인터페이스를 제공합니다.
///
/// 주요 기능:
/// - 네이버 로그인/로그아웃
/// - 사용자 정보 조회
/// - 액세스 토큰 관리
/// - 토큰 갱신
///
/// 사용 예시:
/// ```dart
/// // 로그인
/// final result = await FlutterNaverLogin.logIn();
///
/// // 사용자 정보 조회
/// final account = await FlutterNaverLogin.currentAccount();
/// ```
library;

import 'package:flutter_naver_login/flutter_naver_login_method_channel.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';

/// 네이버 로그인 기능을 제공하는 주요 클래스
///
/// 이 클래스는 네이버 로그인 SDK와의 인터페이스를 제공하며,
/// Flutter 앱에서 네이버 로그인 기능을 쉽게 사용할 수 있도록 합니다.
///
/// 주요 기능:
/// - 로그인/로그아웃
/// - 사용자 정보 조회
/// - 토큰 관리
/// - 토큰 갱신
abstract class FlutterNaverLoginPlatform extends PlatformInterface {
  FlutterNaverLoginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNaverLoginPlatform _instance = MethodChannelFlutterNaverLogin();

  static FlutterNaverLoginPlatform get instance => _instance;

  static set instance(FlutterNaverLoginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 네이버 로그인을 수행합니다.
  Future<NaverLoginResult> logIn();

  /// 네이버 로그아웃을 수행합니다.
  Future<NaverLoginResult> logOut();

  /// 네이버 로그아웃 및 토큰 삭제를 수행합니다.
  Future<NaverLoginResult> logOutAndDeleteToken();

  /// 현재 로그인된 사용자의 계정 정보를 조회합니다.
  Future<NaverAccountResult> getCurrentAccount();

  /// 현재 액세스 토큰 정보를 조회합니다.
  Future<NaverToken> getCurrentAccessToken();

  /// 리프레시 토큰을 사용하여 액세스 토큰을 갱신합니다.
  Future<NaverToken> refreshAccessTokenWithRefreshToken();

  /// 현재 로그인 상태를 확인합니다.
  Future<bool> isLoggedIn() async {
    final result = await getCurrentAccessToken();
    return result.isValid();
  }
}
