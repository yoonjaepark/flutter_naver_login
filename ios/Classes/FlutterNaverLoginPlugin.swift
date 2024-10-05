import Flutter
import NaverThirdPartyLogin
import SafariServices
import UIKit

@objc
public class FlutterNaverLoginPlugin: NSObject, FlutterPlugin,
    NaverThirdPartyLoginConnectionDelegate
{
    private var loginConn: NaverThirdPartyLoginConnection?
    private var pendingResult: FlutterResult?
    private var didInitialized: Bool = false
    private var didEnteredBg: Bool = false
    private var loginState: LoginState = .idle

    // MARK: -

    override public init() {
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)

        // FIXME: should method call initSdk
        initSdk()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func appDidEnterBackground() {
        print("didEnterBg - loginState: \(loginState)")
        if case .inProgress = loginState {
            didEnteredBg = true
        }
    }

    @objc private func appWillEnterForeground() {
        print(
            "willEnterFg - loginState: \(loginState), isReturningFromNaverApp: \(didEnteredBg)"
        )
        if case .inProgress = loginState, didEnteredBg {
            // Add delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                [weak self] in
                guard let self = self else { return }
                if case .inProgress = self.loginState, self.didEnteredBg {
                    let info: [String: Any] = [
                        "status": "cancelledByUser",
                        "isLogin": false,
                    ]
                    self.pendingResult?(info)
                    self.pendingResult = nil
                    self.loginState = .idle
                    self.didEnteredBg = false
                }
            }
        }
    }

    // MARK: - Flutter Plugin Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_naver_login", binaryMessenger: registrar.messenger())
        let instance = FlutterNaverLoginPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - Handle Method Calls from Flutter

    public func handle(
        _ call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        print("Received method call: \(call.method)")

        if pendingResult != nil {
            let errorInfo: [String: String] = [
                "status": "error",
                "errorMessage": "Another request is in progress. Please wait",
            ]
            result(errorInfo)
            return
        }
        self.pendingResult = result

        guard didInitialized else {
            let errorInfo: [String: String] = [
                "status": "error",
                "errorMessage":
                    "NaverLoginPlugin is not initialized",
            ]
            DispatchQueue.main.async {
                self.pendingResult?(errorInfo)
                self.pendingResult = nil
            }
            return
        }

        let flutterMethod = FlutterPluginMethod(methodName: call.method)
        print(call.method)

        switch flutterMethod {
        case .initSdk:
            initSdk()

        case .logIn:
            login()

        case .logOut:
            logout()

        case .logoutAndDeleteToken:
            logoutAndDeleteToken()

        case .getCurrentAccount:
            getCurrentAccount()

        case .getCurrentAccessToken:
            getCurrentAccessToken()

        case .refreshAccessTokenWithRefreshToken:
            refreshAccessTokenWithRefreshToken()

        case .unknown:
            result(FlutterMethodNotImplemented)
            self.pendingResult = nil
        }
    }

    // MARK: -

    private func initSdk() {
        if didInitialized {
            DispatchQueue.main.async {
                self.pendingResult?(true)
                self.pendingResult = nil
            }
            return
        }
        guard
            let sharedConn = NaverThirdPartyLoginConnection.getSharedInstance()
        else {
            print(
                "Error: Failed to get NaverThirdPartyLoginConnection instance.")
            self.didInitialized = false
            return
        }
        self.loginConn = sharedConn

        self.loginConn?.isNaverAppOauthEnable = true
        self.loginConn?.isInAppOauthEnable = true

        let mainBundle = Bundle.main

        guard
            let naverServiceAppUrlScheme = mainBundle.object(
                forInfoDictionaryKey: "naverServiceAppUrlScheme") as? String,
            !naverServiceAppUrlScheme.isEmpty
        else {
            print(
                "Error: Missing or empty 'naverServiceAppUrlScheme' in Info.plist"
            )
            self.didInitialized = false
            DispatchQueue.main.async {
                self.pendingResult?(false)
                self.pendingResult = nil
            }
            return
        }

        guard
            let naverConsumerKey = mainBundle.object(
                forInfoDictionaryKey: "naverConsumerKey") as? String,
            !naverConsumerKey.isEmpty
        else {
            print("Error: Missing or empty 'naverConsumerKey' in Info.plist")
            self.didInitialized = false
            DispatchQueue.main.async {
                self.pendingResult?(false)
                self.pendingResult = nil
            }
            return
        }

        guard
            let naverConsumerSecret = mainBundle.object(
                forInfoDictionaryKey: "naverConsumerSecret") as? String,
            !naverConsumerSecret.isEmpty
        else {
            print("Error: Missing or empty 'naverConsumerSecret' in Info.plist")
            self.didInitialized = false
            DispatchQueue.main.async {
                self.pendingResult?(false)
                self.pendingResult = nil
            }
            return
        }

        guard
            let naverServiceAppName = mainBundle.object(
                forInfoDictionaryKey: "naverServiceAppName") as? String,
            !naverServiceAppName.isEmpty
        else {
            print("Error: Missing or empty 'naverServiceAppName' in Info.plist")
            self.didInitialized = false
            DispatchQueue.main.async {
                self.pendingResult?(false)
                self.pendingResult = nil
            }
            return
        }

        self.loginConn?.consumerKey = naverConsumerKey
        self.loginConn?.consumerSecret = naverConsumerSecret
        self.loginConn?.appName = naverServiceAppName
        self.loginConn?.serviceUrlScheme = naverServiceAppUrlScheme
        self.loginConn?.delegate = self
        self.didInitialized = true

        //.       FIXME: should method call initSdk
        //        DispatchQueue.main.async {
        //            self.pendingResult?(true)
        //            self.pendingResult = nil
        //        }
    }

    private func login() {
        loginState = .inProgress
        didEnteredBg = false
        loginConn!.requestThirdPartyLogin()
    }

    private func logout() {
        loginConn?.resetToken()
        let info: [String: String] = [
            "status": "cancelledByUser",
            "isLogin": "false",
        ]
        DispatchQueue.main.async {
            self.pendingResult?(info)
            self.pendingResult = nil
        }
    }

    private func logoutAndDeleteToken() {
        loginConn?.requestDeleteToken()
        let info: [String: String] = [
            "status": "cancelledByUser",
            "isLogin": "false",
        ]
        DispatchQueue.main.async {
            self.pendingResult?(info)
            self.pendingResult = nil
        }
    }

    private func getCurrentAccount() {
        getUserInfo { result in
            switch result {
            case .success(let info):
                print(info)
                DispatchQueue.main.async {
                    self.pendingResult?(info)
                    self.pendingResult = nil
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.pendingResult?(
                        FlutterError(
                            code: "ERROR", message: error.localizedDescription,
                            details: nil))
                    self.pendingResult = nil
                }
            }
        }
    }

    private func getUserInfo(
        completion: @escaping (Result<[String: String], Error>) -> Void
    ) {
        let urlString = "https://openapi.naver.com/v1/nid/me"

        guard let url = URL(string: urlString) else {
            completion(
                .failure(
                    NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var urlRequest = URLRequest(url: url)

        guard let accessToken = loginConn?.accessToken else {
            completion(
                .failure(
                    NSError(domain: "No Access Token", code: 401, userInfo: nil)
                ))
            return
        }

        let authValue = "Bearer \(accessToken)"
        urlRequest.setValue(authValue, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: urlRequest) {
            [weak self] data, response, error in
            guard self != nil else { return }

            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(
                    .failure(
                        NSError(domain: "No Data", code: 204, userInfo: nil)))
                return
            }

            do {
                if let dict = try JSONSerialization.jsonObject(
                    with: data, options: []) as? [String: Any],
                    let res = dict["response"] as? [String: Any]
                {

                    var info: [String: String] = ["status": "loggedIn"]

                    let userFields = [
                        "email", "gender", "age", "profile_image", "nickname",
                        "name", "id", "birthday", "birthyear", "mobile",
                        "mobile_e164",
                    ]

                    for field in userFields {
                        if let value = res[field] as? String {
                            info[field] = value
                        }
                    }

                    completion(.success(info))
                } else {
                    print("Invalid JSON structure")
                    completion(
                        .failure(
                            NSError(
                                domain: "Invalid JSON Structure", code: 500,
                                userInfo: nil)))
                }
            } catch let jsonError {
                print("JSON parsing error: \(jsonError.localizedDescription)")
                completion(.failure(jsonError))
            }
        }

        task.resume()
    }

    private func getCurrentAccessToken() {
        let accessToken = loginConn?.accessToken ?? ""
        let refreshToken = loginConn?.refreshToken ?? ""
        let tokenType = loginConn?.tokenType ?? ""
        let expiresAt =
            loginConn?.accessTokenExpireDate?.timeIntervalSince1970 ?? 0
        let expiresAtString = String(format: "%.0f", floor(expiresAt))

        let info: [String: String] = [
            "status": "getToken",
            "accessToken": accessToken,
            "refreshToken": refreshToken,
            "tokenType": tokenType,
            "expiresAt": expiresAtString,
        ]

        DispatchQueue.main.async {
            self.pendingResult?(info)
            self.pendingResult = nil
        }
    }

    private func refreshAccessTokenWithRefreshToken() {
        loginConn?.requestAccessTokenWithRefreshToken()
    }

    // MARK: - NaverThirdPartyLoginConnectionDelegate Methods

    public func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("oauth20ConnectionDidFinishRequestACTokenWithAuthCode")
        getCurrentAccount()
    }

    public func oauth20ConnectionDidFinishDeleteToken() {
        print("oauth20ConnectionDidFinishDeleteToken")
        let info: [String: String] = [
            "status": "cancelledByUser",
            "isLogin": "false",
        ]
        DispatchQueue.main.async {
            self.pendingResult?(info)
            self.pendingResult = nil
        }
    }

    public func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("oauth20ConnectionDidFinishRequestACTokenWithRefreshToken")
        getCurrentAccount()
        loginState = .idle
    }

    public func oauth20Connection(
        _ oauthConnection: NaverThirdPartyLoginConnection,
        didFailWithError error: Error
    ) {
        loginConn?.resetToken()
        print(
            "oauth20Connection:didFailWithError - error: \(error.localizedDescription)"
        )
        let errorInfo: [String: String] = [
            "status": "error",
            "errorMessage": error.localizedDescription,
        ]

        DispatchQueue.main.async {
            self.pendingResult?(errorInfo)
            self.pendingResult = nil
        }
        loginState = .idle
    }

    public func oauth20Connection(
        _ oauthConnection: NaverThirdPartyLoginConnection,
        didFinishAuthorizationWithResult receiveType:
            THIRDPARTYLOGIN_RECEIVE_TYPE
    ) {
        print(
            "oauth20Connection:didFinishAuthorizationWithResult - receiveType: \(receiveType)"
        )
        switch receiveType {
        case SUCCESS:
            print("SUCCESS login")
            loginState = .inProgress
        default:
            print(
                "FAILED login. But callbacked from didFinishAuthorizationWithResult"
            )
            loginState = .idle
        }
    }

    public func oauth20Connection(
        _ oauthConnection: NaverThirdPartyLoginConnection,
        didFailAuthorizationWithReceive receiveType:
            THIRDPARTYLOGIN_RECEIVE_TYPE
    ) {
        print(
            "oauth20Connection:didFailAuthorizationWithReceiveType - receiveType: \(receiveType.rawValue)"
        )

        let errorMessage: String?
        switch receiveType {
        case SUCCESS:
            print(
                "SUCCESS. But callbacked from didFailAuthorizationWithReceive")
            errorMessage = nil
        case PARAMETERNOTSET:
            errorMessage = "PARAMETERNOTSET"
        case CANCELBYUSER:
            errorMessage = "CANCELBYUSER"
        case NAVERAPPNOTINSTALLED:
            errorMessage = "NAVERAPPNOTINSTALLED"
        case NAVERAPPVERSIONINVALID:
            errorMessage = "NAVERAPPVERSIONINVALID"
        case OAUTHMETHODNOTSET:
            errorMessage = "OAUTHMETHODNOTSET"
        case INVALIDREQUEST:
            errorMessage = "INVALIDREQUEST"
        case CLIENTNETWORKPROBLEM:
            errorMessage = "CLIENTNETWORKPROBLEM"
        case UNAUTHORIZEDCLIENT:
            errorMessage = "UNAUTHORIZEDCLIENT"
        case UNSUPPORTEDRESPONSETYPE:
            errorMessage = "UNSUPPORTEDRESPONSETYPE"
        case NETWORKERROR:
            errorMessage = "NETWORKERROR"
        case UNKNOWNERROR:
            errorMessage = "UNKNOWNERROR"
        default:
            errorMessage = "UNKNOWN"
        }

        guard let errorMessage else {
            loginState = .inProgress
            return
        }

        let info: [String: String] = [
            "status": "error",
            "errorMessage": errorMessage,
        ]
        DispatchQueue.main.async {
            self.pendingResult?(info)
            self.pendingResult = nil
        }
        loginState = .idle
    }
}
