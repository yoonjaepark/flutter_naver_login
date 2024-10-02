import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/flutter_naver_login_platform_interface.dart';
import 'package:flutter_naver_login/flutter_naver_login_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNaverLoginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNaverLoginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterNaverLoginPlatform initialPlatform = FlutterNaverLoginPlatform.instance;

  test('$MethodChannelFlutterNaverLogin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNaverLogin>());
  });

  test('getPlatformVersion', () async {
    FlutterNaverLogin flutterNaverLoginPlugin = FlutterNaverLogin();
    MockFlutterNaverLoginPlatform fakePlatform = MockFlutterNaverLoginPlatform();
    FlutterNaverLoginPlatform.instance = fakePlatform;

    expect(await flutterNaverLoginPlugin.getPlatformVersion(), '42');
  });
}
