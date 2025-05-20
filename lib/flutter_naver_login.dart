import 'package:flutter/services.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'flutter_naver_login_platform_interface.dart';

/// 플러그인에서 사용할 메서드를 나타내는 열거형
enum FlutterPluginMethod {
  logIn('logIn'), // 로그인 메서드
  logOut('logOut'), // 로그아웃 메서드
  logOutAndDeleteToken('logoutAndDeleteToken'), // 로그아웃 및 토큰 삭제 메서드
  currentAccount('getCurrentAccount'), // 현재 계정 정보 가져오기 메서드
  currentAccessToken('getCurrentAccessToken'), // 현재 액세스 토큰 가져오기 메서드
  refreshAccessTokenWithRefreshToken(
    'refreshAccessTokenWithRefreshToken',
  ) // 리프레시 토큰으로 액세스 토큰 갱신 메서드
  ;

  /// 메서드 이름을 문자열로 저장
  final String method;

  /// 각 열거형 값에 문자열을 연결하는 생성자
  const FlutterPluginMethod(this.method);
}

/// 네이버 로그인 기능을 제공하는 클래스
/// 이 클래스는 네이버 로그인 SDK와의 인터페이스를 제공합니다.
class FlutterNaverLogin {
  /// 네이티브 플랫폼과 통신하기 위한 메서드 채널
  static const MethodChannel channel = MethodChannel('flutter_naver_login');

  /// 네이버 로그인을 수행합니다.
  ///
  /// 성공 시 [NaverLoginResult]를 반환하며, 이는 로그인 상태와 사용자 정보를 포함합니다.
  /// 실패 시 에러 메시지가 포함된 [NaverLoginResult]를 반환합니다.
  static Future<NaverLoginResult> logIn() {
    return FlutterNaverLoginPlatform.instance.logIn();
  }

  /// 네이버 로그아웃을 수행합니다.
  ///
  /// 현재 로그인된 계정에서 로그아웃합니다.
  /// 성공 또는 실패 여부를 [NaverLoginResult]로 반환합니다.
  static Future<NaverLoginResult> logOut() {
    return FlutterNaverLoginPlatform.instance.logOut();
  }

  /// 네이버 로그아웃을 수행하고 저장된 토큰을 삭제합니다.
  ///
  /// 로그아웃 후 저장된 모든 인증 정보를 삭제합니다.
  /// 성공 또는 실패 여부를 [NaverLoginResult]로 반환합니다.
  static Future<NaverLoginResult> logOutAndDeleteToken() {
    return FlutterNaverLoginPlatform.instance.logOutAndDeleteToken();
  }

  /// 현재 로그인된 네이버 계정 정보를 가져옵니다.
  ///
  /// 반환값은 [NaverLoginResult]로, 사용자의 프로필 정보를 포함합니다.
  /// 로그인되지 않은 경우 적절한 상태값을 가진 [NaverLoginResult]를 반환합니다.
  static Future<NaverAccountResult> getCurrentAccount() {
    return FlutterNaverLoginPlatform.instance.getCurrentAccount();
  }

  /// 현재 네이버 로그인 상태를 확인합니다.
  ///
  /// 반환값이 true이면 로그인된 상태, false이면 로그아웃된 상태입니다.
  static Future<bool> isLoggedIn() {
    return FlutterNaverLoginPlatform.instance.isLoggedIn();
  }

  /// 현재 액세스 토큰 정보를 가져옵니다.
  ///
  /// 반환값은 [NaverToken]로, 토큰 관련 정보를 포함합니다.
  /// 유효한 토큰이 없는 경우 적절한 상태값을 가진 [NaverToken]을 반환합니다.
  static Future<NaverToken> getCurrentAccessToken() {
    return FlutterNaverLoginPlatform.instance.getCurrentAccessToken();
  }

  /// 리프레시 토큰을 사용하여 액세스 토큰을 갱신합니다.
  ///
  /// 액세스 토큰이 만료된 경우 이 메서드를 사용하여 새로운 액세스 토큰을 발급받을 수 있습니다.
  /// 반환값은 [NaverToken]로, 갱신된 토큰 정보를 포함합니다.
  static Future<NaverToken> refreshAccessTokenWithRefreshToken() {
    return FlutterNaverLoginPlatform.instance
        .refreshAccessTokenWithRefreshToken();
  }
}
