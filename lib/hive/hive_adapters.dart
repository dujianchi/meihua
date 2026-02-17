import 'package:hive_ce/hive_ce.dart';
import 'package:meihua/entity/database/db_64gua.dart';
import 'package:meihua/entity/database/db_8gua.dart';
import 'package:meihua/entity/database/db_config.dart';
import 'package:meihua/entity/database/db_history.dart';
import 'package:meihua/entity/database/db_history_sync.dart';

@GenerateAdapters([
  AdapterSpec<Db8gua>(),
  AdapterSpec<Db64gua>(),
  AdapterSpec<DbConfig>(),
  AdapterSpec<DbHistory>(),
  AdapterSpec<DbHistorySync>(),
])
part 'hive_adapters.g.dart';
