import 'package:flutter/foundation.dart';
import 'package:flutter_naver_login/interface/types/naver_access_token.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

@immutable
class NaverLoginResult {
  final NaverLoginStatus status;
  final NaverAccountResult account;
  final String errorMessage;
  final NaverAccessToken accessToken;

  const NaverLoginResult({
    required this.status,
    required this.account,
    required this.errorMessage,
    required this.accessToken,
  });

  factory NaverLoginResult.fromMap(Map<String, dynamic> map) =>
      NaverLoginResult(
        status: NaverLoginStatus.fromString(map['status'] ?? ''),
        accessToken: NaverAccessToken.fromMap(map),
        errorMessage: map['errorMessage'] ?? '',
        account: NaverAccountResult.fromMap(map),
      );

  @override
  String toString() =>
      '{ status: $status, account: $account, errorMessage: $errorMessage, accessToken: $accessToken }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NaverLoginResult &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          account == other.account &&
          errorMessage == other.errorMessage &&
          accessToken == other.accessToken;

  @override
  int get hashCode => Object.hash(
        status,
        account,
        errorMessage,
        accessToken,
      );
}
