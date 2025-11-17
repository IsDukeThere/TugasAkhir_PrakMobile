// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieListAdapter extends TypeAdapter<MovieList> {
  @override
  final int typeId = 0;

  @override
  MovieList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieList(
      id: fields[0] as int,
      title: fields[1] as String,
      overview: fields[3] as String,
      posterPath: fields[2] as String,
      releaseDate: fields[4] as String,
      rating: fields[5] as double,
      languageCode: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MovieList obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.overview)
      ..writeByte(4)
      ..write(obj.releaseDate)
      ..writeByte(5)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
