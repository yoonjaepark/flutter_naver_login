import Flutter
import UIKit
import NaverThirdPartyLogin
import Alamofire

public class SwiftFlutterNaverLoginPlugin: NSObject, FlutterPlugin, NaverThirdPartyLoginConnectionDelegate {
    let METHOD_LOG_IN: String = "logIn";
    let METHOD_LOG_OUT: String = "logOut";
    let METHOD_GET_CURRENT_ACCESS_TOKEN: String = "getCurrentAccessToken";
    let METHOD_GET_ACCOUNT: String = "getCurrentAcount";

    var naverResult: FlutterResult!
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance();
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_naver_login", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterNaverLoginPlugin()
        
        let infoDic = Bundle.main.infoDictionary!
        let _kServiceAppUrlScheme = infoDic["kServiceAppUrlScheme"] as! String
        let _kConsumerKey = infoDic["kConsumerKey"] as! String
        let _kConsumerSecret = infoDic["kConsumerSecret"] as! String
        let _kServiceAppName = infoDic["kServiceAppName"] as! String

        instance.loginInstance?.isInAppOauthEnable = true;
        instance.loginInstance?.isNaverAppOauthEnable = true;
        instance.loginInstance?.isOnlyPortraitSupportedInIphone();
        instance.loginInstance?.serviceUrlScheme = _kServiceAppUrlScheme;
        instance.loginInstance?.consumerKey = _kConsumerKey;
        instance.loginInstance?.consumerSecret = _kConsumerSecret;
        instance.loginInstance?.appName = _kServiceAppName;
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    //MARK: - OAuth20 deleagate
    public func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
//         로그인이 성공했을 경우 호출
        getUserInfo();
    }
    
    public func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        /* 로그인 실패시에 호출되며 실패 이유와 메시지 확인 가능합니다. */
        print("oauth20Connection");
        var errorResult = [String : String]()
        errorResult["status"] = "error"
        errorResult["errorMessage"] = error as! String?
        naverResult(errorResult)
    }
    
    //MARK: - OAuth20 deleagate
    public func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        // 네이버 앱이 설치되어있지 않은 경우에 인앱 브라우저로 열리는데 이때 호출되는 함수
        print("oauth20ConnectionDidOpenInAppBrowser");
        let naverInappBrower = NLoginThirdPartyOAuth20InAppBrowserViewController(request: request)
        naverInappBrower?.modalPresentationStyle = .overFullScreen
    }
    
   public func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
//         이미 로그인이 되어있는 경우 access 토큰을 업데이트 하는 경우
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM-dd-yyyy"
//        print("oauth20ConnectionDidFinishRequestACTokenWithRefreshToken");
//        var tokenResult = [String : String]()
//        tokenResult["status"] = "loggedIn"
//        tokenResult["accessToken"] = loginInstance?.accessToken
//        tokenResult["expiresAt"] = dateFormatter.string(from: (loginInstance?.accessTokenExpireDate ?? nil)!)
//        tokenResult["tokenType"] = loginInstance?.tokenType
//        naverResult(tokenResult);
        getUserInfo()

    }
    
   public func oauth20ConnectionDidFinishDeleteToken() {
        // 로그아웃이나 토큰이 삭제되는 경우
        var logoutResult = [String : Any]()
        logoutResult["status"] = "loggedOut"
        logoutResult["isLogin"] = false
        logoutResult["accessToken"] = loginInstance?.accessToken
        logoutResult["tokenType"] = loginInstance?.tokenType
        print("oauth20ConnectionDidFinishDeleteToken");
        naverResult(logoutResult);
    }
    
    func getUserInfo() {
        guard let loginConn = NaverThirdPartyLoginConnection.getSharedInstance() else {return}
        guard let tokenType = loginConn.tokenType else {return}
        guard let accessToken = loginConn.accessToken else {return}
        var object = [String: Any]()
        var _res = [String: Any]()

        let authorization = "\(tokenType) \(accessToken)"
        AF.request("https://openapi.naver.com/v1/nid/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization" : authorization]).responseJSON { (response) in
            switch response.result {
            case .success(let value):
              
                
//                guard let result = response.result.value as? [String: Any] else {return}
//                object = value["response"] as! [String : Any]
                object = value as! [String : Any]
                _res = object["response"] as! [String : Any]
                guard (_res["birthday"] as? String) != nil else {return}
                guard (_res["name"] as? String) != nil else {return}
                guard (_res["email"] as? String) != nil else {return}
                print(_res)
                _res["status"] = "loggedIn"
                self.naverResult(_res)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        naverResult = result
        print(call.method)
        switch call.method {
        case METHOD_LOG_IN:
            loginInstance?.delegate = self
            loginInstance?.requestThirdPartyLogin()
            break;
        case METHOD_LOG_OUT:
            loginInstance?.requestDeleteToken()
            break;
        case METHOD_GET_ACCOUNT:
            getUserInfo()
            break;
        case METHOD_GET_CURRENT_ACCESS_TOKEN:
            var tokenResult = [String : String]()
            tokenResult["status"] = "getCurrentAccessToken"
            tokenResult["accessToken"] = loginInstance?.accessToken
            tokenResult["tokenType"] = loginInstance?.tokenType
            self.naverResult(tokenResult)
            break;
        default:
            break;
        }
    }
}
