import 'package:bookkeeping/routers/routers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'application.dart';

/// fluro的路由跳转工具类
class NavigatorUtils {
  /// 普通跳转
  static push(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transitionType = TransitionType.native}) {
    FocusScope.of(context).requestFocus(new FocusNode());
    Application.router.navigateTo(context, path,
        replace: replace, clearStack: clearStack, transition: transitionType);
  }

  /// 跳转带返回结果
  static pushResult(
      BuildContext context, String path, Function(Object) function,
      {bool replace = false, bool clearStack = false}) {
    FocusScope.of(context).requestFocus(new FocusNode());
    Application.router
        .navigateTo(context, path,
            replace: replace,
            clearStack: clearStack,
            transition: TransitionType.native)
        .then((result) {
      // 页面返回result为null
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
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
  }

  /// 返回带参数
  static void goBackWithParams(BuildContext context, result) {
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context, result);
  }

  /// 跳到WebView页
  static goWebViewPage(BuildContext context, String title, String url) {
    //fluro 不支持传中文,需转换
    push(context,
        '${Routes.webViewPage}?title=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(url)}');
  }
}
