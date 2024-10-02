package com.yoonjaepark.flutter_naver_login

sealed class FlutterPluginMethod(val methodName: String) {
    data object InitSdk : FlutterPluginMethod("initSdk")
    data object LogIn : FlutterPluginMethod("logIn")
    data object LogOut : FlutterPluginMethod("logOut")
    data object LogOutAndDeleteToken : FlutterPluginMethod("logoutAndDeleteToken")
    data object GetCurrentAccount : FlutterPluginMethod("getCurrentAccount")
    data object GetCurrentAccessToken : FlutterPluginMethod("getCurrentAccessToken")
    data object RefreshAccessTokenWithRefreshToken :
        FlutterPluginMethod("refreshAccessTokenWithRefreshToken")

    companion object {
        fun fromMethodName(name: String?): FlutterPluginMethod? {
            return when (name) {
                InitSdk.methodName -> InitSdk
                LogIn.methodName -> LogIn
                LogOut.methodName -> LogOut
                LogOutAndDeleteToken.methodName -> LogOutAndDeleteToken
                GetCurrentAccount.methodName -> GetCurrentAccount
                GetCurrentAccessToken.methodName -> GetCurrentAccessToken
                RefreshAccessTokenWithRefreshToken.methodName -> RefreshAccessTokenWithRefreshToken
                else -> null
            }
        }
    }
}