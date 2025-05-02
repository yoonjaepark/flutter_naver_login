import Flutter
import NidThirdPartyLogin
import NidCore
import SafariServices
import UIKit

/// 네이버 로그인 상태를 나타내는 열거형
private enum NaverLoginState {
    case idle
    case inProgress
    case cancelled
}

/// 네이버 로그인 상태를 나타내는 열거형
public enum NaverLoginStatus: String {
    case loggedIn = "loggedIn"
    case loggedOut = "loggedOut"
    case error = "error"
}

/// Flutter 플러그인 메서드를 나타내는 열거형
private enum NaverLoginPluginMethod {
    case initSdk
    case logIn
    case logOut
    case logoutAndDeleteToken
    case getCurrentAccount
    case getCurrentAccessToken
    case refreshAccessTokenWithRefreshToken
    case isLoggedIn
    case unknown
    
    init(methodName: String) {
        switch methodName {
        case "initSdk":
            self = .initSdk
        case "logIn":
            self = .logIn
        case "logOut":
            self = .logOut
        case "logoutAndDeleteToken":
            self = .logoutAndDeleteToken
        case "getCurrentAccount":
            self = .getCurrentAccount
        case "getCurrentAccessToken":
            self = .getCurrentAccessToken
        case "refreshAccessTokenWithRefreshToken":
            self = .refreshAccessTokenWithRefreshToken
        case "isLoggedIn":
            self = .isLoggedIn
        default:
            self = .unknown
        }
    }
}

/// 네이버 로그인 플러그인의 메인 클래스
@objc
public class FlutterNaverLoginPlugin: NSObject, FlutterPlugin {
    private var pendingResult: FlutterResult?
    private var loginState: NaverLoginState = .idle

    // MARK: - Lifecycle

