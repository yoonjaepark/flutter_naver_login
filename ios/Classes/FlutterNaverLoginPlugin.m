#import "FlutterNaverLoginPlugin.h"
#import <flutter_naver_login/flutter_naver_login-Swift.h>

@implementation FlutterNaverLoginPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNaverLoginPlugin registerWithRegistrar:registrar];
}
@end
