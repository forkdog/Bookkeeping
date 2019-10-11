class DateUtls {

  /// 获取当月总天数
  static int getDaysNum(int year, int month) {
    if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) {
      return 31;
    } else if (month == 2) {
      if (((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)) {
        //闰年 2月29
        return 29;
      } else {
        //平年 2月28
        return 28;
      }
    } else {
      return 30;
    }
  }
}
