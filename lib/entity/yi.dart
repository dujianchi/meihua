/// 易数：上爻、下爻、动爻
// @JsonCodable()
class Yi {
  final int shang, xia, dong;
  final String? historyDate;
  final int? historyId;
  Yi({
    required this.shang,
    required this.xia,
    required this.dong,
    this.historyDate,
    this.historyId,
  }) {
    assert(shang >= 1 && shang <= 8);
    assert(xia >= 1 && xia <= 8);
    assert(dong >= 1 && dong <= 6);
  }
}
