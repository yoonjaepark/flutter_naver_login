enum FlutterPluginMethod {
  logIn('logIn'),
  logOut('logOut'),
  logOutAndDeleteToken('logoutAndDeleteToken'),
  currentAccount('getCurrentAccount'),
  currentAccessToken('getCurrentAccessToken'),
  refreshAccessTokenWithRefreshToken('refreshAccessTokenWithRefreshToken'),
  ;

  final String method;

  const FlutterPluginMethod(this.method);
}
