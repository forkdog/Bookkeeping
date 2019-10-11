import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key key}): super(key:key);
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

/*
抽屉菜单Drawer
Scaffold的drawer和endDrawer属性可以分别接受一个Widget作为页面的左、右抽屉菜单，
如果开发者提供了抽屉菜单，那么当用户手指从屏幕左/右向里滑动时便可打开抽屉菜单
*/
class _MyDrawerState extends State<MyDrawer> {
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        child: Container(
          
        ),
      ),
    );
  }
}
