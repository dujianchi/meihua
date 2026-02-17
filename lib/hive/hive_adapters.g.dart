// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class Db8guaAdapter extends TypeAdapter<Db8gua> {
  @override
  final typeId = 0;

  @override
  Db8gua read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Db8gua()
      ..id = (fields[0] as num?)?.toInt()
      ..xianTianShu = (fields[1] as num?)?.toInt()
      ..houTianShu = (fields[2] as num?)?.toInt()
      ..name = fields[3] as String?
      ..shuLei = fields[4] as String?
      ..leiXiang = fields[5] as String?
      ..guaQiWang = fields[6] as String?
      ..guaQiShuai = fields[7] as String?
      ..xianTianFangWei = fields[8] as String?
      ..houTianFangWei = fields[9] as String?;
  }

  @override
  void write(BinaryWriter writer, Db8gua obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.xianTianShu)
      ..writeByte(2)
      ..write(obj.houTianShu)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.shuLei)
      ..writeByte(5)
      ..write(obj.leiXiang)
      ..writeByte(6)
      ..write(obj.guaQiWang)
      ..writeByte(7)
      ..write(obj.guaQiShuai)
      ..writeByte(8)
      ..write(obj.xianTianFangWei)
      ..writeByte(9)
      ..write(obj.houTianFangWei);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Db8guaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class Db64guaAdapter extends TypeAdapter<Db64gua> {
  @override
  final typeId = 1;

  @override
  Db64gua read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Db64gua()
      ..id = (fields[0] as num?)?.toInt()
      ..name = fields[1] as String?
      ..fullName = fields[2] as String?
      ..shang = fields[3] as String?
      ..xia = fields[4] as String?
      ..guaCi = fields[5] as String?
      ..guaCiJs = fields[6] as String?
      ..chuYao = fields[7] as String?
      ..chuYaoJs = fields[8] as String?
      ..erYao = fields[9] as String?
      ..erYaoJs = fields[10] as String?
      ..sanYao = fields[11] as String?
      ..sanYaoJs = fields[12] as String?
      ..siYao = fields[13] as String?
      ..siYaoJs = fields[14] as String?
      ..wuYao = fields[15] as String?
      ..wuYaoJs = fields[16] as String?
      ..shangYao = fields[17] as String?
      ..shangYaoJs = fields[18] as String?;
  }

  @override
  void write(BinaryWriter writer, Db64gua obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.shang)
      ..writeByte(4)
      ..write(obj.xia)
      ..writeByte(5)
      ..write(obj.guaCi)
      ..writeByte(6)
      ..write(obj.guaCiJs)
      ..writeByte(7)
      ..write(obj.chuYao)
      ..writeByte(8)
      ..write(obj.chuYaoJs)
      ..writeByte(9)
      ..write(obj.erYao)
      ..writeByte(10)
      ..write(obj.erYaoJs)
      ..writeByte(11)
      ..write(obj.sanYao)
      ..writeByte(12)
      ..write(obj.sanYaoJs)
      ..writeByte(13)
      ..write(obj.siYao)
      ..writeByte(14)
      ..write(obj.siYaoJs)
      ..writeByte(15)
      ..write(obj.wuYao)
      ..writeByte(16)
      ..write(obj.wuYaoJs)
      ..writeByte(17)
      ..write(obj.shangYao)
      ..writeByte(18)
      ..write(obj.shangYaoJs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Db64guaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DbConfigAdapter extends TypeAdapter<DbConfig> {
  @override
  final typeId = 2;

  @override
  DbConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbConfig()
      ..id = (fields[0] as num?)?.toInt()
      ..key = fields[1] as String?
      ..val = fields[2] as String?;
  }

  @override
  void write(BinaryWriter writer, DbConfig obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.key)
      ..writeByte(2)
      ..write(obj.val);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DbHistoryAdapter extends TypeAdapter<DbHistory> {
  @override
  final typeId = 3;

  @override
  DbHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbHistory()
      ..id = (fields[0] as num?)?.toInt()
      ..saveDate = (fields[1] as num?)?.toInt()
      ..shang = (fields[2] as num?)?.toInt()
      ..xia = (fields[3] as num?)?.toInt()
      ..bian = (fields[4] as num?)?.toInt()
      ..lunarDate = fields[5] as String?
      ..title = fields[6] as String?
      ..describe = fields[7] as String?
      ..syncHash = fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, DbHistory obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.saveDate)
      ..writeByte(2)
      ..write(obj.shang)
      ..writeByte(3)
      ..write(obj.xia)
      ..writeByte(4)
      ..write(obj.bian)
      ..writeByte(5)
      ..write(obj.lunarDate)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.describe)
      ..writeByte(8)
      ..write(obj.syncHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DbHistorySyncAdapter extends TypeAdapter<DbHistorySync> {
  @override
  final typeId = 4;

  @override
  DbHistorySync read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbHistorySync()
      ..id = (fields[0] as num?)?.toInt()
      ..createTime = (fields[1] as num?)?.toInt()
      ..operate = (fields[2] as num?)?.toInt()
      ..uploaded = (fields[3] as num?)?.toInt()
      ..whereParam = fields[4] as String?
      ..whereArgs = fields[5] as String?
      ..data = fields[6] as String?;
  }

  @override
  void write(BinaryWriter writer, DbHistorySync obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createTime)
      ..writeByte(2)
      ..write(obj.operate)
      ..writeByte(3)
      ..write(obj.uploaded)
      ..writeByte(4)
      ..write(obj.whereParam)
      ..writeByte(5)
      ..write(obj.whereArgs)
      ..writeByte(6)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbHistorySyncAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
