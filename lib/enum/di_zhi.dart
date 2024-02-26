/// 十二地支
/// 子丑寅卯辰巳午未申酉戌亥
enum DiZhi {
  zi(1, '子'),
  chou(2, '丑'),
  yin(3, '寅'),
  mao(4, '卯'),
  chen(5, '辰'),
  si(6, '巳'),
  wu(7, '午'),
  wei(8, '未'),
  shen(9, '申'),
  you(10, '酉'),
  xu(11, '戌'),
  hai(12, '亥'),
  ;

  final String name;
  final int value;
  const DiZhi(this.value, this.name);

  static int name2value(String name) {
    for (var dizhi in DiZhi.values) {
      if (name == dizhi.name) return dizhi.value;
    }
    throw UnsupportedError('错误的地支');
  }
}
