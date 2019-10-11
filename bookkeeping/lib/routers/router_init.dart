import 'package:fluro/fluro.dart';

///  abstract 接口定义 
/// 每个类都是一个接口，dart语言没有interface关键字
/// 如果使用implements某个类的话，就是将这个类的成员都看做是接口的定义
abstract class IRouterProvider {
  void initRouter(Router router);
}
