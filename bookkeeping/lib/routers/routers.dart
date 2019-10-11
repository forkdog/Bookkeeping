import 'package:bookkeeping/bill/pages/bill_router.dart';
import 'package:bookkeeping/routers/router_init.dart';
import 'package:bookkeeping/widgets/404.dart';
import 'package:bookkeeping/widgets/webview_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Routes {
  static String webViewPage = '/webView';
  static List<IRouterProvider> _listRouter = [];

  static void configureRoutes(Router router) {
    /// 指定路由跳转错误返回页
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      debugPrint('未找到目标页');
      return WidgetNotFound();
    });

    router.define(webViewPage, handler: Handler(handlerFunc: (_, params) {
      String title = params['title']?.first;
      String url = params['url']?.first;
      return WebViewPage(title: title, url: url);
    }));

    /// 各自路由由各自模块管理，统一在此初始化
    _listRouter.clear();
    _listRouter.add(BillRouter());
    
    /// 初始化路由
    _listRouter.forEach((routerProvider) {
      routerProvider.initRouter(router);
    });
  }
}
