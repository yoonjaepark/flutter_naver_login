#import <Flutter/Flutter.h>
#import <NaverThirdPartyLogin/NaverThirdPartyLogin.h>

@interface FlutterNaverLoginPlugin : NSObject<FlutterPlugin>
{
    NaverThirdPartyLoginConnection *_thirdPartyLoginConn;
    FlutterResult _naverResult;
}
@end
