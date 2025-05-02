import 'package:flutter_naver_login/flutter_naver_login_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_access_token.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/flutter_naver_login_method_channel.dart';

class MockFlutterNaverLoginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNaverLoginPlatform {
  @override
  Future<void> initSdk({
    required String clientId,
    required String clientName,
    required String clientSecret,
  }) async {
    // Mock implementation
  }

  @override
  Future<bool> isLoggedIn() async {
    return true;
  }

  @override
  Future<NaverLoginResult> logIn() async {
    return NaverLoginResult(
      status: NaverLoginStatus.loggedIn,
      accessToken: NaverAccessToken(
        accessToken: 'mockAccessToken',
        refreshToken: 'mockRefreshToken',
        expiresAt: DateTime.now().add(Duration(days: 1)).toIso8601String(),
        tokenType: 'bearer',
      ),
      account: NaverAccountResult(nickname: 'mockUser'),
    );
  }

  @override
  Future<NaverLoginResult> logOut() async {
    return NaverLoginResult(status: NaverLoginStatus.loggedOut);
  }

  @override
  Future<NaverLoginResult> logOutAndDeleteToken() async {
    return NaverLoginResult(status: NaverLoginStatus.loggedOut);
  }

  @override
  Future<NaverLoginResult> getCurrentAccount() async {
    return NaverLoginResult(
      status: NaverLoginStatus.loggedIn,
      account: NaverAccountResult(nickname: 'mockUser'),
    );
  }

  @override
  Future<NaverLoginResult> getCurrentAccessToken() async {
    return NaverLoginResult(
      status: NaverLoginStatus.loggedIn,
      accessToken: NaverAccessToken(
        accessToken: 'mockAccessToken',
        refreshToken: 'mockRefreshToken',
        expiresAt: DateTime.now().add(Duration(days: 1)).toIso8601String(),
        tokenType: 'bearer',
      ),
    );
  }

  @override
  Future<NaverLoginResult> refreshAccessTokenWithRefreshToken() async {
    return NaverLoginResult(
      status: NaverLoginStatus.loggedIn,
      accessToken: NaverAccessToken(
        accessToken: 'newMockAccessToken',
        refreshToken: 'newMockRefreshToken',
        expiresAt: DateTime.now().add(Duration(days: 1)).toIso8601String(),
        tokenType: 'bearer',
      ),
    );
  }
}

void main() {
  final FlutterNaverLoginPlatform initialPlatform =
      FlutterNaverLoginPlatform.instance;

  test('$MethodChannelFlutterNaverLogin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNaverLogin>());
  });

  test('logIn', () async {
    MockFlutterNaverLoginPlatform fakePlatform =
        MockFlutterNaverLoginPlatform();
    FlutterNaverLoginPlatform.instance = fakePlatform;

    final result = await fakePlatform.logIn();
    expect(result.status, NaverLoginStatus.loggedIn);
    expect(result.accessToken?.accessToken, 'mockAccessToken');
  });

  test('currentAccessToken', () async {
    MockFlutterNaverLoginPlatform fakePlatform =
        MockFlutterNaverLoginPlatform();
    FlutterNaverLoginPlatform.instance = fakePlatform;

    final result = await fakePlatform.getCurrentAccessToken();
    expect(result.status, NaverLoginStatus.loggedIn);
    expect(result.accessToken?.accessToken, 'mockAccessToken');
  });

  test('logOut', () async {
    MockFlutterNaverLoginPlatform fakePlatform =
        MockFlutterNaverLoginPlatform();
    FlutterNaverLoginPlatform.instance = fakePlatform;

    final result = await fakePlatform.logOut();
    expect(result.status, NaverLoginStatus.loggedOut);
  });

  // Add more tests for other methods as needed
}
