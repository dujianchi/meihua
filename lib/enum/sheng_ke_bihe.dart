enum ShengKeBihe {
  shengWo('被生', 1),
  keWo('被克', -2),
  woSheng('生', -1),
  woKe('克', 2),
  bihe('比和', 0),
  ;

  final String name;
  final int value;
  const ShengKeBihe(this.name, this.value);
}
