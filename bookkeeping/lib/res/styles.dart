import 'package:flutter/material.dart';
import 'colours.dart';
import 'font.dart';

class TextStyles {
  static const TextStyle textGray14 = TextStyle(
    fontSize: Font.font_sp14,
    color: Colours.gray,
  );

  static const TextStyle textWhite18 = TextStyle(
    fontSize: Font.font_sp18,
    color: Colors.white,
  );

  static const TextStyle textWhite16 = TextStyle(
    fontSize: Font.font_sp16,
    color: Colors.white,
  );

  static const TextStyle textWhite14 = TextStyle(
    fontSize: Font.font_sp14,
    color: Colors.white,
  );
}

/// 间隔
class Gaps {
  /// 水平间隔
  static Widget hGap(double gap) {
    return SizedBox(width: gap);
  }

  /// 垂直间隔
  static Widget vGap(double gap) {
    return SizedBox(height: gap);
  }

  /// 水平划线
  static Widget hGapLine({double gap = 0.6, Color bgColor = Colours.gray_c}) {
    return Container(
      width: gap,
      color: bgColor,
    );
  }

  /// 竖直划线
  static Widget vGapLine({double gap = 0.6, Color bgColor = Colours.gray_c}) {
    return Container(
      height: gap,
      color: bgColor,
    );
  }

  static Widget line = Container(height: 0.6, color: Colours.line);
  static const Widget empty = SizedBox();
}
