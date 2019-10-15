import 'package:bookkeeping/charts/bill_search_list.dart';
import 'package:bookkeeping/common/eventBus.dart';
import 'package:bookkeeping/db/db_helper.dart';
import 'package:bookkeeping/res/colours.dart';
import 'package:bookkeeping/res/styles.dart';
import 'package:bookkeeping/util/dateUtils.dart';
import 'package:bookkeeping/util/utils.dart';
import 'package:bookkeeping/widgets/app_bar.dart';
import 'package:bookkeeping/widgets/calendar_page.dart';
import 'package:bookkeeping/widgets/highlight_well.dart';
import 'package:bookkeeping/widgets/state_layout.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

class Charts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChartState();
  }
}

class ChartState extends State<StatefulWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  //保存状态
  bool get wantKeepAlive => true;

  /// 类型 1支出 2收入
  int _type = 1;

  /// 当月总支出金额
  double _monthExpenMoney = 0.0;

  /// 当月总收入
  double _monthIncomeMoney = 0.0;

  List<charts.Series<ChartItemModel, int>> _expendChartDatas = List();
  List<charts.Series<ChartItemModel, int>> _incomeChartDatas = List();

  List<ChartItemModel> _datas = List();

  String _year = "${DateTime.now().year}";
  String _month = "${DateTime.now().month.toString().padLeft(2, '0')}";

  Future<void> _initDatas() async {
    // 时间戳
    int startTime = DateTime(int.parse(_year), int.parse(_month), 1, 0, 0, 0, 0)
        .millisecondsSinceEpoch;
    int endTime = DateTime(
            int.parse(_year),
            int.parse(_month),
            DateUtls.getDaysNum(int.parse(_year), int.parse(_month)),
            23,
            59,
            59,
            999)
        .millisecondsSinceEpoch;
    dbHelp.getBillList(startTime, endTime).then((list) {
      _monthExpenMoney = 0.0;
      _monthIncomeMoney = 0.0;
      Map map = Map();
      list.forEach((item) {
        if (item.type == 1) {
          // 支出
          _monthExpenMoney += item.money;
        } else if (item.type == 2) {
          // 收入
          _monthIncomeMoney += item.money;
        }

        if (item.type == _type) {
          map[item.categoryName] = null;
        }
      });

      List<ChartItemModel> chartItems = List();
      int index = 1;
      map.keys.forEach((key) {
        // 查找相同分类的账单
        var items = list.where((item) => item.categoryName == key);

        double money = 0.0;
        items.forEach((item) {
          money += item.money;
        });

        String image = items.first.image ?? '';

        double ratio =
            money / (_type == 1 ? _monthExpenMoney : _monthIncomeMoney);
        ChartItemModel itemModel =
            ChartItemModel(index, key, image, money, ratio, items.length);
        chartItems.add(itemModel);
        index += 1;
      });

      _datas = chartItems;
      // 排序
      _datas.sort((left, right) => right.money.compareTo(left.money));

      if (_type == 1) {
        _expendChartDatas = [
          new charts.Series<ChartItemModel, int>(
            id: 'Sales',
            domainFn: (ChartItemModel item, _) => item.id,
            measureFn: (ChartItemModel item, _) => item.money,
            data: chartItems,
            overlaySeries: true,
            labelAccessorFn: (ChartItemModel item, _) =>
                '${item.categoryName} ${Utils.formatDouble(double.parse((item.ratio * 100).toStringAsFixed(2)))}%',
          ),
        ];
      } else {
        _incomeChartDatas = [
          new charts.Series<ChartItemModel, int>(
            id: 'Sales',
            domainFn: (ChartItemModel item, _) => item.id,
            measureFn: (ChartItemModel item, _) => item.money,
            data: chartItems,
            overlaySeries: true,
            labelAccessorFn: (ChartItemModel item, _) =>
                '${item.categoryName} ${Utils.formatDouble(double.parse((item.ratio * 100).toStringAsFixed(2)))}%',
          ),
        ];
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    _initDatas();

    // 订阅监听
    bus.add(bus.bookkeepingEventName, (arg) {
      _initDatas();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: MyAppBar(
        titleWidget: _buildAppBarTitle(),
        isBack: false,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.only(top: 15),
            sliver: SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                        value: _type == 1,
                        onChanged: (value) {
                          _seletedType(1);
                        },
                      ),
                      HighLightWell(
                        onTap: () {
                          _seletedType(1);
                        },
                        child: Text(
                          '支出¥${Utils.formatDouble(double.parse(_monthExpenMoney.toStringAsFixed(2)))}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Gaps.hGap(10),
                      Checkbox(
                        value: _type == 2,
                        onChanged: (value) {
                          _seletedType(2);
                        },
                      ),
                      HighLightWell(
                        onTap: () {
                          _seletedType(2);
                        },
                        child: Text(
                          '收入¥${Utils.formatDouble(double.parse(_monthIncomeMoney.toStringAsFixed(2)))}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    // color: Colors.red,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.4,
                    child: OverflowBox(
                        minWidth: MediaQuery.of(context).size.width,
                        child: charts.PieChart(
                            _type == 1 ? _expendChartDatas : _incomeChartDatas,
                            animate: true,
                            defaultRenderer: charts.ArcRendererConfig(
                                arcRendererDecorators: [
                                  charts.ArcLabelDecorator(
                                    labelPosition: charts.ArcLabelPosition.auto,
                                  ),
                                ]))),
                  ),
                ]);
              }, childCount: 1),
            ),
          ),
          _datas.length > 0
              ? SliverPadding(
                  padding: const EdgeInsets.only(top: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return HighLightWell(
                        child: _buildItem(index),
                      );
                    }, childCount: _datas.length),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil.getInstance().setHeight(120)),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return const StateLayout(
                        hintText: '没有账单~',
                      );
                    }, childCount: 1),
                  ),
                ),
        ],
      ),
    );
  }

  void _seletedType(int type) {
    _type = type;
    _initDatas();
  }

  /// 设置appbartitleView
  _buildAppBarTitle() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          HighLightWell(
            child: SizedBox(
              width: 35,
              height: 35,
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
            ),
            onTap: () {
              int month = int.parse(_month);
              if (month <= 1) {
                int year = int.parse(_year);
                if (year <= 1971) {
                  showToast('1971年是最小年份');
                } else {
                  _month = '12';
                  _year = (year - 1).toString();
                  _initDatas();
                }
              } else {
                _month = (month - 1).toString().padLeft(2, '0');
                _initDatas();
              }
            },
          ),
          ButtonTheme(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: FlatButton(
              child: Text(
                '$_year-$_month',
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(34),
                    color: Colours.app_main),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return CalendarMonthDialog(
                      checkTap: (year, month) {
                        if (_year != year || _month != month) {
                          _year = year;
                          _month = month;
                          _initDatas();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          HighLightWell(
            child: SizedBox(
              width: 35,
              height: 35,
              child: Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            ),
            onTap: () {
              int month = int.parse(_month);
              if (month >= 12) {
                int year = int.parse(_year);
                if (year >= 2055) {
                  showToast('2055年是最大年份');
                } else {
                  _month = '01';
                  _year = (year + 1).toString();
                  _initDatas();
                }
              } else {
                _month = (month + 1).toString().padLeft(2, '0');
                _initDatas();
              }
            },
          ),
        ],
      ),
    );
  }

  _buildItem(int index) {
    ChartItemModel model = _datas[index];
    return HighLightWell(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
          return BillSearchList(model.categoryName, _year, _month);
        }));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            border: Border(
                top: index == 0
                    ? BorderSide(width: 0.6, color: Colours.line)
                    : BorderSide(width: 0.00001, color: Colors.white),
                bottom: BorderSide(width: 0.6, color: Colours.line))),
        child: Row(
          children: <Widget>[
            Image.asset(
              Utils.getImagePath('category/${model.image}'),
              width: ScreenUtil.getInstance().setWidth(55),
            ),
            Gaps.hGap(ScreenUtil.getInstance().setWidth(32)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model.categoryName,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(32),
                      color: Colours.dark),
                ),
                Text(
                  '${Utils.formatDouble(double.parse((model.ratio * 100).toStringAsFixed(2)))}% ${model.number}笔',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenUtil.getInstance().setSp(24),
                      color: Colours.normalBlack),
                )
              ],
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${Utils.formatDouble(model.money)}',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                maxLines: 1,
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(36),
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartItemModel {
  final int id;
  final String categoryName;
  final String image;
  final double money;
  final double ratio;
  final int number;
  ChartItemModel(this.id, this.categoryName, this.image, this.money, this.ratio,
      this.number);
}
