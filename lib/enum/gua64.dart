/// 64卦
enum Gua64 {
  qian(1, '乾为天'),
  kun(2, '坤为地'),
  zhun(3, '水雷屯'),
  meng(4, '山水蒙'),
  xu(5, '水天需'),
  song(6, '天水讼'),
  shi(7, '地水师'),
  bi(8, '水地比'),
  xiaoxu(9, '风天小畜'),
  lv(10, '天泽履'),
  tai(11, '天地泰'),
  pi(12, '地天否'),
  ;

  final String name;
  final int value;
  const Gua64(this.value, this.name);

  static int name2value(String name) {
    for (var dizhi in Gua64.values) {
      if (name == dizhi.name) return dizhi.value;
    }
    throw UnsupportedError('错误的64卦');
  }
}
