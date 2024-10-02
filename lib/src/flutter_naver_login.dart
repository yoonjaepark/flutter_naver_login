import 'package:flutter_naver_login/interface/flutter_naver_login_platform_interface.dart';
import 'package:flutter_naver_login/interface/types/naver_access_token.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';

class FlutterNaverLogin {
  FlutterNaverLogin._();

  static Future<void> initSdk({
    required String clientId,
    required String clientName,
    required String clientSecret,
  }) =>
      FlutterNaverLoginPlatform.instance.initSdk(
        clientId: clientId,
        clientName: clientName,
        clientSecret: clientSecret,
      );

  static Future<bool> get isLoggedIn =>
      FlutterNaverLoginPlatform.instance.isLoggedIn;

  static Future<NaverLoginResult> logIn() => FlutterNaverLoginPlatform.instance.logIn();

  static Future<NaverLoginResult> logOut() => FlutterNaverLoginPlatform.instance.logOut();

  static Future<NaverLoginResult> logOutAndDeleteToken() =>
      FlutterNaverLoginPlatform.instance.logOutAndDeleteToken();

  static Future<NaverAccountResult> currentAccount() =>
      FlutterNaverLoginPlatform.instance.currentAccount();

  static Future<NaverAccessToken> get currentAccessToken =>
      FlutterNaverLoginPlatform.instance.currentAccessToken;

  static Future<NaverAccessToken> refreshAccessTokenWithRefreshToken() =>
      FlutterNaverLoginPlatform.instance.refreshAccessTokenWithRefreshToken();
}
