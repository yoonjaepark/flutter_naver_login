import Flutter
import UIKit
import NaverThirdPartyLogin
import Alamofire

public class SwiftFlutterNaverLoginPlugin: NSObject, FlutterPlugin, NaverThirdPartyLoginConnectionDelegate {
    let METHOD_LOG_IN: String = "logIn";
    let METHOD_LOG_OUT: String = "logOut";
    let METHOD_GET_CURRENT_ACCESS_TOKEN: String = "getCurrentAccessToken";
    let METHOD_GET_USER_ME: String = "getUserMe";
    var naverResult: FlutterResult!
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance();
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_naver_login", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterNaverLoginPlugin()
        instance.loginInstance?.isInAppOauthEnable = true;
        instance.loginInstance?.isNaverAppOauthEnable = true;
        instance.loginInstance?.isOnlyPortraitSupportedInIphone();
        instance.loginInstance?.serviceUrlScheme = kServiceAppUrlScheme;
        instance.loginInstance?.consumerKey = kConsumerKey;
        instance.loginInstance?.consumerSecret = kConsumerSecret;
        instance.loginInstance?.appName = kServiceAppName;
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    
    //MARK: - OAuth20 deleagate
    public func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        // 로그인이 성공했을 경우 호출
        print("oauth20ConnectionDidFinishRequestACTokenWithAuthCode");
        var loginResult = [String : String]()
        loginResult["status"] = "loggedIn"
        loginResult["accessToken"] = loginInstance?.accessToken as String?
        loginResult["refreshToken"] = loginInstance?.refreshToken as String?
        loginResult["tokenType"] = loginInstance?.tokenType as String?
        naverResult(loginResult);
    }
    
    
    public func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        /* 로그인 실패시에 호출되며 실패 이유와 메시지 확인 가능합니다. */
        print("oauth20Connection");
    }
    
    
    //MARK: - OAuth20 deleagate
    public func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        // 네이버 앱이 설치되어있지 않은 경우에 인앱 브라우저로 열리는데 이때 호출되는 함수
        print("oauth20ConnectionDidOpenInAppBrowser");
        let naverInappBrower = NLoginThirdPartyOAuth20InAppBrowserViewController(request: request)
        naverInappBrower?.modalPresentationStyle = .overFullScreen
    }
    
   public func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        // 이미 로그인이 되어있는 경우 access 토큰을 업데이트 하는 경우
        print("oauth20ConnectionDidFinishRequestACTokenWithRefreshToken");
    }
    
    
    
   public func oauth20ConnectionDidFinishDeleteToken() {
        // 로그아웃이나 토큰이 삭제되는 경우
        print("oauth20ConnectionDidFinishDeleteToken");
        naverResult(true);
    }
    
    func getUserInfo(_res: @escaping FlutterResult) {
        guard let loginConn = NaverThirdPartyLoginConnection.getSharedInstance() else {return}
        guard let tokenType = loginConn.tokenType else {return}
        guard let accessToken = loginConn.accessToken else {return}
    
        let authorization = "\(tokenType) \(accessToken)"
        Alamofire.request("https://openapi.naver.com/v1/nid/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization" : authorization]).responseJSON { (response) in
            guard let result = response.result.value as? [String: Any] else {return}
            guard let object = result["response"] as? [String: Any] else {return}
            guard (object["birthday"] as? String) != nil else {return}
            guard (object["name"] as? String) != nil else {return}
            guard (object["email"] as? String) != nil else {return}
            print(result)
            _res(result)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        naverResult = result

        switch call.method {
        case METHOD_LOG_IN:
            loginInstance?.delegate = self
            loginInstance?.requestThirdPartyLogin()
            break;
        case METHOD_LOG_OUT:
            loginInstance?.requestDeleteToken();
            break;
        case METHOD_GET_USER_ME:
            guard let loginConn = NaverThirdPartyLoginConnection.getSharedInstance() else {return}
            guard let tokenType = loginConn.tokenType else {return}
            guard let accessToken = loginConn.accessToken else {return}

            let authorization = "\(tokenType) \(accessToken)"
            Alamofire.request("https://openapi.naver.com/v1/nid/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization" : authorization]).responseJSON {
                (response) in
                    guard let res = response.result.value as? [String: Any] else {return}
                    guard var _res = res["response"] as? [String: Any] else {return}
                    _res["status"] = "getUserMe"
                    result(_res);
            }
            break;
        case METHOD_GET_CURRENT_ACCESS_TOKEN:
            result(loginInstance?.accessToken);
            break;
        default:
            break;
        }
    }
}
