import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/entity/database/db_history_sync.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
import 'package:meihua/util/sync_helper.dart';
import 'package:meihua/widget/edit_text.dart';
import 'package:webdav_client/webdav_client.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final _historyList = <DbHistory>[];
  final _opacities = <int, bool>{};
  var _hideAll = true;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listview = ListView.separated(
      itemBuilder: (context, index) {
        final item = _historyList[index];
        final opacity = (_opacities[index] ?? true) ? 0.0 : 1.0;
        final contentChildren = [
          Opacity(
            opacity: opacity,
            child: Text(item.title!,
                style: const TextStyle(color: Colors.redAccent)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Text('id: $id'),
              Text('上卦: ${item.shang!.baGua().name}'),
              Text('下卦: ${item.xia!.baGua().name}'),
              Text('变爻: ${item.bian!.yao()}'),
            ],
          ),
          Text('时间: ${item.saveDate.dateStr()}',
              style: const TextStyle(color: Colors.blueGrey)),
          Text('农历时间: ${item.lunarDate.or()}',
              style: const TextStyle(color: Colors.blueGrey)),
        ];
        if (item.describe?.isNotEmpty == true) {
          contentChildren.add(Opacity(
            opacity: opacity,
            child: Text('详细说明: ${item.describe}',
                style: const TextStyle(color: Colors.blueAccent)),
          ));
        }
        return ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: contentChildren,
          ),
          onTap: () {
            Get.toNamed(
              'pan',
              arguments: Yi(
                shang: item.shang! == 0 ? 8 : item.shang!,
                xia: item.xia! == 0 ? 8 : item.xia!,
                dong: item.bian! == 0 ? 6 : item.bian!,
                historyDate: '${item.saveDate.dateStr()}\n(${item.lunarDate})',
              ),
            );
          },
          onLongPress: () {
            final hideText = (_opacities[index] ?? true) ? '显示' : '隐藏';
            Get.bottomSheet(BottomSheet(
                clipBehavior: Clip.antiAlias,
                onClosing: () {},
                builder: (context) {
                  // _delete(id, title, index);
                  final children = <Widget>[
                    ListTile(
                      title: const Text('编辑'),
                      onTap: () => _edit(item),
                    ),
                    ListTile(
                      title: Text(
                        hideText,
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                      onTap: () => _hide(index),
                    ),
                    ListTile(
                      title: const Text(
                        '删除',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () => _delete(item, index),
                    ),
                  ];
                  return Wrap(
                    children: children,
                  );
                }));
          },
        );
      },
      itemCount: _historyList.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(
        color: Colors.grey,
        thickness: 0,
        height: 0.1,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('排盘历史'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: Text(_hideAll ? '显示全部' : '隐藏全部')),
              const PopupMenuItem(value: 1, child: Text('同步')),
              const PopupMenuItem(value: 2, child: Text('同步设置')),
            ],
            onSelected: (value) => _actionSelected(value),
          )
        ],
      ),
      body: listview,
    );
  }

  void _actionSelected(index) async {
    if (index == 0) {
      _hideAll = !_hideAll;
      for (var i = 0; i < _historyList.length; i++) {
        _opacities[i] = _hideAll;
      }
      setState(() {});
    } else if (index == 1) {
      final configured = await SyncHelper.isConfigured();
      if (configured) {
        await SyncHelper.sync();
      } else {
        _actionSelected(2);
      }
    } else if (index == 2) {
      final (oldServerUrl, oldAccount, oldPassword) =
          await SyncHelper.getWebDavConf();
      final etServer = EditText(
            label: '服务器地址',
            defaultStr: oldServerUrl ?? 'https://dav.jianguoyun.com/dav/',
          ),
          etAccount = EditText(
            label: '账号',
            defaultStr: oldAccount,
          ),
          etPassword = EditText(
            label: '密码',
            defaultStr: oldPassword,
          );
      Get.generalDialog(
        pageBuilder: (context, animation1, animation2) => AlertDialog(
          title: const Text('WebDav同步设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [etServer, etAccount, etPassword],
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  await SyncHelper.forceSync();
                  Get.until((route) => Get.isDialogOpen != true);
                },
                child: const Text('覆盖云端数据',
                    style: TextStyle(color: Colors.redAccent))),
            TextButton(
                onPressed: () {
                  Get.until((route) => Get.isDialogOpen != true);
                },
                child: const Text('取消')),
            TextButton(
                onPressed: () async {
                  final serverUrl = etServer.text(),
                      account = etAccount.text(),
                      password = etPassword.text();
                  await SyncHelper.saveWebDavConf(serverUrl, account, password);
                  Get.until((route) => Get.isDialogOpen != true);
                },
                child: const Text('保存')),
          ],
          scrollable: true,
        ),
      );
    }
  }

  void _delete(DbHistory item, int index) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    Get.generalDialog(
      pageBuilder: (context, animation1, animation2) => AlertDialog(
        title: const Text('删除'),
        content: Text('确定删除${item.title}吗'),
        actions: [
          TextButton(
              onPressed: () => Get.until((route) => Get.isDialogOpen != true),
              child: const Text('取消')),
          TextButton(
              onPressed: () async {
                await DbHelper.delete(item.dbName,
                    where: 'id = ?', whereArgs: [item.id]);

                final dbHistorySync = DbHistorySync()
                  ..createTime = DateTime.now().millisecondsSinceEpoch
                  ..operate = 2
                  ..uploaded = 0
                  ..whereArgs = 'id = ?'
                  ..whereParam = '${item.id}';
                await DbHelper.save(dbHistorySync);

                setState(() {
                  _historyList.removeAt(index);
                });
                Get.until((route) => Get.isDialogOpen != true);
                '删除成功'.toast();
              },
              child: const Text('删除'))
        ],
      ),
    );
  }

  void _edit(DbHistory item) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    final title = EditText(
          label: '标题',
          defaultStr: item.title,
        ),
        desc = EditText(
          label: '详细说明',
          maxLines: 3,
          defaultStr: item.describe,
        );
    Get.generalDialog(
      pageBuilder: (context, animation1, animation2) => AlertDialog(
        title: const Text('保存'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            desc,
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.until((route) => Get.isDialogOpen != true);
              },
              child: const Text('取消')),
          TextButton(
              onPressed: () async {
                final titleStr = title.text();
                if (titleStr.isEmpty) {
                  '标题不能为空'.toast();
                } else {
                  final descStr = desc.text();
                  item.title = titleStr;
                  item.describe = descStr;
                  await DbHelper.update(item);

                  final dbHistorySync = DbHistorySync()
                    ..createTime = DateTime.now().millisecondsSinceEpoch
                    ..operate = 3
                    ..uploaded = 0
                    ..data = item.toMap().toJson()
                    ..whereArgs = 'id = ?'
                    ..whereParam = '${item.id}';
                  await DbHelper.save(dbHistorySync);

                  Get.until((route) => Get.isDialogOpen != true);
                  '保存成功'.toast();
                  _loadData();
                }
              },
              child: const Text('保存')),
        ],
        scrollable: true,
      ),
    );
  }

  void _hide(int index) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    final hide = _opacities[index] ?? true;
    setState(() {
      if (hide) {
        _opacities[index] = false;
      } else {
        _opacities[index] = true;
      }
    });
  }

  void _loadData() async {
    _historyList.clear();
    final list =
        await DbHelper.query(DbHistory.nameDb, orderBy: 'save_date desc');
    if (list.isNotEmpty) {
      setState(() {
        _historyList.addAll(list.map((m) => DbHistory()..fromMap(m)).toList());
      });
    }
  }
}
