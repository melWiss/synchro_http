// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SynchroRequestAdapter extends TypeAdapter<SynchroRequest> {
  @override
  final int typeId = 0;

  @override
  SynchroRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SynchroRequest(
      fields[0] as String,
      fields[1] as String,
      body: fields[2] as String,
      persistentConnection: fields[3] as bool,
      headers: (fields[4] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SynchroRequest obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.urlStr)
      ..writeByte(1)
      ..write(obj.method)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.persistentConnection)
      ..writeByte(4)
      ..write(obj.headers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynchroRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
