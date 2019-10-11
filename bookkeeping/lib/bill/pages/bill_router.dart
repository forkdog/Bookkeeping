import 'package:bookkeeping/routers/router_init.dart';
import 'package:fluro/fluro.dart';
import 'bill_list_page.dart';
import 'bookkeeping_page.dart';

class BillRouter implements IRouterProvider {
  static String billPage = '/bill';
  static String bookkeepPage = '/bill/bookkeep';

  @override
  void initRouter(Router router) {
    router.define(billPage, handler: Handler(handlerFunc: (_,params) => Bill()));
    router.define(bookkeepPage, handler: Handler(handlerFunc: (_,params) => Bookkeepping()));
  }
}
