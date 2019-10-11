import 'dart:convert';
import 'dart:io';
import 'package:bookkeeping/bill/models/bill_record_group.dart';
import 'package:bookkeeping/bill/models/bill_record_response.dart';
import 'package:bookkeeping/bill/models/budget_model.dart';
import 'package:bookkeeping/bill/models/category_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

var dbHelp = new Dbhelper();

class Dbhelper {
  // 单例
  Dbhelper._internal();

  static Dbhelper _singleton = new Dbhelper._internal();

  factory Dbhelper() => _singleton;

  Database _db;

  /// 账单表
  final _billTableName = 'BillRecord';

  /// 支出类别表
  final _initialExpenCategory = 'initialExpenCategory';

  /// 收入类别表
  final _initialIncomeCategory = 'initialIncomeCategory';

  /// 每月预算表
  final _budgetTableName = 'Budget';

  /// 获取数据库
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _initDb();
    return _db;
  }

  _initDb() async {
    Directory document = await getApplicationDocumentsDirectory();
    String path = join(document.path, 'AccountDb', 'Account.db');
    debugPrint(path);
    var db = await openDatabase(path, version: 2, onCreate: _onCreate);
    return db;
  }

  /// When creating the db, create the table type 1支出 2收入
  void _onCreate(Database db, int version) async {
    // 账单记录表
    //是否同步 是否删除 金额、备注、类型 1支出 2收入 、 类别名、图片路径、创建时间、更新时间
    String queryBill = """
    CREATE TABLE $_billTableName(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      money REAL NOT NULL,
      remark TEXT,
      categoryName TEXT NOT NULL,
      image TEXT NOT NULL,
      type INTEGER DEFAULT(1),
      isSync INTEGER DEFAULT(0),
      isDelete INTEGER DEFAULT(0),
      createTime TEXT,
      createTimestamp INTEGER,
      updateTime TEXT,
      updateTimestamp INTEGER
    )
    """;
    await db.execute(queryBill);

    // 支出类别表
    String queryStringExpen = """
    CREATE TABLE $_initialExpenCategory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      image TEXT,
      sort INTEGER
    )
    """;
    await db.execute(queryStringExpen);

    // 收入类别表
    String queryStringIncome = """
    CREATE TABLE $_initialIncomeCategory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      image TEXT,
      sort INTEGER
    )
    """;
    await db.execute(queryStringIncome);

    // 初始化支出类别表数据
    rootBundle
        .loadString('assets/data/initialExpenCategory.json')
        .then((value) {
      List list = jsonDecode(value);
      List<CategoryItem> models =
          list.map((i) => CategoryItem.fromJson(i)).toList();
      models.forEach((item) async {
        await db.insert(_initialExpenCategory, item.toJson());
      });
    });

    // 初始化收入类别表数据
    rootBundle
        .loadString('assets/data/initialIncomeCategory.json')
        .then((value) {
      List list = jsonDecode(value);
      List<CategoryItem> models =
          list.map((i) => CategoryItem.fromJson(i)).toList();
      models.forEach((item) async {
        await db.insert(_initialIncomeCategory, item.toJson());
      });
    });

    /// 创建预算表
    String queryStringBudget = """
    CREATE TABLE $_budgetTableName(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      yearMonth TEXT UNIQUE NOT NULL,
      budget REAL DEFAULT(0),
      isOpen INTEGER DEFAULT(0)
    )
    """;
    await db.execute(queryStringBudget);
  }

  /// 获取记账支出类别列表
  Future<List> getInitialExpenCategory() async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery('SELECT * FROM $_initialExpenCategory ORDER BY sort ASC');
    return result.toList();
  }

  /// 获取记账收入类别列表
  Future<List> getInitialIncomeCategory() async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery('SELECT * FROM $_initialIncomeCategory ORDER BY sort ASC');
    return result.toList();
  }

  /// 插入或者更新账单记录
  Future<int> insertBillRecord(BillRecordModel model) async {
    var dbClient = await db;
    var now = DateTime.now();
    String nowTime =
        DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch)
            .toString();
    //这里不要使用Map 声明map
    var map = {
      'money': model.money,
      'remark': model.remark,
      'type': model.type,
      'categoryName': model.categoryName,
      'image': model.image,
      'createTime': model.createTime != null ? model.createTime : nowTime,
      'createTimestamp': model.createTimestamp != null
          ? model.createTimestamp
          : now.millisecondsSinceEpoch,
      'updateTime': model.updateTime != null ? model.updateTime : nowTime,
      'updateTimestamp': model.updateTimestamp != null
          ? model.updateTimestamp
          : now.millisecondsSinceEpoch,
    };
    var result;
    try {
      if (model.id == null) {
        result = await dbClient.insert(_billTableName, map);
      } else {
        result = await dbClient.update(_billTableName, map,
            where: 'id == ${model.id}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  //SELECT * FROM BillRecord WHERE DATETIME(updateTime) >= DATETIME('2019-08-29') and DATETIME(updateTime) <= DATETIME('2019-08-29 23:59')
  //SELECT * FROM BillRecord WHERE updateTimestamp >= 1567094400000 and updateTimestamp <= 1567180799999
  /// 查询账单记录 13位时间戳
  Future<BillRecordMonth> getBillRecordMonth(int startTime, int endTime) async {
    //DESC ASC
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        "SELECT * FROM $_billTableName WHERE isDelete == 0 AND updateTimestamp >= $startTime and updateTimestamp <= $endTime ORDER BY updateTimestamp ASC, id ASC");
    List list = result.toList();
    List<BillRecordModel> models =
        list.map((i) => BillRecordModel.fromJson(i)).toList();

    DateTime bugdgetTime = DateTime.fromMillisecondsSinceEpoch(startTime);
    var budgetModel = await querybudget(
        '${bugdgetTime.year}-${bugdgetTime.month.toString().padLeft(2, '0')}');

    DateTime _preTime;

    /// 当天总支出金额
    double expenMoney = 0;

    /// 当日总收入
    double incomeMoney = 0;

    /// 当月总支出金额
    double monthExpenMoney = 0;

    /// 当月总收入
    double monthIncomeMoney = 0;

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

      // 计算月份金额
      monthExpenMoney += expenMoney;
      monthIncomeMoney += incomeMoney;

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

    if (budgetModel != null) {
      return BillRecordMonth(monthExpenMoney, monthIncomeMoney, recordLsit,
          isBudget: budgetModel.isOpen, budget: budgetModel.budget);
    }

    return BillRecordMonth(monthExpenMoney, monthIncomeMoney, recordLsit);
  }

  /// 查询账单记录 13位时间戳 type类型 1支出 2收入
  Future<List<BillRecordModel>> getBillList(int startTime, int endTime,
      {String categoryName}) async {
    //DESC ASC
    var dbClient = await db;
    var result;
    if (categoryName != null) {
      result = await dbClient.rawQuery(
          "SELECT * FROM $_billTableName WHERE isDelete == 0 AND updateTimestamp >= $startTime and updateTimestamp <= $endTime and categoryName = '$categoryName'  ORDER BY updateTimestamp ASC, id ASC");
    } else {
      result = await dbClient.rawQuery(
          "SELECT * FROM $_billTableName WHERE isDelete == 0 AND updateTimestamp >= $startTime and updateTimestamp <= $endTime");
    }
    List list = result.toList();
    List<BillRecordModel> models =
        list.map((i) => BillRecordModel.fromJson(i)).toList();

    return models;
  }

  /// 查询预算是否存在
  Future<BudgetModel> querybudget(String yearMonth) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        "SELECT yearMonth,budget,isOpen FROM $_budgetTableName WHERE yearMonth = '$yearMonth' LIMIT 1");
    List list = result.toList();
    if (list.length > 0) {
      var map = Map.from(list.first);
      return BudgetModel(map['yearMonth'], map['budget'], map['isOpen']);
    }
    return null;
  }

  /// 插入预算
  Future<int> insertBudget(String yearMonth, int isOpen) async {
    var dbClient = await db;
    var map = {'yearMonth': yearMonth, 'isOpen': isOpen};
    var result;
    try {
      result = await dbClient.insert(_budgetTableName, map);
    } catch (error) {
      debugPrint(error.toString());
    }
    return result;
  }

  /// 查询账单
  Future<BillRecordModel> queryBillRecord(int id) async {
    if (id == null) {
      return null;
    }
    var dbClient = await db;
    var result = await dbClient
        .rawQuery('SELECT * FROM $_billTableName WHERE id == $id LIMIT 1');
    var list = result.toList();
    if (list.length > 0) {
      return BillRecordModel.fromJson(list.first);
    } else {
      return null;
    }
  }

  /// 删除账单
  Future<int> deleteBillRecord(int id) async {
    if (id == null) {
      return null;
    }
    var dbClient = await db;
    //UPDATE BillRecord SET money = 123 WHERE id = 42
    return await dbClient
        .rawUpdate('UPDATE $_billTableName SET isDelete = 1 WHERE id = $id');
  }
}
