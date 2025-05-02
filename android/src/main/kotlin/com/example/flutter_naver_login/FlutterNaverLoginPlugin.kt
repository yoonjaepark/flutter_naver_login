package com.example.flutter_naver_login

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.NidOAuthLogin
import com.navercorp.nid.oauth.OAuthLoginCallback
import com.navercorp.nid.util.AndroidVer
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONException
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.ExecutionException

/// 네이버 로그인 상태를 나타내는 열거형
enum class NaverLoginStatus(val value: String) {
    LOGGED_IN("loggedIn"),
    LOGGED_OUT("loggedOut"),
    ERROR("error")
}

/// Flutter 플러그인 메서드를 나타내는 열거형
enum class FlutterPluginMethod {
    InitSdk,
    LogIn,
    LogOut,
    LogOutAndDeleteToken,
    GetCurrentAccount,
    GetCurrentAccessToken,
    RefreshAccessTokenWithRefreshToken,
    IsLoggedIn,
    Unknown;

    companion object {
        fun fromMethodName(methodName: String): FlutterPluginMethod {
            return when (methodName) {
                "initSdk" -> InitSdk
                "logIn" -> LogIn
                "logOut" -> LogOut
                "logoutAndDeleteToken" -> LogOutAndDeleteToken
                "getCurrentAccount", "getCurrentAcount" -> GetCurrentAccount // 오타 지원
                "getCurrentAccessToken" -> GetCurrentAccessToken
                "refreshAccessTokenWithRefreshToken" -> RefreshAccessTokenWithRefreshToken
                "isLoggedIn" -> IsLoggedIn
                else -> Unknown
            }
        }
    }
}

