// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fainzy_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FainzyUser _$FainzyUserFromJson(Map<String, dynamic> json) => FainzyUser(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      updated: json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
    );

Map<String, dynamic> _$FainzyUserToJson(FainzyUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'created': instance.created?.toIso8601String(),
      'updated': instance.updated?.toIso8601String(),
    };
