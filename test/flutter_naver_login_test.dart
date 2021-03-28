import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_naver_login');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {});
}
