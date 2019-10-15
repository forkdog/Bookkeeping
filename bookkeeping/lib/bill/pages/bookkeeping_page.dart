import 'package:bookkeeping/bill/models/bill_record_response.dart';
import 'package:bookkeeping/bill/models/category_model.dart';
import 'package:bookkeeping/common/eventBus.dart';
import 'package:bookkeeping/db/db_helper.dart';
import 'package:bookkeeping/res/colours.dart';
import 'package:bookkeeping/res/styles.dart';
import 'package:bookkeeping/routers/fluro_navigator.dart';
import 'package:bookkeeping/util/utils.dart';
import 'package:bookkeeping/widgets/app_bar.dart';
import 'package:bookkeeping/widgets/highlight_well.dart';
import 'package:bookkeeping/widgets/input_textview_dialog.dart';
import 'package:bookkeeping/widgets/number_keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Bookkeepping extends StatefulWidget {
  const Bookkeepping({Key key, this.recordModel}) : super(key: key);
  final BillRecordModel recordModel;

  @override
  State<StatefulWidget> createState() => _BookkeeppingState();
}

class _BookkeeppingState extends State<Bookkeepping>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  AnimationController _tapItemController;
  String _remark = '';
  DateTime _time;
  String _dateString = '';
  String _numberString = '';
  bool _isAdd = false;

  /// 支出类别数组
  List<CategoryItem> _expenObjects = List();

  /// 收入类别数组
  List<CategoryItem> _inComeObjects = List();

  TabController _tabController;

  /// tabs
  final List<Tab> tabs = <Tab>[
    Tab(
      text: '支出',
    ),
    Tab(
      text: '收入',
    )
  ];

  /// 获取支出类别数据
  Future<void> _loadExpenDatas() async {
    dbHelp.getInitialExpenCategory().then((list) {
      List<CategoryItem> models =
          list.map((i) => CategoryItem.fromJson(i)).toList();
      if (_expenObjects.length > 0) {
        _expenObjects.removeRange(0, _expenObjects.length);
      }
      _expenObjects.addAll(models);

      if (widget.recordModel != null && widget.recordModel.type == 1) {
        _selectedIndexLeft = _expenObjects
            .indexWhere((item) => item.name == widget.recordModel.categoryName);
      }

      setState(() {});
    });
  }

  Future<void> _loadIncomeDatas() async {
    dbHelp.getInitialIncomeCategory().then((list) {
      List<CategoryItem> models =
          list.map((i) => CategoryItem.fromJson(i)).toList();
      if (_inComeObjects.length > 0) {
        _inComeObjects.removeRange(0, _inComeObjects.length);
      }
      _inComeObjects.addAll(models);

      if (widget.recordModel != null && widget.recordModel.type == 2) {
        _selectedIndexRight = _inComeObjects
            .indexWhere((item) => item.name == widget.recordModel.categoryName);
      }

      setState(() {});
    });
  }

  void _updateInitData() {
    if (widget.recordModel != null) {
      _time = DateTime.fromMillisecondsSinceEpoch(
          widget.recordModel.updateTimestamp);
      DateTime now = DateTime.now();
      if (_time.year == now.year &&
          _time.month == now.month &&
          _time.day == now.day) {
        _dateString = '今天 ${_time.hour}:${_time.minute}';
      } else if (_time.year != now.year) {
        _dateString =
            '${_time.year}-${_time.month.toString().padLeft(2, '0')}-${_time.day.toString().padLeft(2, '0')} ${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
      } else {
        _dateString =
            '${_time.month.toString().padLeft(2, '0')}-${_time.day.toString().padLeft(2, '0')} ${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
      }

      if (widget.recordModel.remark.isNotEmpty) {
        _remark = widget.recordModel.remark;
      }

      if (widget.recordModel.money != null) {
        _numberString = Utils.formatDouble(double.parse(_numberString = widget.recordModel.money.toStringAsFixed(2)));
      }

      if (widget.recordModel.type == 2) {
        _tabController.index = 1;
      }
    } else {
      _time = DateTime.now();
      _dateString = '今天 ${_time.hour}:${_time.minute}';
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              //动画执行结束时反向执行动画
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              //动画恢复到初始状态时执行动画（正向）
              _animationController.forward();
            }
          });
    // 启动动画
    _animationController.forward();

    _tapItemController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              //动画执行结束 反向动画
              _tapItemController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              //动画恢复到初始状态 停止掉
              _tapItemController.stop();
            }
          });

    _updateInitData();
    _loadExpenDatas();
    _loadIncomeDatas();
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    _tapItemController.stop();
    _tapItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        // centerTitle: true,
        titleWidget: TabBar(
          // tabbar菜单
          controller: _tabController,
          tabs: tabs,
          indicatorColor: Colours.app_main,
          unselectedLabelColor: Colours.app_main.withOpacity(0.8),
          labelColor: Colours.app_main,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          indicatorWeight: 1, // 下划线高度
          isScrollable: true, // 是否可以滑动
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 18),
          child: Icon(
            Icons.close,
            color: Colours.app_main,
          ),
          onPressed: () {
            NavigatorUtils.goBack(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: false, // 默认true键盘弹起不遮挡
      body: _buildBody(),
    );
  }

  /// body
  _buildBody() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildExpenCategory(),
                _buildIncomeCategory(),
              ],
            ),
          ),
          HighLightWell(
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return TextViewDialog(
                      confirm: (text) {
                        setState(() {
                          _remark = text;
                        });
                      },
                    );
                  });
            },
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  alignment: Alignment.center,
                  height: 44,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _remark.isEmpty ? '备注...' : _remark,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: ScreenUtil.getInstance().setSp(28),
                              color: _remark.isEmpty
                                  ? Colours.gray
                                  : Colours.black),
                        ),
                      )
                    ],
                  ),
                )),
          ),
          Gaps.vGap(3),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: HighLightWell(
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        theme: DatePickerTheme(
                            doneStyle: TextStyle(
                                fontSize: 16, color: Colours.app_main),
                            cancelStyle:
                                TextStyle(fontSize: 16, color: Colours.gray)),
                        locale: LocaleType.zh, onConfirm: (date) {
                      _time = date;
                      DateTime now = DateTime.now();
                      if (_time.year == now.year &&
                          _time.month == now.month &&
                          _time.day == now.day) {
                        _dateString = '今天 ${_time.hour}:${_time.minute}';
                      } else if (_time.year != now.year) {
                        _dateString =
                            '${_time.year}-${_time.month.toString().padLeft(2, '0')}-${_time.day.toString().padLeft(2, '0')} ${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
                      } else {
                        _dateString =
                            '${_time.month.toString().padLeft(2, '0')}-${_time.day.toString().padLeft(2, '0')} ${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
                      }
                      setState(() {});
                    });
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colours.gray, width: 0.6)),
                    child: Text(_dateString),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    _numberString.isEmpty ? '0.0' : _numberString,
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(48),
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget child) {
                  return Container(
                    margin: const EdgeInsets.only(right: 14),
                    width: 2,
                    height: ScreenUtil.getInstance().setSp(40),
                    decoration: BoxDecoration(
                        color: Colours.app_main
                            .withOpacity(0.8 * _animationController.value)),
                  );
                },
              ),
            ],
          ),
          Gaps.vGap(10),
          Gaps.vGapLine(gap: 0.3),
          MyKeyBoard(
            isAdd: _isAdd,
            // 键盘输入
            numberCallback: (number) => inputVerifyNumber(number),
            // 删除
            deleteCallback: () {
              if (_numberString.length > 0) {
                setState(() {
                  _numberString =
                      _numberString.substring(0, _numberString.length - 1);
                });
              }
            },
            // 清除
            clearZeroCallback: () {
              _clearZero();
            },
            // 等于
            equalCallback: () {
              setState(() {
                _addNumber();
              });
            },
            //继续
            nextCallback: () {
              if (_isAdd == true) {
                _addNumber();
              }
              _record();
              _clearZero();
              setState(() {});
            },
            // 保存
            saveCallback: () {
              _record();
              NavigatorUtils.goBack(context);
            },
          ),
          MediaQuery.of(context).padding.bottom > 0
              ? Gaps.vGapLine(gap: 0.3)
              : Gaps.empty,
        ],
      ),
    );
  }

  /// 相加
  void _addNumber() {
    _isAdd = false;
    List<String> numbers = _numberString.split('+');
    double number = 0.0;
    for (String item in numbers) {
      if (item.isEmpty == false) {
        number += double.parse(item);
      }
    }
    String numberString = number.toString();
    if (numberString.split('.').last == '0') {
      numberString = numberString.substring(0, numberString.length - 2);
    }
    _numberString = numberString;
  }

  /// 记账保存
  void _record() {
    if (_numberString.isEmpty || _numberString == '0.') {
      return;
    }

    _isAdd = false;
    CategoryItem item;
    if (_tabController.index == 0) {
      item = _expenObjects[_selectedIndexLeft];
    } else {
      item = _inComeObjects[_selectedIndexRight];
    }

    BillRecordModel model = BillRecordModel(
        widget.recordModel != null ? widget.recordModel.id : null,
        double.parse(_numberString),
        _remark,
        _tabController.index + 1,
        item.name,
        item.image,
        DateTime.fromMillisecondsSinceEpoch(_time.millisecondsSinceEpoch)
            .toString(),
        _time.millisecondsSinceEpoch,
        DateTime.fromMillisecondsSinceEpoch(_time.millisecondsSinceEpoch)
            .toString(),
        _time.millisecondsSinceEpoch);

    dbHelp.insertBillRecord(model).then((value) {
      bus.trigger(bus.bookkeepingEventName);
    });
  }

  /// 清零
  void _clearZero() {
    setState(() {
      _isAdd = false;
      _numberString = '';
    });
  }

  /// 选中index
  int _selectedIndexLeft = 0;

  /// 支出构建
  _buildExpenCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GridView.builder(
        key: PageStorageKey<String>("0"), //保存状态
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
            mainAxisSpacing: 0,
            crossAxisSpacing: 8),
        itemCount: _expenObjects.length,
        itemBuilder: (context, index) {
          return _getCategoryItem(
              _expenObjects[index], index, _selectedIndexLeft);
        },
      ),
    );
  }

  /// 选中index
  int _selectedIndexRight = 0;

  /// 收入构建
  _buildIncomeCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GridView.builder(
        key: PageStorageKey<String>("1"), //保存状态
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
            mainAxisSpacing: 0,
            crossAxisSpacing: 8),
        itemCount: _inComeObjects.length,
        itemBuilder: (context, index) {
          return _getCategoryItem(
              _inComeObjects[index], index, _selectedIndexRight);
        },
      ),
    );
  }

  /// 构建类别item
  _getCategoryItem(CategoryItem item, int index, selectedIndex) {
    return GestureDetector(
      onTap: () {
        if (_tabController.index == 0) {
          //左边支出类别
          if (_selectedIndexLeft != index) {
            _selectedIndexLeft = index;
            _tapItemController.forward();
            setState(() {});
          }
        } else {
          //右边收入类别
          if (_selectedIndexRight != index) {
            _selectedIndexRight = index;
            _tapItemController.forward();
            setState(() {});
          }
        }
      },
      child: AnimatedBuilder(
        animation: _tapItemController,
        builder: (BuildContext context, Widget child) {
          return ClipOval(
            child: Container(
              color: selectedIndex == index ? Colours.app_main : Colors.white,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    Utils.getImagePath('category/${item.image}'),
                    width: selectedIndex == index
                        ? ScreenUtil.getInstance()
                            .setWidth(60 + _tapItemController.value * 6)
                        : ScreenUtil.getInstance().setWidth(50),
                    color: selectedIndex == index ? Colors.white : Colors.black,
                  ),
                  Gaps.vGap(3),
                  Text(
                    item.name,
                    style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.white
                            : Colours.black,
                        fontSize: selectedIndex == index
                            ? ScreenUtil.getInstance()
                                .setSp(25 + 3 * _tapItemController.value)
                            : ScreenUtil.getInstance().setSp(25)),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 键盘输入验证
  void inputVerifyNumber(String number) {
    //小数点精确分，否则不能输入
    //加法
    if (_numberString.isEmpty) {
      //没输入的时候，不能输入+或者.
      if (number == '+') {
        return;
      }

      if (number == '.') {
        setState(() {
          _numberString += '0.';
        });
        return;
      }

      setState(() {
        _numberString += number;
      });
    } else {
      List<String> numbers = _numberString.split('');
      if (numbers.length == 1) {
        // 当只有一个数字
        if (numbers.first == '0') {
          //如果第一个数字是0，那么输入其他数字和+不生效
          if (number == '.') {
            setState(() {
              _numberString += number;
            });
          } else if (number != '+') {
            setState(() {
              _numberString = number;
            });
          }
        } else {
          //第一个数字不是0 为1-9
          setState(() {
            if (number == '+') {
              _isAdd = true;
            }
            _numberString += number;
          });
        }
      } else {
        List<String> temps = _numberString.split('+');
        if (temps.last.isEmpty && number == '+') {
          //加号
          return;
        }

        //拿到最后一个数字
        String lastNumber = temps.last;
        List<String> lastNumbers = lastNumber.split('.');
        if (lastNumbers.last.isEmpty && number == '.') {
          return;
        }
        if (lastNumbers.length > 1 &&
            lastNumbers.last.length >= 2 &&
            number != '+') {
          return;
        }

        setState(() {
          if (number == '+') {
            _isAdd = true;
          }
          _numberString += number;
        });
      }
    }
  }
}
