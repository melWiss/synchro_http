// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SynchroResponseAdapter extends TypeAdapter<SynchroResponse> {
  @override
  final int typeId = 1;

  @override
  SynchroResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SynchroResponse(
      fields[0] as String,
      fields[1] as int,
      headers: (fields[2] as Map).cast<String, String>(),
      isRedirect: fields[3] as bool,
      persistentConnection: fields[4] as bool,
      reasonPhrase: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SynchroResponse obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.body)
      ..writeByte(1)
      ..write(obj.statusCode)
      ..writeByte(2)
      ..write(obj.headers)
      ..writeByte(3)
      ..write(obj.isRedirect)
      ..writeByte(4)
      ..write(obj.persistentConnection)
      ..writeByte(5)
      ..write(obj.reasonPhrase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynchroResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
