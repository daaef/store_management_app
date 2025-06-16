// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuCategory _$MenuCategoryFromJson(Map<String, dynamic> json) => MenuCategory(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      modified: json['modified'] == null
          ? null
          : DateTime.parse(json['modified'] as String),
      subentity: (json['subentity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MenuCategoryToJson(MenuCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created': instance.created?.toIso8601String(),
      'modified': instance.modified?.toIso8601String(),
      'subentity': instance.subentity,
    };
