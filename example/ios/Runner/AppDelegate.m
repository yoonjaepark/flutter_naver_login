#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <NaverThirdPartyLogin/NaverThirdPartyLogin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// Implemented when iOS 9.0 higher
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[NaverThirdPartyLoginConnection getSharedInstance] application:app openURL:url options:options];
}

@end
