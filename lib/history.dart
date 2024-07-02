import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:meihua/entity/yi.dart';
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
  final _historyList = <Map<String, dynamic>>[];
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
/*
CREATE TABLE $dbName (
	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`save_date` INTEGER,
	`lunar_date` TEXT,
	`shang` INTEGER NOT NULL,
	`xia` INTEGER NOT NULL,
	`bian` INTEGER NOT NULL,
	`title` TEXT NOT NULL,
	`describe` TEXT
);
*/
        final id = item['id'] as int;
        final saveDate = item['save_date'] as int?;
        final lunarDate = item['lunar_date'] as String?;
        final shang = item['shang'] as int;
        final xia = item['xia'] as int;
        final bian = item['bian'] as int;
        final title = item['title'] as String;
        final describe = item['describe'] as String?;
        final opacity = (_opacities[index] ?? true) ? 0.0 : 1.0;
        final contentChildren = [
          Opacity(
            opacity: opacity,
            child: Text(title, style: const TextStyle(color: Colors.redAccent)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Text('id: $id'),
              Text('上卦: ${shang.baGua().name}'),
              Text('下卦: ${xia.baGua().name}'),
              Text('变爻: ${bian.yao()}'),
            ],
          ),
          Text('时间: ${saveDate.dateStr()}',
              style: const TextStyle(color: Colors.blueGrey)),
          Text('农历时间: ${lunarDate.or()}',
              style: const TextStyle(color: Colors.blueGrey)),
        ];
        if (describe?.isNotEmpty == true) {
          contentChildren.add(Opacity(
            opacity: opacity,
            child: Text('详细说明: $describe',
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
                shang: shang == 0 ? 8 : shang,
                xia: xia == 0 ? 8 : xia,
                dong: bian == 0 ? 6 : bian,
                historyDate: '${saveDate.dateStr()}\n($lunarDate)',
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
                      onTap: () => _edit(id, title, describe),
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
                      onTap: () => _delete(id, title, index),
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
      final serverUrl = await DbHelper.getConfig('webdav_server');
      final account = await DbHelper.getConfig('webdav_account');
      final password = await DbHelper.getConfig('webdav_password');

      if (serverUrl?.isEmpty == true ||
          account?.isEmpty == true ||
          password?.isEmpty == true) {
        _actionSelected(2);
      } else {
        var success = true;
        final client = newClient(
          serverUrl!,
          user: account!,
          password: password!,
          debug: false,
        );
        client.setHeaders({'accept-charset': 'utf-8'});
        client.setConnectTimeout(8000);
        client.setSendTimeout(8000);
        client.setReceiveTimeout(8000);
        try {
          await client.ping();
          await client.mkdir('/meihua');
          var list = await client.readDir('/meihua');
          if (list.isEmpty) {
            final jsonArray = jsonEncode(_historyList);
            jsonArray.log('json array = ');
            await client.write('/meihua/history.json', utf8.encode(jsonArray));
          } else {
            final cloudJsonBytes = await client.read('/meihua/history.json');
            final cloudJsonArray =
                jsonDecode(utf8.decode(cloudJsonBytes)) as List<dynamic>;
            // todo 待完善的合并算法，应该试着加一个唯一值，判断唯一值进行合并，同时应该做一个删除操作，可能要价格同步表，记录所有操作记录，按照同步表去同步
            final newList = <dynamic>[];
            newList.addAll(_historyList);
            final cloudList = cloudJsonArray.where((map) {
              final saveDate = map['save_date'] as int?;
              return !_historyList
                  .any((m) => (m['save_date'] as int?) == saveDate);
            }).toList();
            cloudList.log('cloudList = ');
            if (cloudList.isNotEmpty) {
              await DbHelper.saveList(cloudList);
              newList.add(cloudList);
              final jsonArray = jsonEncode(newList);
              jsonArray.log('json array = ');
              await client.write(
                  '/meihua/history.json', utf8.encode(jsonArray));
            }
          }
        } catch (e) {
          '连接WebDav失败，失败原因：$e'.toast(5);
          e.log('webdav exception: ');
          success = false;
        } finally {
          (success ? '同步成功' : '同步失败').toast();
        }
      }
    } else if (index == 2) {
      final oldServerUrl = await DbHelper.getConfig('webdav_server');
      final oldAccount = await DbHelper.getConfig('webdav_account');
      final oldPassword = await DbHelper.getConfig('webdav_password');
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
                onPressed: () {
                  Get.until((route) => Get.isDialogOpen != true);
                },
                child: const Text('取消')),
            TextButton(
                onPressed: () async {
                  final serverUrl = etServer.text(),
                      account = etAccount.text(),
                      password = etPassword.text();
                  await DbHelper.saveConfig({
                    'webdav_server': serverUrl,
                    'webdav_account': account,
                    'webdav_password': password,
                  });
                  Get.until((route) => Get.isDialogOpen != true);
                },
                child: const Text('保存')),
          ],
          scrollable: true,
        ),
      );
    }
  }

  void _delete(int id, String title, int index) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    Get.generalDialog(
      pageBuilder: (context, animation1, animation2) => AlertDialog(
        title: const Text('删除'),
        content: Text('确定删除$title吗'),
        actions: [
          TextButton(
              onPressed: () => Get.until((route) => Get.isDialogOpen != true),
              child: const Text('取消')),
          TextButton(
              onPressed: () {
                DbHelper.transaction((db) async {
                  await db.delete(DbHelper.dbName,
                      where: "id = ?", whereArgs: [id]);
                  setState(() {
                    _historyList.removeAt(index);
                  });
                });
                Get.until((route) => Get.isDialogOpen != true);
                '删除成功'.toast();
              },
              child: const Text('删除'))
        ],
      ),
    );
  }

  void _edit(int id, String oldTitle, String? oldDescribe) {
    Get.until((route) => Get.isBottomSheetOpen != true);
    final title = EditText(
          label: '标题',
          defaultStr: oldTitle,
        ),
        desc = EditText(
          label: '详细说明',
          maxLines: 3,
          defaultStr: oldDescribe,
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
                  await DbHelper.update(id, title: titleStr, describe: descStr);
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
    DbHelper.transaction((db) async {
      final list = await db.query(DbHelper.dbName, orderBy: 'save_date desc');
      setState(() {
        if (list.isNotEmpty) {
          _historyList.addAll(list);
        }
      });
    });
  }
}
