import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/yi.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/entity/database/db_history_sync.dart';
import 'package:meihua/util/db_helper.dart';
import 'package:meihua/util/exts.dart';
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
      // final serverUrl = await DbHelper.getConfig('webdav_server');
      // final account = await DbHelper.getConfig('webdav_account');
      // final password = await DbHelper.getConfig('webdav_password');

      // if (serverUrl?.isEmpty == true ||
      //     account?.isEmpty == true ||
      //     password?.isEmpty == true) {
      //   _actionSelected(2);
      // } else {
      //   var success = true;
      //   final client = newClient(
      //     serverUrl!,
      //     user: account!,
      //     password: password!,
      //     debug: false,
      //   );
      //   client.setHeaders({'accept-charset': 'utf-8'});
      //   client.setConnectTimeout(8000);
      //   client.setSendTimeout(8000);
      //   client.setReceiveTimeout(8000);
      //   try {
      //     await client.ping();
      //     await client.mkdir('/meihua');
      //     var list = await client.readDir('/meihua');
      //     if (list.isEmpty) {
      //       final jsonArray = jsonEncode(_historyList);
      //       jsonArray.log('json array = ');
      //       await client.write('/meihua/history.json', utf8.encode(jsonArray));
      //     } else {
      //       // final cloudJsonBytes = await client.read('/meihua/history.json');
      //       // final cloudJsonArray =
      //       //     jsonDecode(utf8.decode(cloudJsonBytes)) as List<dynamic>;
      //       // // todo 待完善的合并算法，应该试着加一个唯一值，判断唯一值进行合并，同时应该做一个删除操作，可能要价格同步表，记录所有操作记录，按照同步表去同步
      //       // final newList = <dynamic>[], cloudList = <dynamic>[];
      //       // for (dynamic map in cloudJsonArray) {
      //       //   final saveDate = map['save_date'];
      //       //   if (!_historyList
      //       //       .any((m) => '${m['save_date']}' == '$saveDate')) {
      //       //     cloudList.add(map);
      //       //   }
      //       // }
      //       // for (dynamic map in _historyList) {
      //       //   final saveDate = map['save_date'];
      //       //   if (!cloudJsonArray
      //       //       .any((m) => '${m['save_date']}' == '$saveDate')) {
      //       //     newList.add(map);
      //       //   }
      //       // }
      //       // cloudList.log('cloudList = ');
      //       // if (cloudList.isNotEmpty || newList.isNotEmpty) {
      //       //   await DbHelper.saveList(cloudList);
      //       //   _historyList.addAll(cloudList);
      //       //   final jsonArray = jsonEncode(_historyList);
      //       //   jsonArray.log('json array = ');
      //       //   await client.write(
      //       //       '/meihua/history.json', utf8.encode(jsonArray));
      //       // }
      //     }
      //     _loadData();
      //   } catch (e) {
      //     '连接WebDav失败，失败原因：$e'.toast(5);
      //     e.log('webdav exception: ');
      //     success = false;
      //   } finally {
      //     (success ? '同步成功' : '同步失败').toast();
      //   }
      // }
    } else if (index == 2) {
      // final oldServerUrl = await DbHelper.getConfig('webdav_server');
      // final oldAccount = await DbHelper.getConfig('webdav_account');
      // final oldPassword = await DbHelper.getConfig('webdav_password');
      // final etServer = EditText(
      //       label: '服务器地址',
      //       defaultStr: oldServerUrl ?? 'https://dav.jianguoyun.com/dav/',
      //     ),
      //     etAccount = EditText(
      //       label: '账号',
      //       defaultStr: oldAccount,
      //     ),
      //     etPassword = EditText(
      //       label: '密码',
      //       defaultStr: oldPassword,
      //     );
      // Get.generalDialog(
      //   pageBuilder: (context, animation1, animation2) => AlertDialog(
      //     title: const Text('WebDav同步设置'),
      //     content: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [etServer, etAccount, etPassword],
      //     ),
      //     actions: [
      //       TextButton(
      //           onPressed: () {
      //             Get.until((route) => Get.isDialogOpen != true);
      //           },
      //           child: const Text('取消')),
      //       TextButton(
      //           onPressed: () async {
      //             final serverUrl = etServer.text(),
      //                 account = etAccount.text(),
      //                 password = etPassword.text();
      //             await DbHelper.saveConfig({
      //               'webdav_server': serverUrl,
      //               'webdav_account': account,
      //               'webdav_password': password,
      //             });
      //             Get.until((route) => Get.isDialogOpen != true);
      //           },
      //           child: const Text('保存')),
      //     ],
      //     scrollable: true,
      //   ),
      // );
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
