import 'dart:async';

import 'package:flutter/services.dart';

class FlutterNaverLogin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_naver_login');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<NaverLoginResult> logIn() async {
    final Map<dynamic, dynamic> res = await _channel.invokeMethod('logIn');
    print(res);
    return _delayedToResult(
        new NaverLoginResult._(res.cast<String, dynamic>()));
  }

  static Future<NaverLoginResult> logOut() async {
    final Map<dynamic, dynamic> res = await _channel.invokeMethod('logOut');

    return _delayedToResult(
        new NaverLoginResult._(res.cast<String, dynamic>()));
  }

  static Future<NaverLoginResult> getProfile() async {
    final Map<dynamic, dynamic> res = await _channel.invokeMethod('getUserMe');
    print('########');
    print(res);
    return _delayedToResult(
        new NaverLoginResult._(res.cast<String, dynamic>()));
  }

  static Future<T> _delayedToResult<T>(T result) {
    return new Future.delayed(const Duration(milliseconds: 100), () => result);
  }
}

enum NaverLoginStatus { loggedIn, loggedOut, getUserMe, error }

class NaverLoginResult {
  final NaverLoginStatus status;

  final NaverTokenResult token;
  final NaverProfileResult profile;
  final String errorMessage;

  NaverLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status']),
        errorMessage = map['errorMessage'],
        token = new NaverTokenResult._(map),
        profile = new NaverProfileResult._(map);

  static NaverLoginStatus _parseStatus(String status) {
    switch (status) {
      case 'loggedIn':
        return NaverLoginStatus.loggedIn;
      case 'loggedOut':
        return NaverLoginStatus.loggedOut;
      case 'getUserMe':
        return NaverLoginStatus.getUserMe;
      case 'error':
        return NaverLoginStatus.error;
    }

    throw new StateError('Invalid status: $status');
  }
}

class NaverTokenResult {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  NaverTokenResult._(Map<String, dynamic> map)
      : accessToken = map['accessToken'],
        refreshToken = map['refreshToken'],
        tokenType = map['tokenType'];
}

class NaverProfileResult {
  // final String resultcode;
  // final String message;
  final String nickname;
  final String id;
  final String name;
  final String email;
  final String gender;
  final String age;
  final String birthday;
  final String profileImage;
  // : resultcode = map['resultcode'],
// message = map['message'],
  NaverProfileResult._(Map<String, dynamic> map)
      : nickname = map['nickname'],
        id = map['id'],
        name = map['name'],
        email = map['email'],
        gender = map['gender'],
        age = map['age'],
        birthday = map['birthday'],
        profileImage = map['profile_image'];
}

// class KakaoAccessToken {
//   String token;

//   KakaoAccessToken(this.token);
// }
