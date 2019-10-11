
class BudgetModel {

  BudgetModel(this.yearMonth, this.budget, this.isOpen):super();

  /// 年月 2019-08
  String yearMonth;

  /// 预算金额
  double budget;

  /// 0不打开 1打开预算
  int isOpen;
}