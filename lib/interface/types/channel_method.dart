/// channel_method.dart
///
/// 네이버 로그인 기능의 메서드를 나타내는 열거형입니다.
/// 이 열거형은 네이버 로그인 기능의 메서드를 정의하고,
/// 메서드 이름을 문자열로 저장합니다.
enum FlutterPluginMethod {
  /// 네이버 로그인 기능의 메서드를 나타내는 열거형입니다.
  logIn('logIn'),

  /// 네이버 로그아웃 기능의 메서드를 나타내는 열거형입니다.
  logOut('logOut'),

  /// 네이버 로그아웃 및 토큰 삭제 기능의 메서드를 나타내는 열거형입니다.
  logOutAndDeleteToken('logoutAndDeleteToken'),

  /// 현재 네이버 계정 정보를 가져오는 메서드를 나타내는 열거형입니다.
  currentAccount('getCurrentAccount'),

  /// 현재 액세스 토큰 정보를 가져오는 메서드를 나타내는 열거형입니다.
  currentAccessToken('getCurrentAccessToken'),

  /// 리프레시 토큰을 사용하여 액세스 토큰을 갱신하는 메서드를 나타내는 열거형입니다.
  refreshAccessTokenWithRefreshToken('refreshAccessTokenWithRefreshToken');

  /// 메서드 이름을 문자열로 저장합니다.
  final String method;

  /// 메서드 이름을 문자열로 저장하는 생성자입니다.
  const FlutterPluginMethod(this.method);
}
