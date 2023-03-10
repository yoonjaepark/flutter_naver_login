package com.yoonjaepark.flutter_naver_login

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.AsyncTask
import android.os.Build
import android.os.Bundle
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONException
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.ExecutionException
import android.util.Log
import com.navercorp.nid.NaverIdLoginSDK
import com.navercorp.nid.oauth.NidOAuthLogin
import com.navercorp.nid.oauth.OAuthLoginCallback
import com.navercorp.nid.util.AndroidVer

/** FlutterNaverLoginPlugin */
class FlutterNaverLoginPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /** Plugin registration.  */

  private val METHOD_LOG_IN = "logIn"
  private val METHOD_LOG_OUT = "logOut"
  private val METHOD_LOG_OUT_DELETE_TOKEN = "logoutAndDeleteToken"
  private val METHOD_GET_ACCOUNT = "getCurrentAcount"

  private val METHOD_GET_TOKEN = "getCurrentAccessToken"
  private val METHOD_REFRESH_ACCESS_TOKEN_WITH_REFRESH_TOKEN = "refreshAccessTokenWithRefreshToken"

  /**
   * 네이버 개발자 등록한 client 정보를 넣어준다.
   */
  private var OAUTH_CLIENT_ID = "OAUTH_CLIENT_ID"
  private var OAUTH_CLIENT_SECRET = "OAUTH_CLIENT_SECRET"
  private var OAUTH_CLIENT_NAME = "OAUTH_CLIENT_NAME"

  private var channel: MethodChannel? = null

  // Must used this activity instead of context (flutterPluginBinding.applicationContext) to avoid AppCompat issue
  private var activity: Activity? = null
  private lateinit var launcher: ActivityResultLauncher<Intent>

  // pendingResult in login function
  // used to call flutter result in launcher
  private var pendingResult: MethodChannel.Result? = null

  private fun deleteCurrentEncryptedPreferences(applicationContext: Context) {
    val oauthLoginPrefNamePerApp = "NaverOAuthLoginEncryptedPreferenceData"
    val oldOauthLoginPrefName  = "NaverOAuthLoginPreferenceData"

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
      val preferences = applicationContext.getSharedPreferences(oauthLoginPrefNamePerApp, Context.MODE_PRIVATE)
      val edit = preferences.edit()
      edit.clear()
      edit.commit()
    } catch (e: Exception) {
      //
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_naver_login")
    channel?.setMethodCallHandler(this);

    NaverIdLoginSDK.showDevelopersLog(true)

    try {
      flutterPluginBinding.applicationContext?.packageName?.let {
        val bundle = flutterPluginBinding.applicationContext?.packageManager?.getApplicationInfo(it, PackageManager.GET_META_DATA)?.metaData

        if(bundle != null) {
          OAUTH_CLIENT_ID = bundle?.getString("com.naver.sdk.clientId").toString();
          OAUTH_CLIENT_SECRET = bundle?.getString("com.naver.sdk.clientSecret").toString();
          OAUTH_CLIENT_NAME = bundle?.getString("com.naver.sdk.clientName").toString();
          try {
            NaverIdLoginSDK.initialize(flutterPluginBinding.applicationContext, OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET, OAUTH_CLIENT_NAME);
          } catch (e: Exception) {
            try {
              deleteCurrentEncryptedPreferences(flutterPluginBinding.applicationContext)
              NaverIdLoginSDK.initialize(flutterPluginBinding.applicationContext, OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET, OAUTH_CLIENT_NAME);  
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

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
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
    this.launcher = (binding.activity as FlutterFragmentActivity).registerForActivityResult<Intent, ActivityResult>(ActivityResultContracts.StartActivityForResult()) {
      result: ActivityResult ->

      if(pendingResult != null) {
        if (result.resultCode == Activity.RESULT_OK) {
          currentAccount(pendingResult!!)
        } else if (result.resultCode == Activity.RESULT_CANCELED) {
            val errorCode = NaverIdLoginSDK.getLastErrorCode().code
            val errorDesc = NaverIdLoginSDK.getLastErrorDescription()
            pendingResult!!.success(object : HashMap<String, String>() {
              init {
                put("status", "error")
                put("errorMessage", "errorCode:$errorCode, errorDesc:$errorDesc")
              }
            })
        } else {
          pendingResult!!.success(null)
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

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      METHOD_LOG_IN -> this.login(result)
      METHOD_LOG_OUT -> this.logout(result)
      METHOD_LOG_OUT_DELETE_TOKEN -> this.logoutAndDeleteToken(result)
      METHOD_GET_TOKEN -> {
        result.success(object : HashMap<String, String>() {
          init {
            put("status", "getToken")
            NaverIdLoginSDK.getAccessToken()?.let { put("accessToken", it) }
            NaverIdLoginSDK.getRefreshToken()?.let { put("refreshToken", it) }
            put("expiresAt", NaverIdLoginSDK.getExpiresAt().toString())
            NaverIdLoginSDK.getTokenType()?.let { put("tokenType", it) }
          }
        })
      }
      METHOD_GET_ACCOUNT -> this.currentAccount(result)
      METHOD_REFRESH_ACCESS_TOKEN_WITH_REFRESH_TOKEN -> this.refreshAccessTokenWithRefreshToken(result)
      else -> result.notImplemented()
    }
  }

  fun currentAccount(result: Result) {
    val accessToken = NaverIdLoginSDK.getAccessToken()

    val task = ProfileTask()
    try {
      val res = task.execute(accessToken).get()
      val obj = JSONObject(res)
      var resultProfile = jsonObjectToMap(obj.getJSONObject("response"))
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

  private fun login(result: Result) {
    pendingResult = result

    val mOAuthLoginHandler = object : OAuthLoginCallback {
      override fun onSuccess() {
        currentAccount(result)
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

    NaverIdLoginSDK.authenticate(this.activity!!, mOAuthLoginHandler);
  }

  fun logout(result: Result) {
    NaverIdLoginSDK.logout()
    result.success(object : HashMap<String, Any>() {
      init {
        put("status", "cancelledByUser")
        put("isLogin", false)
      }
    })
  }

  fun logoutAndDeleteToken(result: Result) {
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

    NidOAuthLogin().callDeleteTokenApi(this.activity!!, mOAuthLoginHandler)
  }

  fun refreshAccessTokenWithRefreshToken(result: Result) {
    val mOAuthLoginHnadler = object : OAuthLoginCallback {
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

    NidOAuthLogin().callRefreshAccessTokenApi(this.activity!!, mOAuthLoginHnadler)
  }

  internal inner class ProfileTask : AsyncTask<String, Void, String>() {
    var result: String = "";
    override fun doInBackground(vararg arg: String): String {
      val token = arg[0]// 네이버 로그인 접근 토큰;
      val header = "Bearer $token" // Bearer 다음에 공백 추가
      try {
        val apiURL = "https://openapi.naver.com/v1/nid/me"
        val url = URL(apiURL)
        val con = url.openConnection() as HttpURLConnection
        con.requestMethod = "GET"
        con.setRequestProperty("Authorization", header)
        val responseCode = con.responseCode
        val br: BufferedReader
        if (responseCode == 200) { // 정상 호출
          br = BufferedReader(InputStreamReader(con.inputStream))
        } else {  // 에러 발생
          br = BufferedReader(InputStreamReader(con.errorStream))
        }
        val response = StringBuffer()
        val allText = br.use(BufferedReader::readText)
        result = allText
        br.close()
        println(response.toString())
      } catch (e: Exception) {
        println(e)
      }

      //result 값은 JSONObject 형태로 넘어옵니다.
      return result
    }

    override fun onPostExecute(s: String) {

    }
  }

  @Throws(JSONException::class)
  fun jsonToMap(t: String): HashMap<String, String> {
    val jObject = JSONObject(t)
    var map = jsonObjectToMap(jObject)
    return map
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
