import 'package:bookkeeping/widgets/state_layout.dart';
import 'package:flutter/material.dart';

class WidgetNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StateLayout(
        hintText: '页面不存在',
      ),
    );
  }
}
