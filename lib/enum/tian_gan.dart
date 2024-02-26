/// 十天干
/// 甲乙丙丁戊己庚辛壬癸
enum TianGan {
  jia(1, '甲'),
  yi(2, '乙'),
  bing(3, '丙'),
  ding(4, '丁'),
  wu(5, '戊'),
  ji(6, '己'),
  geng(7, '庚'),
  xin(8, '辛'),
  ren(9, '壬'),
  gui(10, '癸'),
  ;

  final String name;
  final int value;
  const TianGan(this.value, this.name);

  static int name2value(String name) {
    for (var tiangan in TianGan.values) {
      if (name == tiangan.name) return tiangan.value;
    }
    throw UnsupportedError('错误的天干');
  }
}
