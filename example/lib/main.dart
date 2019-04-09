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
  bool isLogin = false;

  String accesToken;

  String expiresAt;

  String tokenType;

  String name;

  String refreshToken;

  @override
  void initState() {
    super.initState();
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
                onPressed: buttonTokenPressed,
                child: new Text(
                  "GetToken",
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

  Future<void> buttonLoginPressed() async {
    NaverLoginResult res = await FlutterNaverLogin.logIn();
    setState(() {
      name = res.account.nickname;
      isLogin = true;
    });
  }

  Future<void> buttonTokenPressed() async {
    NaverAccessToken res = await FlutterNaverLogin.currentAccessToken;
    setState(() {
      accesToken = res.accessToken;
      tokenType = res.tokenType;
    });
  }

  Future<void> buttonLogoutPressed() async {
    FlutterNaverLogin.logOut();
    setState(() {
      isLogin = false;
      accesToken = null;
      tokenType = null;
      name = null;
    });
  }

  Future<void> buttonGetUserPressed() async {
    NaverAccountResult res = await FlutterNaverLogin.currentAccount();
    setState(() {
      name = res.name;
    });
  }
}