    override public init() {
        super.init()
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Methods

    private func setupNotifications() {
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
    }

    @objc private func appDidEnterBackground() {
        if case .inProgress = loginState {
            loginState = .cancelled
        }
    }

    @objc private func appWillEnterForeground() {
        if case .cancelled = loginState {
            sendError(message: "Login cancelled by user")
            loginState = .idle
        }
    }

    // MARK: - Flutter Plugin Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterNaverLoginPlugin()
        
        // Info.plist에서 네이버 로그인 설정 값 읽기
        let infoDictionary = Bundle.main.infoDictionary
        
        guard let clientId = infoDictionary?["NidClientID"] as? String,
              let clientSecret = infoDictionary?["NidClientSecret"] as? String,
              let appName = infoDictionary?["NidAppName"] as? String,
              let urlScheme = infoDictionary?["NidUrlScheme"] as? String else {
            print("Error: Required Naver Login configuration not found in Info.plist")
            return
        }
        
        // SDK 초기화
        NidOAuth.shared.initialize()
        
        // 기본 로그인 동작 설정 (웹뷰)
        NidOAuth.shared.setLoginBehavior(.inAppBrowser)
        
        let channel = FlutterMethodChannel(
            name: "flutter_naver_login",
            binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - Handle Method Calls

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if pendingResult != nil {
            sendError(message: "Another request is in progress. Please wait", result: result)
            return
        }
        self.pendingResult = result
        let flutterMethod = NaverLoginPluginMethod(methodName: call.method)
        switch flutterMethod {
        case .initSdk:
            guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Arguments are required", 
                              details: nil))
            return
            }
            handleInitSdk(args)
        case .logIn:
            handleLogin()
        case .logOut:
            handleLogout()
        case .logoutAndDeleteToken:
            handleLogoutAndDeleteToken()
        case .getCurrentAccount:
            handleGetCurrentAccount()
        case .getCurrentAccessToken:
            handleGetCurrentAccessToken()
        case .refreshAccessTokenWithRefreshToken:
            handleRefreshToken()
        case .isLoggedIn:
            handleIsLoggedIn()
        case .unknown:
            pendingResult?(FlutterMethodNotImplemented)
            pendingResult = nil
        }
    }

    // MARK: - Handler Methods

    private func handleInitSdk(_ args: [String: Any]) {
        // Info.plist에서 네이버 로그인 설정 값 읽기
        let infoDictionary = Bundle.main.infoDictionary
        guard let clientId = infoDictionary?["NidClientID"] as? String,
              let clientSecret = infoDictionary?["NidClientSecret"] as? String,
              let appName = infoDictionary?["NidAppName"] as? String,
              let urlScheme = infoDictionary?["NidUrlScheme"] as? String else {
            sendError(message: "Required Naver Login configuration not found in Info.plist. Please check NidClientID, NidClientSecret, NidAppName, and NidUrlScheme values.")
            return
        }

        // 로그인 동작 설정
        if let behavior = args["loginBehavior"] as? String {
            switch behavior.lowercased() {
            case "web":
                NidOAuth.shared.setLoginBehavior(.inAppBrowser)
            case "app":
                NidOAuth.shared.setLoginBehavior(.app)
            default:
                print("Unknown login behavior: \(behavior)")
                break
            }
        }

        // SDK 초기화 완료 후 결과 전송
        sendResult(status: .loggedOut)
    }

    private func handleLogin() {
        loginState = .inProgress
        NidOAuth.shared.requestLogin { [weak self] result in
            switch result {
            case .success(let loginResult):
                let tokenInfo: [String: Any] = [
                    "accessToken": loginResult.accessToken.tokenString,
                    "refreshToken": loginResult.refreshToken.tokenString,
                    "tokenType": "bearer",
                    "expiresAt": loginResult.accessToken.expiresAt.iso8601String()
                ]
                // 프로필 정보 조회
                self?.getUserProfile(accessToken: loginResult.accessToken.tokenString) { profileResult in
                    switch profileResult {
                    case .success(let profile):
                        self?.sendResult(status: .loggedIn, accessToken: tokenInfo, account: profile)
                    case .failure(let error):
                        self?.sendError(message: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self?.sendError(message: error.localizedDescription)
            }
            self?.loginState = .idle
        }
    }

    private func handleLogout() {
        NidOAuth.shared.logout()
        sendResult(status: .loggedOut)
    }

    private func handleLogoutAndDeleteToken() {
        // 먼저 토큰 삭제 시도
        NidOAuth.shared.disconnect { [weak self] result in
            switch result {
            case .success:
                // 토큰 삭제 성공 후 로그아웃 실행
                NidOAuth.shared.logout()
                self?.sendResult(status: .loggedOut)
            case .failure(let error):
                // 토큰 삭제 실패 시에도 로그아웃은 시도
                NidOAuth.shared.logout()
                self?.sendError(message: "Token deletion failed: \(error.localizedDescription)")
            }
        }
    }

    private func handleGetCurrentAccount() {
        guard let accessToken = NidOAuth.shared.accessToken?.tokenString else {
            sendError(message: "No access token available")
            return
        }

        NidOAuth.shared.getUserProfile(accessToken: accessToken) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.sendResult(status: .loggedIn, account: profile)
            case .failure(let error):
                self?.sendError(message: error.localizedDescription)
            }
        }
    }

    private func handleGetCurrentAccessToken() {
        guard let token = NidOAuth.shared.accessToken else {
            sendResult(status: .loggedOut)
            return
        }

        let tokenInfo: [String: Any] = [
            "accessToken": token.tokenString,
            "refreshToken": NidOAuth.shared.refreshToken?.tokenString ?? "",
            "tokenType": "bearer",
            "expiresAt": token.expiresAt.iso8601String()
        ]

        sendResult(status: .loggedIn, accessToken: tokenInfo)
    }

    private func handleRefreshToken() {
        guard let refreshToken = NidOAuth.shared.refreshToken?.tokenString else {
            sendError(message: "No refresh token available")
            return
        }

        // 재인증을 통해 토큰 갱신
        NidOAuth.shared.reauthenticate { [weak self] result in
            switch result {
            case .success(let loginResult):
                let tokenInfo: [String: Any] = [
                    "accessToken": loginResult.accessToken.tokenString,
                    "refreshToken": loginResult.refreshToken.tokenString,
                    "tokenType": "bearer",
                    "expiresAt": loginResult.accessToken.expiresAt.iso8601String()
                ]
                self?.sendResult(status: .loggedIn, accessToken: tokenInfo)
            case .failure(let error):
                self?.sendError(message: error.localizedDescription)
            }
        }
    }

    private func handleIsLoggedIn() {
        if let accessToken = NidOAuth.shared.accessToken?.tokenString {
            sendResult(status: .loggedIn)
        } else {
            sendResult(status: .loggedOut)
        }
    }

    // MARK: - Helper Methods

    private func verifyAndGetProfile(accessToken: String, completion: @escaping (Bool) -> Void) {
        NidOAuth.shared.verifyAccessToken(accessToken) { [weak self] result in
            switch result {
            case .success(let isValid):
                if isValid {
                    self?.getUserProfile(accessToken: accessToken) { profileResult in
                        switch profileResult {
                        case .success(let profile):
                            // 로그인 시에는 토큰과 계정 정보 모두 포함
                            self?.sendResult(status: .loggedIn, accessToken: nil, account: profile)
                            completion(true)
                        case .failure(let error):
                            self?.sendError(message: error.localizedDescription)
                            completion(false)
                        }
                    }
                } else {
                    self?.sendError(message: "Invalid access token")
                    completion(false)
                }
            case .failure(let error):
                self?.sendError(message: error.localizedDescription)
                completion(false)
            }
        }
    }

    private func getUserProfile(accessToken: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        NidOAuth.shared.getUserProfile(accessToken: accessToken) { result in
            completion(result.mapError { $0 as Error })
        }
    }

    // MARK: - Result Handling

    private func sendResult(status: NaverLoginStatus, accessToken: [String: Any]? = nil, account: [String: String]? = nil) {
        var result: [String: Any] = ["status": status.rawValue.lowercased()]
        
        if let accessToken = accessToken {
            result["accessToken"] = accessToken
        }
        
        if let account = account {
            result["account"] = account
        }
        
        DispatchQueue.main.async {
            self.pendingResult?(result)
            self.pendingResult = nil
        }
    }

    private func sendError(message: String, result: FlutterResult? = nil) {
        let errorInfo: [String: Any] = [
            "status": NaverLoginStatus.error.rawValue.lowercased(),
            "errorMessage": message
        ]
        
        DispatchQueue.main.async {
            (result ?? self.pendingResult)?(errorInfo)
            self.pendingResult = nil
        }
    }
}

extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
