// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fainzy_cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FainzyCartItem _$FainzyCartItemFromJson(Map<String, dynamic> json) =>
    FainzyCartItem(
      id: json['id'] as String?,
      menu: json['menu'] == null
          ? null
          : FainzyMenu.fromJson(json['menu'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FainzyCartItemToJson(FainzyCartItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menu': instance.menu,
      'quantity': instance.quantity,
      'price': instance.price,
    };
