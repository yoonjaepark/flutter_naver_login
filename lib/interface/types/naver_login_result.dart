import 'naver_account_result.dart';
import 'naver_login_status.dart';
import 'naver_token.dart';

/// naver_login_result.dart
///
/// 네이버 로그인 결과를 나타내는 클래스입니다.
/// 이 클래스는 네이버 로그인 기능의 결과를 정의하고,
/// 로그인 결과 정보를 포함합니다.
class NaverLoginResult {
  final NaverToken? accessToken;
  final NaverAccountResult? account;
  final NaverLoginStatus status;
  final String? errorMessage;

  /// 네이버 로그인 결과를 생성하는 생성자입니다.
  ///
  /// 이 생성자는 네이버 로그인 결과의 각 속성을 초기화합니다.
  ///
  /// 매개변수:
  /// - accessToken: 액세스 토큰 정보
  /// - account: 사용자 계정 정보
  /// - status: 로그인 상태
  /// - errorMessage: 에러 메시지 (실패 시)
  NaverLoginResult({
    this.accessToken,
    this.account,
    required this.status,
    this.errorMessage,
  });

  /// 맵에서 네이버 로그인 결과를 생성하는 팩토리 메서드입니다.
  ///
  /// 이 메서드는 맵에서 네이버 로그인 결과의 각 속성을 추출하고,
  /// 해당 속성을 사용하여 NaverLoginResult 객체를 생성합니다.
  ///
  factory NaverLoginResult.fromMap(Map map) {
    return NaverLoginResult(
      accessToken:
          map['accessToken'] != null
              ? NaverToken.fromMap(
                Map<String, dynamic>.from(map['accessToken']),
              )
              : null,
      account:
          map['account'] != null
              ? NaverAccountResult.fromMap(
                Map<String, dynamic>.from(map['account']),
              )
              : null,
      status: NaverLoginStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == map['status'].toString().toLowerCase(),
        orElse: () => NaverLoginStatus.error,
      ),
      errorMessage: map['errorMessage'],
    );
  }

  /// 네이버 로그인 결과를 맵으로 변환하는 메서드입니다.
  ///
  /// 이 메서드는 NaverLoginResult 객체의 각 속성을 맵으로 변환하고,
  /// 해당 맵을 반환합니다.
  ///
  Map<String, dynamic> toMap() => {
    'accessToken': accessToken?.toMap(),
    'account': account?.toMap(),
    'status': status.index,
    'errorMessage': errorMessage,
  };
}
