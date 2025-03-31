package com.yoonjaepark.flutter_naver_login

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
import java.util.concurrent.ExecutionException

/** FlutterNaverLoginPlugin */
class FlutterNaverLoginPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /**
     * 네이버 개발자 등록한 client 정보를 넣어준다.
     */
    private var oAuthClientId = "OAUTH_CLIENT_ID"
    private var oAuthClientSecret = "OAUTH_CLIENT_SECRET"
    private var oAuthClientName = "OAUTH_CLIENT_NAME"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private var channel: MethodChannel? = null

    private val mainScope = CoroutineScope(Dispatchers.Main)

    // Must used this activity instead of context (flutterPluginBinding.applicationContext) to avoid AppCompat issue
    private var activity: Activity? = null
    private lateinit var launcher: ActivityResultLauncher<Intent>
    private var _applicationContext: Context? = null
    private val applicationContext get() = _applicationContext!!

    // pendingResult in login function
    // used to call flutter result in launcher
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        _applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_naver_login")
        channel?.setMethodCallHandler(this)

        NaverIdLoginSDK.showDevelopersLog(true)

        try {
            flutterPluginBinding.applicationContext.packageName?.let {
                val bundle =
                    flutterPluginBinding.applicationContext.packageManager?.getApplicationInfo(
                        it,
                        PackageManager.GET_META_DATA
                    )?.metaData

                if (bundle != null) {
                    oAuthClientId = bundle.getString("com.naver.sdk.clientId").toString()
                    oAuthClientSecret = bundle.getString("com.naver.sdk.clientSecret").toString()
                    oAuthClientName = bundle.getString("com.naver.sdk.clientName").toString()
                    try {
                        // FIXME: should method call initSdk
                        NaverIdLoginSDK.initialize(
                            flutterPluginBinding.applicationContext,
                            oAuthClientId,
                            oAuthClientSecret,
                            oAuthClientName
                        )
                    } catch (e: Exception) {
                        try {
                            deleteCurrentEncryptedPreferences(flutterPluginBinding.applicationContext)
                            NaverIdLoginSDK.initialize(
                                flutterPluginBinding.applicationContext,
                                oAuthClientId,
                                oAuthClientSecret,
                                oAuthClientName
                            )
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        _applicationContext = null
        channel?.setMethodCallHandler(null)
        channel = null
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_naver_login")
            channel.setMethodCallHandler(FlutterNaverLoginPlugin())
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        this.launcher =
            (binding.activity as FlutterFragmentActivity).registerForActivityResult<Intent, ActivityResult>(
                ActivityResultContracts.StartActivityForResult()
            ) { result: ActivityResult ->

                if (pendingResult != null) {
                    when (result.resultCode) {
                        Activity.RESULT_OK -> {
                            mainScope.launch {
                                getCurrentAccount(
                                    pendingResult!!
                                )
                            }
                        }

                        Activity.RESULT_CANCELED -> {
                            val errorCode = NaverIdLoginSDK.getLastErrorCode().code
                            val errorDesc = NaverIdLoginSDK.getLastErrorDescription()
                            pendingResult!!.success(object : HashMap<String, String>() {
                                init {
                                    put("status", "error")
                                    put(
                                        "errorMessage",
                                        "errorCode:$errorCode, errorDesc:$errorDesc"
                                    )
                                }
                            })
                        }

                        else -> {
                            pendingResult!!.success(null)
                        }
                    }
                }
                pendingResult = null
            }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (FlutterPluginMethod.fromMethodName(call.method)) {
            FlutterPluginMethod.InitSdk -> {
                @Suppress("UNCHECKED_CAST") val args = call.arguments as Map<String, String?>
                val clientId = args["clientId"] as String
                val clientName = args["clientName"] as String
                val clientSecret = args["clientSecret"] as String
                this.initSdk(result, clientId, clientName, clientSecret)
            }

            FlutterPluginMethod.LogIn -> this.login(result)
            FlutterPluginMethod.LogOut -> this.logout(result)
            FlutterPluginMethod.LogOutAndDeleteToken -> this.logoutAndDeleteToken(result)
            FlutterPluginMethod.GetCurrentAccessToken -> this.getCurrentAccessToken(result)

            FlutterPluginMethod.GetCurrentAccount -> {
                mainScope.launch {
                    getCurrentAccount(result)
                }
            }

            FlutterPluginMethod.RefreshAccessTokenWithRefreshToken -> this.refreshAccessTokenWithRefreshToken(
                result
            )

            else -> result.notImplemented()
        }
    }

    private fun initSdk(
        result: Result,
        clientId: String,
        clientName: String,
        clientSecret: String
    ) {
        try {
            NaverIdLoginSDK.showDevelopersLog(true)

            println("Init SDK")
            println("- clientId: $clientId")
            println("- clientName: $clientName")
            println("- clientSecret: $clientSecret")

            NaverIdLoginSDK.initialize(applicationContext, clientId, clientSecret, clientName)
            result.success(true)

        } catch (e: Exception) {
            e.printStackTrace()

            try {
                deleteCurrentEncryptedPreferences()
                println("- try again sdk init")
                NaverIdLoginSDK.initialize(applicationContext, clientId, clientSecret, clientName)
                result.success(true)
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

    suspend fun getCurrentAccount(result: Result) {
        val accessToken = NaverIdLoginSDK.getAccessToken()

        try {
            val res = getUserInfo(accessToken ?: "")
            val obj = JSONObject(res)
            val resultProfile = jsonObjectToMap(obj.getJSONObject("response"))
            resultProfile["status"] = "loggedIn"
            result.success(resultProfile)
        } catch (e: InterruptedException) {
            e.printStackTrace()
        } catch (e: ExecutionException) {
            e.printStackTrace()
        } catch (e: JSONException) {
            e.printStackTrace()
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
            edit.apply()
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
            edit.apply()
        } catch (e: Exception) {
            //
        }
    }

    private fun login(result: Result) {
        pendingResult = result

        val mOAuthLoginHandler = object : OAuthLoginCallback {
            override fun onSuccess() {
                mainScope.launch {
                    getCurrentAccount(result)
                }
            }

            override fun onFailure(httpStatus: Int, message: String) {
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
        NaverIdLoginSDK.authenticate(this.activity!!, mOAuthLoginHandler)
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
            result.success(object : HashMap<String, Any>() {
                init {
                    put("status", "cancelledByUser")
                    put("isLogin", false)
                }
            })
        }
    }

    private fun logoutAndDeleteToken(result: Result) {
        val mOAuthLoginHandler = object : OAuthLoginCallback {
            override fun onSuccess() {
                result.success(object : HashMap<String, Any>() {
                    init {
                        put("status", "cancelledByUser")
                        put("isLogin", false)
                    }
                })
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
        val info = HashMap<String, String>().apply {
            put("status", "getToken")
            NaverIdLoginSDK.getAccessToken()?.let { put("accessToken", it) }
            NaverIdLoginSDK.getRefreshToken()?.let { put("refreshToken", it) }
            put("expiresAt", NaverIdLoginSDK.getExpiresAt().toString())
            NaverIdLoginSDK.getTokenType()?.let { put("tokenType", it) }
        }

        result.success(info)
    }

    private fun refreshAccessTokenWithRefreshToken(result: Result) {
        val mOAuthLoginHandler = object : OAuthLoginCallback {
            override fun onSuccess() {
                result.success(true)
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
}
