package com.example.flutter_naver_login

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.OAuthLoginCallback

class FlutterNaverLoginPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_naver_login")
        channel.setMethodCallHandler(this)

        // TODO: 여기에 실제 값으로 바꾸세요
        val clientId = "YOUR_CLIENT_ID"
        val clientSecret = "YOUR_CLIENT_SECRET"
        val appName = "YOUR_APP_NAME"

        NaverIdLoginSDK.initialize(context, clientId, clientSecret, appName)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "logIn" -> handleLogin(result)
            "logOut" -> handleLogout(result)
            else -> result.notImplemented()
        }
    }

    private fun handleLogin(result: Result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is null", null)
            return
        }

        pendingResult = result

        NaverIdLoginSDK.authenticate(activity!!, object : OAuthLoginCallback {
            override fun onSuccess() {
                val accessToken = NaverIdLoginSDK.getAccessToken()
                val refreshToken = NaverIdLoginSDK.getRefreshToken()
                val expiresAt = NaverIdLoginSDK.getExpiresAt()
                val tokenType = NaverIdLoginSDK.getTokenType()

                val tokenInfo = mapOf(
                    "accessToken" to (accessToken ?: ""),
                    "refreshToken" to (refreshToken ?: ""),
                    "expiresAt" to expiresAt.toString(),
                    "tokenType" to (tokenType ?: "bearer")
                )

                result.success(
                    mapOf(
                        "status" to "loggedIn",
                        "accessToken" to tokenInfo
                    )
                )
                pendingResult = null
            }

            override fun onFailure(httpStatus: Int, message: String) {
                result.success(
                    mapOf(
                        "status" to "error",
                        "errorMessage" to "httpStatus:$httpStatus, message:$message"
                    )
                )
                pendingResult = null
            }

            override fun onError(errorCode: Int, message: String) {
                onFailure(errorCode, message)
            }
        })
    }

    private fun handleLogout(result: Result) {
        try {
            NaverIdLoginSDK.logout()
            result.success(
                mapOf(
                    "status" to "loggedOut"
                )
            )
        } catch (e: Exception) {
            result.success(
                mapOf(
                    "status" to "error",
                    "errorMessage" to e.localizedMessage
                )
            )
        }
    }
}