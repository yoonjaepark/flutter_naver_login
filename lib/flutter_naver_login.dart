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
    print(res);

    return _delayedToResult(
        new NaverLoginResult._(res.cast<String, dynamic>()));
  }

  static Future<NaverLoginResult> getToken() async {
    final Map<dynamic, dynamic> res = await _channel.invokeMethod('getToken');
    print(res);

    return _delayedToResult(
        new NaverLoginResult._(res.cast<String, dynamic>()));
  }

  static Future<T> _delayedToResult<T>(T result) {
    return new Future.delayed(const Duration(milliseconds: 100), () => result);
  }
}

enum NaverLoginStatus { loggedIn, loggedOut, getUserMe, getToken, error }

class NaverLoginResult {
  final NaverLoginStatus status;
  final NaverLoginStatusResult loginStatus;
  final NaverTokenResult tokenStatus;
  final NaverProfileResult profileStatus;
  final String errorMessage;

  NaverLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status']),
        errorMessage = map['errorMessage'],
        tokenStatus = new NaverTokenResult._(map),
        loginStatus = new NaverLoginStatusResult._(map),
        profileStatus = new NaverProfileResult._(map);

  static NaverLoginStatus _parseStatus(String status) {
    switch (status) {
      case 'loggedIn':
        return NaverLoginStatus.loggedIn;
      case 'loggedOut':
        return NaverLoginStatus.loggedOut;
      case 'getToken':
        return NaverLoginStatus.getToken;
      case 'getUserMe':
        return NaverLoginStatus.getUserMe;
    }

    throw new StateError('Invalid status: $status');
  }
}

class NaverTokenResult {
  final String accessToken;
  final String tokenType;

  NaverTokenResult._(Map<String, dynamic> map)
      : accessToken = map['accessToken'],
        tokenType = map['tokenType'];
}

class NaverLoginStatusResult {
  final String accessToken;
  final String tokenType;
  final bool isLogin;

  NaverLoginStatusResult._(Map<String, dynamic> map)
      : accessToken = map['accessToken'],
        tokenType = map['tokenType'],
        isLogin = map['isLogin'];
}

class NaverProfileResult {
  final String nickname;
  final String id;
  final String name;
  final String email;
  final String gender;
  final String age;
  final String birthday;
  final String profileImage;

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
