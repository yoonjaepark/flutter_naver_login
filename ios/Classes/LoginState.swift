/// 네이버 로그인의 상태를 나타내는 열거형
enum LoginState {
    /// 초기 상태 또는 작업이 완료된 상태
    case idle
    /// 로그인 작업이 진행 중인 상태
    case inProgress
    /// 에러가 발생한 상태
    case error(String)
    /// 로그인이 취소된 상태
    case cancelled
} 