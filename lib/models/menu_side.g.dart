// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_side.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuSide _$MenuSideFromJson(Map<String, dynamic> json) => MenuSide(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool?,
      isSelected: json['is_selected'] as bool?,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      modified: json['modified'] == null
          ? null
          : DateTime.parse(json['modified'] as String),
      menu: (json['menu'] as num?)?.toInt(),
      subentity: (json['subentity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MenuSideToJson(MenuSide instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'name': instance.name,
      'price': instance.price,
      'is_default': instance.isDefault,
      'is_selected': instance.isSelected,
      'created': instance.created?.toIso8601String(),
      'modified': instance.modified?.toIso8601String(),
      'menu': instance.menu,
      'subentity': instance.subentity,
    };