/** FlutterNaverLoginPlugin */
class FlutterNaverLoginPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    /// The MethodChannel that will facilitate communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private val mainScope = CoroutineScope(Dispatchers.Main)

    // Must use this activity instead of context (flutterPluginBinding.applicationContext) to avoid AppCompat issue
    private var activity: Activity? = null
    private lateinit var launcher: ActivityResultLauncher<Intent>
    private lateinit var context: Context

    // pendingResult in login function
    // used to call flutter result in launcher
    private var pendingResult: Result? = null

    // MARK: - FlutterPlugin

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_naver_login")
        channel.setMethodCallHandler(this)

        NaverIdLoginSDK.showDevelopersLog(true)

        try {
            context.packageName?.let { packageName ->
                val bundle = context.packageManager?.getApplicationInfo(
                    packageName,
                    PackageManager.GET_META_DATA
                )?.metaData

                if (bundle != null) {
                    val clientId = bundle.getString("com.naver.sdk.clientId")
                    val clientSecret = bundle.getString("com.naver.sdk.clientSecret")
                    val clientName = bundle.getString("com.naver.sdk.clientName")

                    println("=== Naver Login Plugin Registration ===")
                    println("ClientID: $clientId")
                    println("ClientSecret: $clientSecret")
                    println("ClientName: $clientName")
                    println("===================================")

                    if (clientId != null && clientSecret != null && clientName != null) {
                        try {
                            NaverIdLoginSDK.initialize(context, clientId, clientSecret, clientName)
                            println("Naver Login SDK initialized successfully on plugin registration")
                        } catch (e: Exception) {
                            try {
                                deleteCurrentEncryptedPreferences(context)
                                NaverIdLoginSDK.initialize(context, clientId, clientSecret, clientName)
                                println("Naver Login SDK initialized successfully after clearing preferences")
                            } catch (e: Exception) {
                                e.printStackTrace()
                                println("Failed to initialize Naver Login SDK: ${e.message}")
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            println("Error reading AndroidManifest.xml meta-data: ${e.message}")
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // MARK: - ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        launcher = (binding.activity as FlutterFragmentActivity).registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { result: ActivityResult ->
            if (pendingResult != null) {
                when (result.resultCode) {
                    Activity.RESULT_OK -> {
                        mainScope.launch {
                            getCurrentAccount(pendingResult!!)
                        }
                    }
                    Activity.RESULT_CANCELED -> {
                        val errorCode = NaverIdLoginSDK.getLastErrorCode().code
                        val errorDesc = NaverIdLoginSDK.getLastErrorDescription()

                        // 사용자 취소인지 확인
                        if (errorCode == "user_cancel" || errorDesc?.contains("cancel") == true) {
                            sendResult(NaverLoginStatus.LOGGED_OUT, null, null, pendingResult!!)
                        } else {
                            pendingResult!!.success(object : HashMap<String, String>() {
                                init {
                                    put("status", "error")
                                    put("errorMessage", "errorCode:$errorCode, errorDesc:$errorDesc")
                                }
                            })
                        }
                    }
                    else -> {
                        pendingResult!!.success(null)
                    }
                }
            }
            pendingResult = null
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    // MARK: - MethodCallHandler

    override fun onMethodCall(call: MethodCall, result: Result) {
        println("🔥 Called method: ${call.method}")

        when (FlutterPluginMethod.fromMethodName(call.method)) {
            FlutterPluginMethod.InitSdk -> {
                @Suppress("UNCHECKED_CAST") val args = call.arguments as Map<String, String?>
                val clientId = args["clientId"] as String
                val clientName = args["clientName"] as String
                val clientSecret = args["clientSecret"] as String
                initSdk(result, clientId, clientName, clientSecret)
            }
            FlutterPluginMethod.LogIn -> login(result)
            FlutterPluginMethod.LogOut -> logout(result)
            FlutterPluginMethod.LogOutAndDeleteToken -> logoutAndDeleteToken(result)
            FlutterPluginMethod.GetCurrentAccessToken -> getCurrentAccessToken(result)
            FlutterPluginMethod.GetCurrentAccount -> {
                mainScope.launch {
                    getCurrentAccount(result)
                }
            }
            FlutterPluginMethod.RefreshAccessTokenWithRefreshToken -> refreshAccessTokenWithRefreshToken(result)
            FlutterPluginMethod.IsLoggedIn -> isLoggedIn(result)
            FlutterPluginMethod.Unknown -> result.notImplemented()
        }
    }

    // MARK: - Private Methods

    private fun initSdk(result: Result, clientId: String, clientName: String, clientSecret: String) {
        try {
            NaverIdLoginSDK.showDevelopersLog(true)

            println("Init SDK")
            println("- clientId: $clientId")
            println("- clientName: $clientName")
            println("- clientSecret: $clientSecret")

            NaverIdLoginSDK.initialize(context, clientId, clientSecret, clientName)
            sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)

        } catch (e: Exception) {
            e.printStackTrace()

            try {
                deleteCurrentEncryptedPreferences()
                println("- try again sdk init")
                NaverIdLoginSDK.initialize(context, clientId, clientSecret, clientName)
                sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)
            } catch (e: Exception) {
                e.printStackTrace()
                result.error(
                    e.javaClass.simpleName,
                    "NaverIdLoginSDK.initialize failed. message: " + e.localizedMessage,
                    null
                )
            }
        }
    }

    private suspend fun getCurrentAccount(result: Result) {
        // SDK 초기화 상태 확인
        try {
            val state = NaverIdLoginSDK.getState()
        } catch (e: Exception) {
            sendError("SDK not initialized. Please call initSdk first.", result)
            return
        }

        val accessToken = NaverIdLoginSDK.getAccessToken()

        if (accessToken == null) {
            sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)
            return
        }

        try {
            val res = getUserInfo(accessToken)
            val obj = JSONObject(res)
            val account = jsonObjectToMap(obj.getJSONObject("response"))
            sendResult(NaverLoginStatus.LOGGED_IN, null, account, result)
        } catch (e: InterruptedException) {
            e.printStackTrace()
            sendError("Failed to get user info: ${e.message}", result)
        } catch (e: ExecutionException) {
            e.printStackTrace()
            sendError("Failed to get user info: ${e.message}", result)
        } catch (e: JSONException) {
            e.printStackTrace()
            sendError("Failed to parse user info: ${e.message}", result)
        }
    }

    private fun deleteCurrentEncryptedPreferences(applicationContext: Context) {
        val oauthLoginPrefNamePerApp = "NaverOAuthLoginEncryptedPreferenceData"
        val oldOauthLoginPrefName = "NaverOAuthLoginPreferenceData"

        if (Build.VERSION.SDK_INT >= AndroidVer.API_24_NOUGAT) {
            try {
                println("- try clear old oauth login prefs")
                applicationContext.deleteSharedPreferences(oldOauthLoginPrefName)
            } catch (e: Exception) {
                //
            }
        }

        try {
            println("- try clear shared oauth login prefs")
            val preferences = applicationContext.getSharedPreferences(
                oauthLoginPrefNamePerApp,
                Context.MODE_PRIVATE
            )
            val edit = preferences.edit()
            edit.clear()
            edit.apply() // commit() 대신 apply() 사용
        } catch (e: Exception) {
            //
        }
    }

    // https://github.com/naver/naveridlogin-sdk-android/pull/63/files
    private fun deleteCurrentEncryptedPreferences() {
        val oauthLoginPrefNamePerApp = "NaverOAuthLoginEncryptedPreferenceData"
        val oldOauthLoginPrefName = "NaverOAuthLoginPreferenceData"

        if (Build.VERSION.SDK_INT >= AndroidVer.API_24_NOUGAT) {
            try {
                println("- try clear old oauth login prefs")
                context.deleteSharedPreferences(oldOauthLoginPrefName)
            } catch (e: Exception) {
                //
            }
        }

        try {
            println("- try clear shared oauth login prefs")
            val preferences = context.getSharedPreferences(
                oauthLoginPrefNamePerApp,
                Context.MODE_PRIVATE
            )
            val edit = preferences.edit()
            edit.clear()
            edit.apply() // commit() 대신 apply() 사용
        } catch (e: Exception) {
            //
        }
    }

    private fun login(result: Result) {
        // SDK 초기화 상태 확인
        try {
            val state = NaverIdLoginSDK.getState()
            println("Current SDK state: $state")
        } catch (e: Exception) {
            sendError("SDK not initialized. Please call initSdk first.", result)
            return
        }

        pendingResult = result

        // 기존 토큰이 있다면 먼저 삭제 (user_cancel 문제 방지)
        try {
            if (NaverIdLoginSDK.getAccessToken() != null) {
                println("Existing token found, logging out first")
                NaverIdLoginSDK.logout()
            }
        } catch (e: Exception) {
            // 토큰 체크 실패는 무시하고 계속 진행
            println("Token check failed: ${e.message}")
        }

        val mOAuthLoginHandler = object : OAuthLoginCallback {
            override fun onSuccess() {
                mainScope.launch {
                    getCurrentAccount(result)
                }
            }

            override fun onFailure(httpStatus: Int, message: String) {
                val errorCode = NaverIdLoginSDK.getLastErrorCode().code
                val errorDesc = NaverIdLoginSDK.getLastErrorDescription()

                // 사용자 취소인지 확인
                if (errorCode == "user_cancel" || errorDesc?.contains("cancel") == true) {
                    sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)
                } else {
                    result.success(object : HashMap<String, String>() {
                        init {
                            put("status", "error")
                            put("errorMessage", "errorCode:$errorCode, errorDesc:$errorDesc")
                        }
                    })
                }
                // Already handled result. We don't need this at the ActivityResult as pending status
                pendingResult = null
            }

            override fun onError(errorCode: Int, message: String) {
                // 사용자 취소인지 확인
                if (message.contains("user_cancel") || message.contains("cancel")) {
                    sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)
                } else {
                    onFailure(errorCode, message)
                }
                pendingResult = null
            }
        }

        activity?.let {
            NaverIdLoginSDK.authenticate(it, mOAuthLoginHandler)
        } ?: run {
            sendError("Activity is null", result)
            pendingResult = null
        }
    }

    private fun logout(result: Result) {
        try {
            NaverIdLoginSDK.logout()
        } catch (e: Exception) {
            /**
            Firebase Crasylytics error workaround

            ArrayDecoders.decodeUnknownField
            com.google.crypto.tink.shaded.protobuf.c0 - Protocol message contained an invalid tag (zero).
             */
            e.printStackTrace()
        } finally {
            sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)
        }
    }

    private fun logoutAndDeleteToken(result: Result) {
        val mOAuthLoginHandler = object : OAuthLoginCallback {
            override fun onSuccess() {
                sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)
            }

            override fun onFailure(httpStatus: Int, message: String) {
                // 서버에서 token 삭제에 실패했어도 클라이언트에 있는 token 은 삭제되어 로그아웃된 상태이다
                // 실패했어도 클라이언트 상에 token 정보가 없기 때문에 추가적으로 해줄 수 있는 것은 없음
                val errorCode = NaverIdLoginSDK.getLastErrorCode().code
                val errorDesc = NaverIdLoginSDK.getLastErrorDescription()
                result.success(object : HashMap<String, String>() {
                    init {
                        put("status", "error")
                        put("errorMessage", "errorCode:$errorCode, errorDesc:$errorDesc")
                    }
                })
            }

            override fun onError(errorCode: Int, message: String) {
                onFailure(errorCode, message)
            }
        }

        NidOAuthLogin().callDeleteTokenApi(mOAuthLoginHandler)
    }

    private fun getCurrentAccessToken(result: Result) {
        println("🔥 handleGetCurrentAccessToken")

        // SDK 초기화 상태 확인
        try {
            val state = NaverIdLoginSDK.getState()
        } catch (e: Exception) {
            sendError("SDK not initialized. Please call initSdk first.", result)
            return
        }

        val accessToken = NaverIdLoginSDK.getAccessToken()
        val refreshToken = NaverIdLoginSDK.getRefreshToken()
        val expiresAt = NaverIdLoginSDK.getExpiresAt()
        val tokenType = NaverIdLoginSDK.getTokenType()

        if (accessToken == null) {
            sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)
            return
        }

        val tokenInfo = mapOf(
            "accessToken" to accessToken,
            "refreshToken" to (refreshToken ?: ""),
            "tokenType" to (tokenType ?: "bearer"),
            "expiresAt" to formatExpiresAt(expiresAt)
        )

        sendResult(NaverLoginStatus.LOGGED_IN, tokenInfo, null, result)
    }

    private fun refreshAccessTokenWithRefreshToken(result: Result) {
        val refreshToken = NaverIdLoginSDK.getRefreshToken()
        if (refreshToken == null) {
            sendError("No refresh token available", result)
            return
        }

        val mOAuthLoginHandler = object : OAuthLoginCallback {
            override fun onSuccess() {
                val accessToken = NaverIdLoginSDK.getAccessToken()
                val newRefreshToken = NaverIdLoginSDK.getRefreshToken()
                val expiresAt = NaverIdLoginSDK.getExpiresAt()
                val tokenType = NaverIdLoginSDK.getTokenType()

                if (accessToken != null) {
                    val tokenInfo = mapOf(
                        "accessToken" to accessToken,
                        "refreshToken" to (newRefreshToken ?: ""),
                        "tokenType" to (tokenType ?: "bearer"),
                        "expiresAt" to formatExpiresAt(expiresAt)
                    )
                    sendResult(NaverLoginStatus.LOGGED_IN, tokenInfo, null, result)
                } else {
                    sendError("Failed to get refreshed access token", result)
                }
            }

            override fun onFailure(httpStatus: Int, message: String) {
                val errorCode = NaverIdLoginSDK.getLastErrorCode().code
                val errorDescription = NaverIdLoginSDK.getLastErrorDescription()
                result.success(object : HashMap<String, String>() {
                    init {
                        put("status", "error")
                        put("errorMessage", "errorCode:$errorCode, errorDesc:$errorDescription")
                    }
                })
            }

            override fun onError(errorCode: Int, message: String) {
                onFailure(errorCode, message)
            }
        }

        NidOAuthLogin().callRefreshAccessTokenApi(mOAuthLoginHandler)
    }

    private fun isLoggedIn(result: Result) {
        // SDK 초기화 상태 확인
        try {
            val state = NaverIdLoginSDK.getState()
        } catch (e: Exception) {
            sendError("SDK not initialized. Please call initSdk first.", result)
            return
        }

        val accessToken = NaverIdLoginSDK.getAccessToken()
        if (accessToken != null) {
            sendResult(NaverLoginStatus.LOGGED_IN, null, null, result)
        } else {
            sendResult(NaverLoginStatus.LOGGED_OUT, null, null, result)
        }
    }

    // MARK: - Helper Methods

    private suspend fun getUserInfo(token: String): String = withContext(Dispatchers.IO) {
        val header = "Bearer $token"
        try {
            val apiURL = "https://openapi.naver.com/v1/nid/me"
            val url = URL(apiURL)
            val con = url.openConnection() as HttpURLConnection
            con.requestMethod = "GET"
            con.setRequestProperty("Authorization", header)
            val responseCode = con.responseCode
            val br: BufferedReader = if (responseCode == 200) {
                BufferedReader(InputStreamReader(con.inputStream))
            } else {
                BufferedReader(InputStreamReader(con.errorStream))
            }
            val response = br.use(BufferedReader::readText)
            br.close()
            response
        } catch (e: Exception) {
            e.printStackTrace()
            ""
        }
    }

    private fun formatExpiresAt(expiresAt: Long): String {
        val date = Date(expiresAt * 1000) // 초를 밀리초로 변환
        val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
        formatter.timeZone = TimeZone.getTimeZone("UTC")
        return formatter.format(date)
    }

    @Throws(JSONException::class)
    fun jsonObjectToMap(jObject: JSONObject): HashMap<String, String> {
        val map = HashMap<String, String>()
        val keys = jObject.keys()

        while (keys.hasNext()) {
            val key = keys.next() as String
            val value = jObject.getString(key)
            map[key] = value
        }
        return map
    }

    // MARK: - Result Handling

    private fun sendResult(
        status: NaverLoginStatus,
        accessToken: Map<String, Any>? = null,
        account: Map<String, String>? = null,
        result: Result
    ) {
        val resultMap = mutableMapOf<String, Any>("status" to status.value.lowercase())

        accessToken?.let { resultMap["accessToken"] = it }
        account?.let { resultMap["account"] = it }

        result.success(resultMap)
    }

    private fun sendError(message: String, result: Result) {
        val errorInfo = mapOf(
            "status" to NaverLoginStatus.ERROR.value.lowercase(),
            "errorMessage" to message
        )

        result.success(errorInfo)
    }
}