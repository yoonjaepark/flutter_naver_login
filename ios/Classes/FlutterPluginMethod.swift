import Foundation

/// Flutter 플러그인에서 사용되는 메서드를 정의하는 열거형
enum FlutterPluginMethod: String {
    /// SDK 초기화
    case initSdk = "initSdk"
    /// 네이버 로그인
    case logIn = "logIn"
    /// 네이버 로그아웃
    case logOut = "logOut"
    /// 네이버 로그아웃 및 토큰 삭제
    case logoutAndDeleteToken = "logoutAndDeleteToken"
    /// 현재 계정 정보 조회
    case getCurrentAccount = "getCurrentAccount"
    /// 현재 액세스 토큰 정보 조회
    case getCurrentAccessToken = "getCurrentAccessToken"
    /// 리프레시 토큰으로 액세스 토큰 갱신
    case refreshAccessTokenWithRefreshToken = "refreshAccessTokenWithRefreshToken"
    /// 알 수 없는 메서드
    case unknown
    
    /// 문자열로부터 메서드를 생성하는 이니셜라이저
    /// - Parameter methodName: 메서드 이름
    init(methodName: String) {
        self = FlutterPluginMethod(rawValue: methodName) ?? .unknown
    }
} 