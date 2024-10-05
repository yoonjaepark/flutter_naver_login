import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_naver_login/interface/flutter_naver_login_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterNaverLogin platform = MethodChannelFlutterNaverLogin();
  const MethodChannel channel = MethodChannel('flutter_naver_login');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return true;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(
        await platform.initSdk(
            clientId: 'clientId',
            clientName: 'clientName',
            clientSecret: 'clientSecret'),
        true);
  });
}
