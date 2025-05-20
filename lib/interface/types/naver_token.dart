import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/utils/clock.dart';

/// naver_access_token.dart
///
/// 네이버 액세스 토큰을 나타내는 클래스입니다.
/// 이 클래스는 네이버 로그인 기능의 결과를 정의하고,
/// 액세스 토큰 정보를 포함합니다.
@immutable
class NaverToken {
  final String accessToken;
  final String refreshToken;
  final String expiresAt;
  final String tokenType;

  /// 네이버 액세스 토큰을 생성하는 생성자입니다.
  ///
  /// 이 생성자는 네이버 액세스 토큰의 각 속성을 초기화합니다.
  ///
  /// 매개변수:
  /// - accessToken: 액세스 토큰
  const NaverToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.tokenType,
  });

  /// 맵에서 네이버 액세스 토큰을 생성하는 팩토리 메서드입니다.
  ///
  /// 이 메서드는 맵에서 네이버 액세스 토큰의 각 속성을 추출하고,
  /// 해당 속성을 사용하여 NaverAccessToken 객체를 생성합니다.
  ///
  factory NaverToken.fromMap(Map<String, dynamic> map) {
    final m = Map<String, dynamic>.from(map);
    return NaverToken(
      accessToken: m['accessToken'] ?? '',
      refreshToken: m['refreshToken'] ?? '',
      expiresAt: m['expiresAt'] ?? '',
      tokenType: m['tokenType'] ?? '',
    );
  }

  /// 빈 네이버 액세스 토큰을 생성하는 팩토리 메서드입니다.
  ///
  /// 이 메서드는 빈 네이버 액세스 토큰을 생성하고,
  /// 해당 속성을 사용하여 NaverAccessToken 객체를 생성합니다.
  ///
  factory NaverToken.empty() => const NaverToken(
    accessToken: '',
    refreshToken: '',
    expiresAt: '',
    tokenType: '',
  );

  Map<String, dynamic> toMap() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt,
    'tokenType': tokenType,
  };

  /// 네이버 액세스 토큰이 유효한지 확인하는 메서드입니다.
  ///
  /// 토큰의 유효성을 검사합니다.
  ///
  /// 만료 시간이 있고, 현재 시간이 만료 시간보다 이전인 경우 true를 반환합니다.
  /// 그 외의 경우 false를 반환합니다.
  bool isValid() {
    if (expiresAt == null) return false;
    final expireDate = DateTime.tryParse(expiresAt!);
    if (expireDate == null) return false;
    return Clock.now().isBefore(expireDate);
  }

  /// 네이버 액세스 토큰을 문자열로 변환하는 메서드입니다.
  ///
  /// 이 메서드는 네이버 액세스 토큰의 각 속성을 문자열로 변환하고,
  /// 해당 문자열을 반환합니다.
  @override
  String toString() =>
      '{ accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt, tokenType: $tokenType }';

  /// 네이버 액세스 토큰을 비교하는 메서드입니다.
  ///
  /// 이 메서드는 네이버 액세스 토큰을 비교하고,
  /// 같은 경우 true를 반환하고, 다른 경우 false를 반환합니다.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NaverToken &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt &&
          tokenType == other.tokenType;

  /// 네이버 액세스 토큰의 해시 코드를 반환하는 메서드입니다.
  ///
  /// 이 메서드는 네이버 액세스 토큰의 각 속성을 해시 코드로 변환하고,
  /// 해당 해시 코드를 반환합니다.
  @override
  int get hashCode =>
      Object.hash(accessToken, refreshToken, expiresAt, tokenType);
}
