import 'package:bookkeeping/routers/application.dart';
import 'package:bookkeeping/routers/routers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

/// 路由跳转工具
class NavigatorUtils {
  static push(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transition = TransitionType.native}) {
    FocusScope.of(context).requestFocus(FocusNode());
    Application.router.navigateTo(context, path,
        replace: replace, clearStack: clearStack, transition: transition);
  }

  static pushResult(
      BuildContext context, String path, Function(Object) function,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transition = TransitionType.native}) {
    FocusScope.of(context).requestFocus(FocusNode());
    Application.router
        .navigateTo(context, path,
            replace: replace, clearStack: clearStack, transition: transition)
        .then((result) {
      //页面返回result为null
      if (result == null) {
        return;
      }
      function(result);
    }).catchError((error) {
      print('$error');
    });
  }

  /// 返回
  static void goBack(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.pop(context);
  }

  /// 带参数返回
  static void goBackWithParams(BuildContext context, result) {
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.pop(context, result);
  }

  /// 跳转网页
  static goWebViewPage(BuildContext context, String title, String url) {
    // fluro不支持中文，需要转换
    push(context, '${Routes.webViewPage}?title=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(url)}');
  }
}
