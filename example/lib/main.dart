import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Naver Login',
      theme: new ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF00c73c),
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';
  bool isLogin = false;

  String accesToken;

  String expiresAt;

  String tokenType;

  String name;

  String refreshToken;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Flutter Naver Login Sample',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Column(
              children: <Widget>[
                new Text('isLogin: $isLogin\n'),
                new Text('accesToken: $accesToken\n'),
                new Text('refreshToken: $refreshToken\n'),
                new Text('tokenType: $tokenType\n'),
                new Text('user: $name\n'),
              ],
            ),
            new FlatButton(
                key: null,
                onPressed: buttonLoginPressed,
                child: new Text(
                  "LogIn",
                  style: new TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Roboto"),
                )),
            new FlatButton(
                key: null,
                onPressed: buttonLogoutPressed,
                child: new Text(
                  "LogOut",
                  style: new TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Roboto"),
                )),
            new FlatButton(
                key: null,
                onPressed: buttonGetUserPressed,
                child: new Text(
                  "GetUser",
                  style: new TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Roboto"),
                ))
          ]),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterNaverLogin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> buttonLoginPressed() async {
    NaverLoginResult res = await FlutterNaverLogin.logIn();
    setState(() {
      isLogin = true;
      accesToken = res.token.accessToken;
      refreshToken = res.token.refreshToken;
      tokenType = res.token.tokenType;
    });
  }

  Future<void> buttonLogoutPressed() async {
    NaverLoginResult res = await FlutterNaverLogin.logOut();
    print('로그아웃');
    print(res.token);
    print(res.status);
  }

  Future<void> buttonGetUserPressed() async {
    NaverLoginResult res = await FlutterNaverLogin.getProfile();
    print('유저정보');
    print(res.profile.name);
    setState(() {
      name = res.profile.name;
    });
  }
}
