// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fainzy_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FainzyMenu _$FainzyMenuFromJson(Map<String, dynamic> json) => FainzyMenu(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      ingredients: json['ingredients'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      currencySymbol: json['currency_symbol'] as String?,
      status: json['status'] as String?,
      category: (json['category'] as num?)?.toInt(),
      subentity: (json['subentity'] as num?)?.toInt(),
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      modified: json['modified'] == null
          ? null
          : DateTime.parse(json['modified'] as String),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => FainzyMenuImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      sides: json['sides'] as List<dynamic>?,
    );

Map<String, dynamic> _$FainzyMenuToJson(FainzyMenu instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'ingredients': instance.ingredients,
      'price': instance.price,
      'discount': instance.discount,
      'discount_price': instance.discountPrice,
      'currency_symbol': instance.currencySymbol,
      'status': instance.status,
      'category': instance.category,
      'subentity': instance.subentity,
      'created': instance.created?.toIso8601String(),
      'modified': instance.modified?.toIso8601String(),
      'images': instance.images,
      'sides': instance.sides,
    };
