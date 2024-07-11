import 'package:flutter/material.dart';
import 'package:meihua/entity/database/db_8gua.dart';
import 'package:meihua/util/db_helper.dart';

class DocTooltip extends StatelessWidget {
  final String fullname;
  final Widget widget;

  const DocTooltip({super.key, required this.fullname, required this.widget});

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
        future: _getCacheStr(fullname),
        builder: (ctx, str) {
          if (str.connectionState == ConnectionState.done &&
              str.data?.isNotEmpty == true) {
            return Tooltip(
              message: str.data,
              child: widget,
            );
          } else {
            return widget;
          }
        },
      );

  Future<String?> _getCacheStr(String name) async {
    final db8guas = await DbHelper.query(Db8gua.nameDb,
        where: 'name = ?', whereArgs: [name], limit: 1);
    if (db8guas.isEmpty) return null;
    final db8gua = Db8gua()..fromMap(db8guas[0]);
    return '''旺于${db8gua.guaQiWang}
衰于${db8gua.guaQiShuai}
${db8gua.shuLei}
${db8gua.houTianFangWei}
''';
  }
}
