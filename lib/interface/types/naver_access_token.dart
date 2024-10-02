import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/interface/utils/clock.dart';

@immutable
class NaverAccessToken {
  final String accessToken;
  final String refreshToken;
  final String expiresAt;
  final String tokenType;

  const NaverAccessToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.tokenType,
  });

  factory NaverAccessToken.fromMap(Map<String, dynamic> map) {
    return NaverAccessToken(
      accessToken: map['accessToken'] ?? '',
      refreshToken: map['refreshToken'] ?? '',
      expiresAt: map['expiresAt'] ?? '',
      tokenType: map['tokenType'] ?? '',
    );
  }

  factory NaverAccessToken.empty() => const NaverAccessToken(
        accessToken: 'no token',
        refreshToken: 'no refreshToken',
        expiresAt: 'no token',
        tokenType: 'no token',
      );

  bool isValid() {
    if (expiresAt.isEmpty || expiresAt == 'no token') return false;
    bool timeValid = Clock.now().isBefore(
        DateTime.fromMillisecondsSinceEpoch(int.parse(expiresAt) * 1000));
    bool tokenExist = accessToken.isNotEmpty && accessToken != 'no token';
    return timeValid && tokenExist;
  }

  @override
  String toString() =>
      '{ accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt, tokenType: $tokenType }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NaverAccessToken &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt &&
          tokenType == other.tokenType;

  @override
  int get hashCode => Object.hash(
        accessToken,
        refreshToken,
        expiresAt,
        tokenType,
      );
}
