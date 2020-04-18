package com.yoonjaepark.flutter_naver_login

import android.app.Activity
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.AsyncTask
import android.os.Bundle
import androidx.annotation.NonNull;
import com.nhn.android.naverlogin.OAuthLogin
import com.nhn.android.naverlogin.OAuthLoginHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONException
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.ExecutionException

/** FlutterNaverLoginPlugin */
class FlutterNaverLoginPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /** Plugin registration.  */

  private val METHOD_LOG_IN = "logIn"
  private val METHOD_LOG_OUT = "logOut"
  private val METHOD_GET_ACCOUNT = "getCurrentAcount"

  private val METHOD_GET_TOKEN = "getCurrentAccessToken"

  /**
   * 네이버 개발자 등록한 client 정보를 넣어준다.
   */
  private var OAUTH_CLIENT_ID = "OAUTH_CLIENT_ID"
  private var OAUTH_CLIENT_SECRET = "OAUTH_CLIENT_SECRET"
  private var OAUTH_CLIENT_NAME = "OAUTH_CLIENT_NAME"
  private var registrar: Registrar? = null

  private var mOAuthLoginInstance: OAuthLogin? = null
  private var currentActivity: Activity? = null
  private var mContext: Context? = null
  private var methodChannel: MethodChannel? = null

  private var ai: ApplicationInfo? = null
  private var e: String? = null
  private var bundle: Bundle? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val instance = FlutterNaverLoginPlugin()
      instance.registrar = registrar
      instance.onAttachedToEngine(registrar.context(), registrar.messenger())
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    onAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
  }

  private fun onAttachedToEngine(applicationContext: Context, binaryMessenger: BinaryMessenger) {
    mOAuthLoginInstance = OAuthLogin.getInstance()
    mOAuthLoginInstance?.showDevelopersLog(true)
    mContext = applicationContext
    methodChannel = MethodChannel(binaryMessenger, "flutter_naver_login")
    methodChannel?.setMethodCallHandler(this)
    try {
      e = mContext?.packageName;

      ai = mContext?.packageManager?.getApplicationInfo(e, PackageManager.GET_META_DATA)

      bundle = ai?.metaData;

      if(bundle != null) {
        OAUTH_CLIENT_ID = bundle?.getString("com.naver.sdk.clientId").toString();
        OAUTH_CLIENT_SECRET = bundle?.getString("com.naver.sdk.clientSecret").toString();
        OAUTH_CLIENT_NAME = bundle?.getString("com.naver.sdk.clientName").toString();
        mOAuthLoginInstance?.showDevelopersLog(true);
        mOAuthLoginInstance?.init(mContext, OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET, OAUTH_CLIENT_NAME);
      }

    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    setActivity(binding.getActivity());
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    setActivity(binding.getActivity())
  }

  override fun onDetachedFromActivityForConfigChanges() {
    setActivity(null);
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
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

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      METHOD_LOG_IN -> this.login(result)
      METHOD_LOG_OUT -> this.logout(result)
      METHOD_GET_TOKEN -> {
        result.success(object : HashMap<String, String>() {
          init {
            put("status", "getToken")
            mOAuthLoginInstance?.getAccessToken(mContext)?.let { put("accessToken", it) }
            put("expiresAt", mOAuthLoginInstance?.getExpiresAt(mContext).toString())
            mOAuthLoginInstance?.getTokenType(mContext)?.let { put("tokenType", it) }
          }
        })
      }
      METHOD_GET_ACCOUNT -> this.currentAccount(result)
      else -> result.notImplemented()
    }
  }

  // Only access activity with this method.
  private fun getActivity(): Activity? {
    return if (registrar != null) registrar!!.activity() else currentActivity
  }

  private fun setActivity(activity: Activity?) {
    currentActivity = activity
  }

  fun currentAccount(result: Result) {
    val accessToken = mOAuthLoginInstance?.getAccessToken(mContext)

    val task = ProfileTask()
    try {
      val res = task.execute(accessToken).get()
      val obj = JSONObject(res)
      var resultProfile = jsonToMap(obj.getString("response"))
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
    val mOAuthLoginHandler = object : OAuthLoginHandler() {
      override fun run(success: Boolean) {
        if (success) {
          currentAccount(result)
        } else {
          val errorCode = mOAuthLoginInstance?.getLastErrorCode(mContext)?.code
          val errorDesc = mOAuthLoginInstance?.getLastErrorDesc(mContext)
          result.success(object : HashMap<String, String>() {
            init {
              put("status", "error")
              put("errorMessage", "errorCode:$errorCode, errorDesc:$errorDesc")
            }
          })
        }
      }
    }
    mOAuthLoginInstance?.startOauthLoginActivity(this.getActivity(), mOAuthLoginHandler)
  }

  fun logout(result: Result) {
    var isSuccessDeleteToken = DeleteTokenTask().execute().get();

    if (isSuccessDeleteToken) {
      result.success(object : HashMap<String, Any>() {
        init {
          put("status", "cancelledByUser")
          put("isLogin", false)
        }
      })
    } else {
      // 서버에서 token 삭제에 실패했어도 클라이언트에 있는 token 은 삭제되어 로그아웃된 상태이다
      // 실패했어도 클라이언트 상에 token 정보가 없기 때문에 추가적으로 해줄 수 있는 것은 없음
      val errorCode = mOAuthLoginInstance?.getLastErrorCode(mContext)?.code
      val errorDesc = mOAuthLoginInstance?.getLastErrorDesc(mContext)
      result.success(object : HashMap<String, String>() {
        init {
          put("status", "error")
          put("errorMessage", "errorCode:$errorCode, errorDesc:$errorDesc")
        }
      })
    }
  }

  private inner class DeleteTokenTask : AsyncTask<Void, Void, Boolean>() {
    override fun doInBackground(vararg arg: Void): Boolean? {
      val isSuccessDeleteToken = mOAuthLoginInstance?.logoutAndDeleteToken(mContext)

      return isSuccessDeleteToken
    }
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

    val map = HashMap<String, String>()
    val jObject = JSONObject(t)
    val keys = jObject.keys()

    while (keys.hasNext()) {
      val key = keys.next() as String
      val value = jObject.getString(key)
      map[key] = value
    }
    return map
  }
}
