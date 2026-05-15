// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListModelAdapter extends TypeAdapter<ListModel> {
  @override
  final int typeId = 0;

  @override
  ListModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListModel(
      id: fields[0] as int?,
      name: fields[1] as String,
      type: fields[2] as String?,
      description: fields[3] as String?,
      supportsCompletion: fields[4] as bool,
      supportsWishlist: fields[5] as bool,
      tracksDates: fields[6] as bool,
      supportsPrice: fields[7] as bool,
      genreLayoutMode: fields[8] as int?,
      position: fields[9] as int?,
      supportsProgress: fields[10] as bool,
      progressType: fields[11] as String?,
      customProgressUnit: fields[12] as String?,
      defaultCategory: fields[13] as String?,
      ratingScale: fields[14] as int?,
      canEdit: fields[15] as bool,
      owner: fields[16] as bool,
      shared: fields[17] as bool,
      compact: fields[18] as bool,
      thematic: fields[19] as bool,
      gradeable: fields[20] as bool,
      color: fields[21] as String,
      icon: fields[22] as String,
      itemCount: fields[23] as int,
      statusOrder: (fields[24] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ListModel obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.supportsCompletion)
      ..writeByte(5)
      ..write(obj.supportsWishlist)
      ..writeByte(6)
      ..write(obj.tracksDates)
      ..writeByte(7)
      ..write(obj.supportsPrice)
      ..writeByte(8)
      ..write(obj.genreLayoutMode)
      ..writeByte(9)
      ..write(obj.position)
      ..writeByte(10)
      ..write(obj.supportsProgress)
      ..writeByte(11)
      ..write(obj.progressType)
      ..writeByte(12)
      ..write(obj.customProgressUnit)
      ..writeByte(13)
      ..write(obj.defaultCategory)
      ..writeByte(14)
      ..write(obj.ratingScale)
      ..writeByte(15)
      ..write(obj.canEdit)
      ..writeByte(16)
      ..write(obj.owner)
      ..writeByte(17)
      ..write(obj.shared)
      ..writeByte(18)
      ..write(obj.compact)
      ..writeByte(19)
      ..write(obj.thematic)
      ..writeByte(20)
      ..write(obj.gradeable)
      ..writeByte(21)
      ..write(obj.color)
      ..writeByte(22)
      ..write(obj.icon)
      ..writeByte(23)
      ..write(obj.itemCount)
      ..writeByte(24)
      ..write(obj.statusOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
