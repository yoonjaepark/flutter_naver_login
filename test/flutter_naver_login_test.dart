import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/flutter_naver_login_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNaverLoginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNaverLoginPlatform {
  @override
  Future<void> initSdk(
      {required String clientId,
      required String clientName,
      required String clientSecret}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> get isLoggedIn => throw UnimplementedError();

  @override
  Future<NaverLoginResult> logIn() {
    throw UnimplementedError();
  }

  @override
  Future<NaverLoginResult> logOut() {
    throw UnimplementedError();
  }

  @override
  Future<NaverLoginResult> logOutAndDeleteToken() {
    throw UnimplementedError();
  }

  @override
  Future<NaverAccountResult> currentAccount() {
    throw UnimplementedError();
  }

  @override
  Future<NaverAccessToken> get currentAccessToken => throw UnimplementedError();

  @override
  Future<NaverAccessToken> refreshAccessTokenWithRefreshToken() {
    throw UnimplementedError();
  }
}

void main() {
  final FlutterNaverLoginPlatform initialPlatform =
      FlutterNaverLoginPlatform.instance;

  test('$MethodChannelFlutterNaverLogin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNaverLogin>());
  });

  test('getPlatformVersion', () async {
    MockFlutterNaverLoginPlatform fakePlatform =
        MockFlutterNaverLoginPlatform();
    FlutterNaverLoginPlatform.instance = fakePlatform;
  });
}
