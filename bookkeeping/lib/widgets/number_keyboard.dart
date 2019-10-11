import 'package:bookkeeping/res/colours.dart';
import 'package:bookkeeping/util/utils.dart';
import 'package:bookkeeping/widgets/highlight_well.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 数字回调
typedef void MyNumberCallback(String number);

/// 删除最后一位
typedef void DeleteCallback();

/// 继续记账
typedef void NextCallback();

/// 清零
typedef void ClearZeroCallback();

/// 等于
typedef void EqualCallback();

/// 保存
typedef void SaveCallback();

class MyKeyBoard extends StatefulWidget {
  const MyKeyBoard(
      {Key key,
      this.numberCallback,
      this.deleteCallback,
      this.nextCallback,
      this.clearZeroCallback,
      this.saveCallback,
      this.equalCallback,
      this.isAdd: false})
      : super(key: key);
  final MyNumberCallback numberCallback;
  final DeleteCallback deleteCallback;
  final NextCallback nextCallback;
  final ClearZeroCallback clearZeroCallback;
  final SaveCallback saveCallback;
  final EqualCallback equalCallback;
  final bool isAdd;

  @override
  State<StatefulWidget> createState() => _MyKeyBoardState();
}

class _MyKeyBoardState extends State<MyKeyBoard> {
  final double _spaceing = 0.3;
  final double _runSpacing = 0.3;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colours.gray_c,
      ),
      child: Wrap(
        spacing: _spaceing,
        runSpacing: _runSpacing,
        alignment: WrapAlignment.center,
        children: _buildItem(context),
      ),
    );
  }

  void callBack(int index) {
    int number = index < 3
        ? index + 1
        : index > 3 && index < 7
            ? index
            : index > 7 ? index - 1 : (index == 7 ? 112 : -1);
    if (number >= 0 && number < 10 ||
        number == 112 ||
        number == 12 ||
        number == 13) {
      if (number == 112) {
        widget.numberCallback('+');
      } else if (number == 12) {
        widget.numberCallback('0');
      } else if (number == 13) {
        widget.numberCallback('.');
      } else {
        widget.numberCallback('$number');
      }
    } else {
      switch (index) {
        case 3:
          // 删除
          if (widget.deleteCallback != null) {
            widget.deleteCallback();
          }
          break;
        case 11:
          // 继续
          if (widget.nextCallback != null) {
            widget.nextCallback();
          }
          break;
        case 12:
          // 清零
          if (widget.clearZeroCallback != null) {
            widget.clearZeroCallback();
          }
          break;
        case 15:
          // 保存
          if (widget.equalCallback != null && widget.saveCallback != null) {
            if (widget.isAdd) {
              widget.equalCallback();
            } else {
              widget.saveCallback();
            }
          }
          break;
        default:
      }
    }
  }

  List<Widget> _buildItem(BuildContext context) {
    double itemWidth =
        (MediaQuery.of(context).size.width - _spaceing * 3) * 0.25 - 0.01;
    double itemHeight = itemWidth * 0.65;
    return List.generate(
        16,
        (int index) => HighLightWell(
              isForeground: true,
              onTap: () {
                callBack(index);
              },
              child: Container(
                color: index == 15 ? Colours.app_main : Colors.white,
                alignment: Alignment.center,
                width: itemWidth,
                height: itemHeight,
                child: _buildSubItem(index, itemWidth),
              ),
            ));
  }

  static TextStyle _numberStyle = TextStyle(
      fontSize: ScreenUtil.getInstance().setSp(40), color: Colours.dark);

  Widget _buildSubItem(int index, double parentWidth) {
    switch (index) {
      case 3:
        return Image.asset(
          Utils.getImagePath('icons/delete_icon'),
          width: parentWidth * 0.3,
        );
        break;
      case 7:
        return Image.asset(
          Utils.getImagePath('icons/add_icon'),
          width: parentWidth * 0.3,
        );
        break;
      case 11:
        return Text(
          '继续',
          style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(30),
              color: Colours.dark),
        );
        break;
      case 12:
        return Text(
          '清零',
          style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(30),
              color: Colours.dark),
        );
        break;
      case 13:
        return Text(
          '0',
          style: _numberStyle,
        );
        break;
      case 14:
        return Text(
          '.',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil.getInstance().setSp(40),
              color: Colours.dark),
        );
        break;
      case 15:
        return Text(
          widget.isAdd ? '=' : '保存',
          style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(32),
              color: Colors.white),
        );
        break;
      default:
        return Text(
          '${index < 3 ? index + 1 : index > 3 && index < 7 ? index : index > 7 ? index - 1 : 0}',
          style: _numberStyle,
        );
    }
  }
}
