import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/interface/types/channel_method.dart';
import 'package:flutter_naver_login/interface/types/naver_access_token.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';

import 'flutter_naver_login_platform_interface.dart';

/// An implementation of [FlutterNaverLoginPlatform] that uses method channels.
class MethodChannelFlutterNaverLogin extends FlutterNaverLoginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_naver_login');

  @override
  Future<bool?> initSdk({
    required String clientId,
    required String clientName,
    required String clientSecret,
  }) async {
    final arguments = {
      'clientId': clientId,
      'clientName': clientName,
      'clientSecret': clientSecret,
    };

    debugPrint('[FlutterNaverLogin] initSdk');

    return await methodChannel.invokeMethod<bool>("initSdk", arguments);
  }

  @override
  Future<NaverLoginResult> logIn() async {
    final Map<dynamic, dynamic> res =
        await methodChannel.invokeMethod(FlutterPluginMethod.logIn.method);

    return _delayedToResult(
        NaverLoginResult.fromMap(res.cast<String, dynamic>()));
  }

  @override
  Future<NaverLoginResult> logOut() async {
    final Map<dynamic, dynamic> res =
        await methodChannel.invokeMethod(FlutterPluginMethod.logOut.method);

    return _delayedToResult(
        NaverLoginResult.fromMap(res.cast<String, dynamic>()));
  }

  @override
  Future<NaverLoginResult> logOutAndDeleteToken() async {
    final Map<dynamic, dynamic> res = await methodChannel
        .invokeMethod(FlutterPluginMethod.logOutAndDeleteToken.method);

    return _delayedToResult(
        NaverLoginResult.fromMap(res.cast<String, dynamic>()));
  }

  @override
  Future<bool> get isLoggedIn async {
    if ((await currentAccessToken).isValid()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<NaverAccountResult> currentAccount() async {
    final Map<dynamic, dynamic> res = await methodChannel
        .invokeMethod(FlutterPluginMethod.currentAccount.method);

    return _delayedToResult(
        NaverAccountResult.fromMap(res.cast<String, dynamic>()));
  }

  @override
  Future<NaverAccessToken> get currentAccessToken async {
    final Map<dynamic, dynamic>? accessToken = await methodChannel
        .invokeMethod(FlutterPluginMethod.currentAccessToken.method);

    if (accessToken == null) {
      return NaverAccessToken.empty();
    } else {
      return _delayedToResult(
          NaverAccessToken.fromMap(accessToken.cast<String, dynamic>()));
    }
  }

  @override
  Future<NaverAccessToken> refreshAccessTokenWithRefreshToken() async {
    final accessToken = await currentAccessToken;
    if (accessToken.refreshToken.isNotEmpty &&
        accessToken.refreshToken != 'no token') {
      await methodChannel.invokeMethod(
          FlutterPluginMethod.refreshAccessTokenWithRefreshToken.method);
    }
    return (await currentAccessToken);
  }

  static Future<T> _delayedToResult<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 100), () => result);
  }
}
