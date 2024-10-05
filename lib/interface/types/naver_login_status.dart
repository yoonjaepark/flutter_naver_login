enum NaverLoginStatus {
  loggedIn,
  cancelledByUser,
  error,
  ;

  static NaverLoginStatus fromString(String status) => switch (status) {
        'loggedIn' => NaverLoginStatus.loggedIn,
        'cancelledByUser' => NaverLoginStatus.cancelledByUser,
        'error' => NaverLoginStatus.error,
        _ => throw ArgumentError('Invalid string value: $status'),
      };
}
