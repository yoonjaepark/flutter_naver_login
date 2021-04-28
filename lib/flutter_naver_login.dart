import 'dart:async';

import 'package:flutter/services.dart';
import 'src/clock.dart';

class FlutterNaverLogin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_naver_login');

  static Future<NaverLoginResult> logIn() async {
    final Map<dynamic, dynamic> res = await _channel.invokeMethod('logIn');

    return _delayedToResult(
        new NaverLoginResult._(res.cast<String, dynamic>()));
  }

  static Future<NaverLoginResult> logOut() async {
    final Map<dynamic, dynamic> res = await _channel.invokeMethod('logOut');

    return _delayedToResult(
        new NaverLoginResult._(res.cast<String, dynamic>()));
  }

  static Future<bool> get isLoggedIn async {
    if ((await currentAccessToken).isValid())
      return true;
    else
      return false;
  }

  static Future<NaverAccountResult> currentAccount() async {
    final Map<dynamic, dynamic> res =
        await _channel.invokeMethod('getCurrentAcount');

    return _delayedToResult(
        new NaverAccountResult._(res.cast<String, dynamic>()));
  }

  static Future<NaverAccessToken> get currentAccessToken async {
    final Map<dynamic, dynamic>? accessToken =
        await _channel.invokeMethod('getCurrentAccessToken');

    if (accessToken == null)
      return NaverAccessToken._(noToken);
    else
      return _delayedToResult(
          NaverAccessToken._(accessToken.cast<String, dynamic>()));
  }

  static Future<T> _delayedToResult<T>(T result) {
    return new Future.delayed(const Duration(milliseconds: 100), () => result);
  }
}

enum NaverLoginStatus { loggedIn, cancelledByUser, error }

class NaverLoginResult {
  final NaverLoginStatus status;
  final NaverAccountResult account;
  final String errorMessage;
  final NaverAccessToken accessToken;

  NaverLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status'] ?? ''),
        accessToken = NaverAccessToken._(map),
        errorMessage = map['errorMessage'] ?? '',
        account = new NaverAccountResult._(map);

  static NaverLoginStatus _parseStatus(String status) {
    switch (status) {
      case 'loggedIn':
        return NaverLoginStatus.loggedIn;
      case 'cancelledByUser':
        return NaverLoginStatus.cancelledByUser;
      case 'error':
        return NaverLoginStatus.error;
    }
    throw new StateError('Invalid status: $status');
  }

  @override
  String toString() =>
      '{ status: $status, account: $account, errorMessage: $errorMessage, accessToken: $accessToken }';
}

class NaverAccessToken {
  final String accessToken;
  final String expiresAt;
  final String tokenType;
  bool isValid() {
    bool timeValid = Clock.now().isBefore(DateTime.parse(expiresAt));
    bool tokenExist = accessToken != 'no token';
    return timeValid && tokenExist;
  }

  NaverAccessToken._(Map<String, dynamic> map)
      : accessToken = map['accessToken'] ?? '',
        expiresAt = map['expiresAt'] ?? '',
        tokenType = map['tokenType'] ?? '';

  @override
  String toString() =>
      '{ accessToken: $accessToken, expiresAt: $expiresAt, tokenType: $tokenType }';
}

class NaverAccountResult {
  final String nickname;
  final String id;
  final String name;
  final String email;
  final String gender;
  final String age;
  final String birthday;
  final String profileImage;

  NaverAccountResult._(Map<String, dynamic> map)
      : nickname = map['nickname'] ?? '',
        id = map['id'] ?? '',
        name = map['name'] ?? '',
        email = map['email'] ?? '',
        gender = map['gender'] ?? '',
        age = map['age'] ?? '',
        birthday = map['birthday'] ?? '',
        profileImage = map['profile_image'] ?? '';

  @override
  String toString() {
    return '{ '
        'nickname: $nickname, '
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'gender: $gender, '
        'age: $age, '
        'birthday: $birthday, '
        'profileImage: $profileImage'
        ' }';
  }
}

Map<String, dynamic> noToken = {
  'accessToken': 'no token',
  'expiresAt': 'no token',
  'tokenType': 'no token',
};
