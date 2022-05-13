#import "FlutterNaverLoginPlugin.h"
#import <NaverThirdPartyLogin/NaverThirdPartyLogin.h>
#import <SafariServices/SafariServices.h>

@implementation FlutterNaverLoginPlugin
- (id)init {
    if ((self = [super init])) {
        _thirdPartyLoginConn = [NaverThirdPartyLoginConnection getSharedInstance];

        [_thirdPartyLoginConn setIsNaverAppOauthEnable:YES];
        [_thirdPartyLoginConn setIsInAppOauthEnable:YES];

        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString *_naverServiceAppUrlScheme = [mainBundle objectForInfoDictionaryKey:@"naverServiceAppUrlScheme"];
        NSString *_naverConsumerKey = [mainBundle objectForInfoDictionaryKey:@"naverConsumerKey"];
        NSString *_naverConsumerSecret = [mainBundle objectForInfoDictionaryKey:@"naverConsumerSecret"];
        NSString *_naverServiceAppName = [mainBundle objectForInfoDictionaryKey:@"naverServiceAppName"];
        //Log the value
        [_thirdPartyLoginConn setConsumerKey:_naverConsumerKey ];
        [_thirdPartyLoginConn setConsumerSecret:_naverConsumerSecret];
        [_thirdPartyLoginConn setAppName:_naverServiceAppName];
        [_thirdPartyLoginConn setServiceUrlScheme:_naverServiceAppUrlScheme];

        _thirdPartyLoginConn.delegate = self;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        int version = [[[UIDevice currentDevice] systemVersion] intValue];
        if (7 <= version) {
            // self.automaticallyAdjustsScrollViewInsets = NO;
        }
#endif
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_naver_login"
                                     binaryMessenger:[registrar messenger]];
    FlutterNaverLoginPlugin* instance = [[FlutterNaverLoginPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    _naverResult = result;
    if ([@"logIn" isEqualToString:call.method]) {
        [_thirdPartyLoginConn requestThirdPartyLogin];
    }  else if ([@"logOut" isEqualToString:call.method]) {
        [_thirdPartyLoginConn resetToken];
        [self logout];
    } else if ([@"logoutAndDeleteToken" isEqualToString:call.method]) {
        [_thirdPartyLoginConn requestDeleteToken];
    } else if ([@"getCurrentAcount" isEqualToString:call.method]) {
        [self getUserInfo];
    } else if ([@"getCurrentAccessToken" isEqualToString:call.method]) {

        NSTimeInterval expiresAt = [_thirdPartyLoginConn.accessTokenExpireDate timeIntervalSince1970];
        
        NSMutableDictionary *info = [NSMutableDictionary new];
        info[@"status"] = @"getToken";
        info[@"accessToken"] = _thirdPartyLoginConn.accessToken;
        info[@"refreshToken"] = _thirdPartyLoginConn.refreshToken;
        info[@"tokenType"] = _thirdPartyLoginConn.tokenType;
        info[@"expiresAt"] = [NSString stringWithFormat:@"%.0f", floor(expiresAt)];

        _naverResult(info);
    } else if ([@"refreshAccessTokenWithRefreshToken" isEqualToString:call.method]) {
        [_thirdPartyLoginConn requestAccessTokenWithRefreshToken];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

-(void) logout {
    NSMutableDictionary *info = [NSMutableDictionary new];
    info[@"status"] = @"cancelledByUser";
    info[@"isLogin"] = false;
    _naverResult(info);
}

-(void) getUserInfo {
    //xml
    //NSString *urlString = @"https://openapi.naver.com/v1/nid/getUserProfile.xml";  //  사용자 프로필 호출
    //json
    NSString *urlString = @"https://openapi.naver.com/v1/nid/me";

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", _thirdPartyLoginConn.accessToken];

    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *decodingString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    if (error) {
        NSLog(@"Error happened - %@", [error description]);
    } else {
        NSData *jsonData = [decodingString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];

        NSDictionary *res = [dict objectForKey:@"response"];
        NSMutableDictionary *info = [NSMutableDictionary new];
        info[@"status"] = @"loggedIn";
        info[@"email"] = [res objectForKey:@"email"];
        info[@"gender"] = [res objectForKey:@"gender"];
        info[@"age"] = [res objectForKey:@"age"];
        info[@"profile_image"] = [res objectForKey:@"profile_image"];
        info[@"nickname"] = [res objectForKey:@"nickname"];
        info[@"name"] = [res objectForKey:@"name"];
        info[@"id"] = [res objectForKey:@"id"];
        info[@"birthday"] = [res objectForKey:@"birthday"];
        info[@"birthyear"] = [res objectForKey:@"birthyear"];
        info[@"mobile"] = [res objectForKey:@"mobile"];
        info[@"mobileE164"] = [res objectForKey:@"mobile_e164"];

        _naverResult(info);
    }
}

#pragma mark - OAuth20 deleagate

- (void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode {
    //         로그인이 성공했을 경우 호출
    [self getUserInfo];
}

- (void)oauth20ConnectionDidFinishDeleteToken {
    //         로그아웃 경우 호출
    NSMutableDictionary *info = [NSMutableDictionary new];
    info[@"status"] = @"cancelledByUser";
    info[@"isLogin"] = false;
    _naverResult(info);
}

- (void)oauth20ConnectionDidFinishRequestACTokenWithRefreshToken {
    //         이미 로그인이 되어있는 경우 access 토큰을 업데이트 하는 경우
    [self getUserInfo];
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error
{
    [self logout];
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFinishAuthorizationWithResult:(THIRDPARTYLOGIN_RECEIVE_TYPE)recieveType
{
    [self getUserInfo];
}

- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailAuthorizationWithRecieveType:(THIRDPARTYLOGIN_RECEIVE_TYPE)recieveType
{
    NSMutableDictionary *info = [NSMutableDictionary new];
    info[@"status"] = @"error";
    info[@"errorMessage"] = @"NaverApp login fail handler";
    _naverResult(info);
}

@end
