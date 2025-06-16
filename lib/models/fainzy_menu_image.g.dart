// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fainzy_menu_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FainzyMenuImage _$FainzyMenuImageFromJson(Map<String, dynamic> json) =>
    FainzyMenuImage(
      id: (json['id'] as num?)?.toInt(),
      menu: (json['menu'] as num?)?.toInt(),
      upload: json['upload'] as String?,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      modified: json['modified'] == null
          ? null
          : DateTime.parse(json['modified'] as String),
      subentity: (json['subentity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FainzyMenuImageToJson(FainzyMenuImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menu': instance.menu,
      'upload': instance.upload,
      'created': instance.created?.toIso8601String(),
      'modified': instance.modified?.toIso8601String(),
      'subentity': instance.subentity,
    };
