import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Naver Login',
      scaffoldMessengerKey: snackbarKey,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF00c73c),
        canvasColor: const Color(0xFFfafafa),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 12.0,
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontFamily: "Roboto",
            ),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLogin = false;
  String? accessToken;
  String? expiresAt;
  String? tokenType;
  String? name;
  String? refreshToken;

  /// Show [error] content in a ScaffoldMessenger snackbar
  void _showSnackError(String error) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(error.toString())),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Naver Login Sample',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        children: [
          Column(
            children: [
              Text('isLogin: $isLogin\n'),
              Text('accessToken: $accessToken\n'),
              Text('refreshToken: $refreshToken\n'),
              Text('tokenType: $tokenType\n'),
              Text('user: $name\n'),
            ],
          ),
          ElevatedButton(
            onPressed: buttonLoginPressed,
            child: const Text("LogIn"),
          ),
          ElevatedButton(
            onPressed: buttonLogoutPressed,
            child: const Text("LogOut"),
          ),
          ElevatedButton(
            onPressed: buttonLogoutAndDeleteTokenPressed,
            child: const Text("LogOutAndDeleteToken"),
          ),
          ElevatedButton(
            onPressed: buttonTokenPressed,
            child: const Text("GetToken"),
          ),
          ElevatedButton(
            onPressed: buttonGetUserPressed,
            child: const Text("GetUser"),
          ),
        ],
      ),
    );
  }

  Future<void> buttonLoginPressed() async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      setState(() {
        name = res.account?.nickname;
        accessToken = res.accessToken?.accessToken;
        refreshToken = res.accessToken?.refreshToken;
        tokenType = res.accessToken?.tokenType;
        expiresAt = res.accessToken?.expiresAt;
        isLogin = res.status == NaverLoginStatus.loggedIn;
      });
    } catch (error) {
      _showSnackError(error.toString());
    }
  }

  Future<void> buttonTokenPressed() async {
    try {
      final NaverLoginResult res =
          await FlutterNaverLogin.getCurrentAccessToken();
      setState(() {
        refreshToken = res.accessToken?.refreshToken;
        accessToken = res.accessToken?.accessToken;
        tokenType = res.accessToken?.tokenType;
        expiresAt = res.accessToken?.expiresAt;
        isLogin = res.status == NaverLoginStatus.loggedIn;
      });
    } catch (error) {
      _showSnackError(error.toString());
    }
  }

  Future<void> buttonLogoutPressed() async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logOut();
      if (res.status == NaverLoginStatus.loggedOut) {
        setState(() {
          isLogin = false;
          accessToken = null;
          refreshToken = null;
          tokenType = null;
          expiresAt = null;
          name = null;
        });
      }
    } catch (error) {
      _showSnackError(error.toString());
    }
  }

  Future<void> buttonLogoutAndDeleteTokenPressed() async {
    try {
      final NaverLoginResult res =
          await FlutterNaverLogin.logOutAndDeleteToken();
      print("🔥 buttonLogoutAndDeleteTokenPressed: $res");
      if (res.status == NaverLoginStatus.loggedOut) {
        setState(() {
          isLogin = false;
          accessToken = null;
          refreshToken = null;
          tokenType = null;
          expiresAt = null;
          name = null;
        });
      }
    } catch (error) {
      _showSnackError(error.toString());
    }
  }

  Future<void> buttonGetUserPressed() async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.getCurrentAccount();
      setState(() => name = res.account?.name);
    } catch (error) {
      _showSnackError(error.toString());
    }
  }
}
