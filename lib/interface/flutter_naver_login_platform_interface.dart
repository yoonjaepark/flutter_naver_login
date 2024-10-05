import 'package:flutter_naver_login/interface/types/naver_access_token.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/flutter_naver_login_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterNaverLoginPlatform extends PlatformInterface {
  /// Constructs a FlutterNaverLoginPlatform.
  FlutterNaverLoginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNaverLoginPlatform _instance = MethodChannelFlutterNaverLogin();

  /// The default instance of [FlutterNaverLoginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNaverLogin].
  static FlutterNaverLoginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNaverLoginPlatform] when
  /// they register themselves.
  static set instance(FlutterNaverLoginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initSdk({
    required String clientId,
    required String clientName,
    required String clientSecret,
  }) {
    throw UnimplementedError();
  }

  Future<bool> get isLoggedIn {
    throw UnimplementedError();
  }

  Future<NaverLoginResult> logIn() {
    throw UnimplementedError();
  }

  Future<NaverLoginResult> logOut() {
    throw UnimplementedError();
  }

  Future<NaverLoginResult> logOutAndDeleteToken() {
    throw UnimplementedError();
  }

  Future<NaverAccountResult> currentAccount() {
    throw UnimplementedError();
  }

  Future<NaverAccessToken> get currentAccessToken {
    throw UnimplementedError();
  }

  Future<NaverAccessToken> refreshAccessTokenWithRefreshToken() {
    throw UnimplementedError();
  }
}
