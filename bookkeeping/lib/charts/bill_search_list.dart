
import 'package:bookkeeping/bill/models/bill_record_group.dart';
import 'package:bookkeeping/bill/models/bill_record_response.dart';
import 'package:bookkeeping/bill/pages/bookkeeping_page.dart';
import 'package:bookkeeping/common/eventBus.dart';
import 'package:bookkeeping/db/db_helper.dart';
import 'package:bookkeeping/res/colours.dart';
import 'package:bookkeeping/res/styles.dart';
import 'package:bookkeeping/util/dateUtils.dart';
import 'package:bookkeeping/util/fluro_navigator.dart';
import 'package:bookkeeping/util/utils.dart';
import 'package:bookkeeping/widgets/app_bar.dart';
import 'package:bookkeeping/widgets/highlight_well.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';

class BillSearchList extends StatefulWidget {
  BillSearchList(this.searchCategoryName, this.year, this.month) : super();
  final searchCategoryName;
  final String year;
  final String month;

  @override
  State<StatefulWidget> createState() {
    return BillSearchListState();
  }
}

class BillSearchListState extends State<BillSearchList> {
  List _datas = List();

  // 初始化数据
  Future _initDatas() async {
    // 时间戳
    int startTime =
        DateTime(int.parse(widget.year), int.parse(widget.month), 1, 0, 0, 0, 0)
            .millisecondsSinceEpoch;
    int endTime = DateTime(
            int.parse(widget.year),
            int.parse(widget.month),
            DateUtls.getDaysNum(
                int.parse(widget.year), int.parse(widget.month)),
            23,
            59,
            59,
            999)
        .millisecondsSinceEpoch;
    dbHelp
        .getBillList(startTime, endTime,
            categoryName: widget.searchCategoryName)
        .then((models) {
      DateTime _preTime;

      /// 当天总支出金额
      double expenMoney = 0;

      /// 当日总收入
      double incomeMoney = 0;

      /// 账单记录
      List recordLsit = List();

      /// 账单记录
      List<BillRecordModel> itemList = List();

      void addAction(BillRecordModel item) {
        itemList.insert(0, item);
        if (item.type == 1) {
          // 支出
          expenMoney += item.money;
        } else {
          incomeMoney += item.money;
        }
      }

      void buildGroup() {
        recordLsit.insertAll(0, itemList);
        DateTime time =
            DateTime.fromMillisecondsSinceEpoch(itemList.first.updateTimestamp);
        String groupDate =
            '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
        BillRecordGroup group =
            BillRecordGroup(groupDate, expenMoney, incomeMoney);
        recordLsit.insert(0, group);

        // 清除重构
        expenMoney = 0;
        incomeMoney = 0;
        itemList = List();
      }

      int length = models.length;

      List.generate(length, (index) {
        BillRecordModel item = models[index];
        //格式化时间戳
        if (_preTime == null) {
          _preTime = DateTime.fromMillisecondsSinceEpoch(item.updateTimestamp);
          addAction(item);
          if (length == 1) {
            buildGroup();
          }
        } else {
          // 存在两条或以上数
          DateTime time =
              DateTime.fromMillisecondsSinceEpoch(item.updateTimestamp);
          //判断账单是不是在同一天
          if (time.year == _preTime.year &&
              time.month == _preTime.month &&
              time.day == _preTime.day) {
            //如果是同一天
            addAction(item);
            if (index == length - 1) {
              //这是最后一条数据
              buildGroup();
            }
          } else {
            //如果不是同一天 这条数据是某一条的第一条 构建上一条的组
            buildGroup();
            addAction(item);
            if (index == length - 1) {
              //这是最后一条数据
              buildGroup();
            }
          }
          _preTime = time;
        }
      });

      setState(() {
        _datas = recordLsit;
      });
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
    return Scaffold(
      appBar: MyAppBar(
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('${widget.searchCategoryName}'),
            Text(
              '${widget.year}-${widget.month}-01-${widget.year}-${widget.month}-${DateUtls.getDaysNum(int.parse(widget.year), int.parse(widget.month)).toString()}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _datas.length,
        itemBuilder: (BuildContext context, int index) {
          var model = _datas[index];
          if (model.runtimeType == BillRecordModel) {
            return _buildItem(model);
          } else {
            return _buildTimeTag(model);
          }
        },
      ),
    );
  }

  /// 构建账单
  _buildItem(BillRecordModel model) {
    return Container(
      child: HighLightWell(
          onTap: () {
            _showBottomSheet(model);
          },
          child: Stack(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset(
                          Utils.getImagePath('category/${model.image}'),
                          width: ScreenUtil.getInstance().setWidth(55),
                        ),
                        Gaps.hGap(12),
                        Text(
                          model.categoryName,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenUtil.getInstance().setSp(32),
                            color: Colours.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${Utils.formatDouble(model.money)}',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenUtil.getInstance().setSp(36),
                                color: Colours.dark),
                          ),
                        )
                      ],
                    ),
                    model.remark.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(
                                left:
                                    ScreenUtil.getInstance().setWidth(55) + 12,
                                top: 2),
                            child: Text(
                              model.remark,
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w300,
                                  fontSize: ScreenUtil.getInstance().setSp(30),
                                  color: Colours.black),
                            ),
                          )
                        : Gaps.empty,
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 0,
                bottom: 0,
                child: Gaps.line,
              )
            ],
          )),
    );
  }

  /// 构建头部日期
  Widget _buildTimeTag(BillRecordGroup group) {
    String moneyString = '';
    if (group.incomeMoney > 0) {
      moneyString = moneyString +
          '收入${Utils.formatDouble(double.parse(group.incomeMoney.toStringAsFixed(2)))}';
    }
    if (group.expenMoney > 0) {
      moneyString = moneyString +
          '${group.incomeMoney > 0 == true ? '  ' : ''}支出${Utils.formatDouble(double.parse(group.expenMoney.toStringAsFixed(2)))}';
    }

    return Container(
      color: Colours.line,
      width: double.infinity,
      child: HighLightWell(
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        Utils.getImagePath('icons/icon_calendar'),
                        width: ScreenUtil.getInstance().setWidth(28),
                      ),
                      Gaps.hGap(8),
                      Text(
                        group.date,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: ScreenUtil.getInstance().setSp(28),
                          color: Colours.dark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Text(
                      moneyString,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil.getInstance().setSp(28),
                          color: Colours.dark),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Gaps.line,
            )
          ],
        ),
      ),
    );
  }

  /// 点击item弹出详情
  _showBottomSheet(BillRecordModel model) {
    if (model == null) {
      showToast('查询错误');
      return;
    }

    final TextStyle titleStyle = TextStyle(fontSize: 16, color: Colours.black);
    final TextStyle descStyle = TextStyle(fontSize: 16, color: Colours.black);

    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    var dateTime = DateTime.fromMillisecondsSinceEpoch(model.updateTimestamp);
    String timeString = dateFormat.format(dateTime);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 60,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Text(
                        '账单详情',
                        style: TextStyle(fontSize: 18),
                      ),
                      Positioned(
                        left: 0,
                        child: HighLightWell(
                          onTap: () {
                            // 删除记录
                            dbHelp.deleteBillRecord(model.id).then((value) {
                              bus.trigger(bus.bookkeepingEventName);
                              NavigatorUtils.goBack(context);
                            });
                          },
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    color: Colours.gray_c, width: 0.5)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: Text(
                                '删除',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: HighLightWell(
                          onTap: () {
                            NavigatorUtils.goBack(context);
                            Navigator.of(context).push(new MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (_) {
                                  return Bookkeepping(
                                    recordModel: model,
                                  );
                                }));
                          },
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    color: Colours.gray_c, width: 0.5)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: Text(
                                '编辑',
                                style: TextStyle(
                                    fontSize: 16, color: Colours.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gaps.line,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: <Widget>[
                      Text('金额', style: titleStyle),
                      Gaps.hGap(20),
                      Expanded(
                        flex: 1,
                        child: Text('${Utils.formatDouble(model.money)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            )),
                      )
                    ],
                  ),
                ),
                Gaps.line,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text('分类', style: titleStyle),
                      Gaps.hGap(23),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerRight,
                          width: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                Utils.getImagePath(
                                  'category/${model.image}',
                                ),
                                width: 18,
                              ),
                              Gaps.hGap(5),
                              Text('${model.categoryName}',
                                  textAlign: TextAlign.right, style: descStyle)
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Gaps.line,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: <Widget>[
                      Text('时间', style: titleStyle),
                      Gaps.hGap(20),
                      Expanded(
                        flex: 1,
                        child: Text('$timeString',
                            textAlign: TextAlign.right, style: descStyle),
                      )
                    ],
                  ),
                ),
                Gaps.line,
                model.remark.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: <Widget>[
                            Text('备注', style: titleStyle),
                            Gaps.hGap(20),
                            Expanded(
                              flex: 1,
                              child: Text('${model.remark}',
                                  textAlign: TextAlign.right, style: descStyle),
                            )
                          ],
                        ),
                      )
                    : Gaps.empty,
                MediaQuery.of(context).padding.bottom > 0
                    ? SizedBox(
                        height: MediaQuery.of(context).padding.bottom,
                      )
                    : Gaps.empty,
              ],
            ),
          );
        });
  }
}
