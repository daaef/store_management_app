// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fainzy_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FainzyImage _$FainzyImageFromJson(Map<String, dynamic> json) => FainzyImage(
      id: (json['id'] as num?)?.toInt(),
      created: json['created'] as String?,
      modified: json['modified'] as String?,
      upload: json['upload'] as String?,
      menu: (json['menu'] as num?)?.toInt(),
      subentity: (json['subentity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FainzyImageToJson(FainzyImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'modified': instance.modified,
      'upload': instance.upload,
      'menu': instance.menu,
      'subentity': instance.subentity,
    };
