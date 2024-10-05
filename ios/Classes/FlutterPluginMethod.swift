import Foundation

enum FlutterPluginMethod: String {
    case logIn = "logIn"
    case initSdk = "initSdk"
    case logOut = "logOut"
    case logoutAndDeleteToken = "logoutAndDeleteToken"
    case getCurrentAccount = "getCurrentAccount"
    case getCurrentAccessToken = "getCurrentAccessToken"
    case refreshAccessTokenWithRefreshToken = "refreshAccessTokenWithRefreshToken"
    
    // Optionally, you can add a case for unknown methods
    case unknown
    
    // Initializer to handle unknown methods gracefully
    init(methodName: String) {
        self = FlutterPluginMethod(rawValue: methodName) ?? .unknown
    }
}
