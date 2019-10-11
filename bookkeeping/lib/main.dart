import 'dart:io';
import 'package:bookkeeping/main/main_page.dart';
import 'package:bookkeeping/res/colours.dart';
import 'package:bookkeeping/routers/application.dart';
import 'package:bookkeeping/routers/routers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  //透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
    // 初始化路由
    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        // showPerformanceOverlay: true,
        // debugShowMaterialGrid: true,
        title: '小记账',
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colours.app_main,
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(),
            cupertinoOverrideTheme: CupertinoThemeData(
              brightness: Brightness.dark,
              primaryContrastingColor: Colors.white,
              primaryColor: Colors.white,
              scaffoldBackgroundColor: Colors.white,
              barBackgroundColor: Colours.app_main,
            )),
        home: MainPage(),
      ),
      backgroundColor: Colors.black54,
      textPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      radius: 20,
      position: ToastPosition.bottom,
    );
  }
}
