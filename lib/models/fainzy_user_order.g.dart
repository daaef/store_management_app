// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fainzy_user_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FainzyUserOrder _$FainzyUserOrderFromJson(Map<String, dynamic> json) =>
    FainzyUserOrder(
      id: (json['id'] as num?)?.toInt(),
      orderId: json['order_id'] as String?,
      code: json['code'] as String?,
      restaurant: json['restaurant'] == null
          ? null
          : FainzyStore.fromJson(json['restaurant'] as Map<String, dynamic>),
      deliveryLocation: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      menu: (json['menu'] as List<dynamic>?)
          ?.map((e) => FainzyCartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      serviceFee: (json['service_fee'] as num?)?.toDouble(),
      couponDiscount: (json['coupon_discount'] as num?)?.toDouble(),
      couponCode: json['coupon_code'] as String?,
      status: json['status'] as String?,
      user: json['user'] == null
          ? null
          : FainzyUser.fromJson(json['user'] as Map<String, dynamic>),
      updated: json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      cancellationTime: json['cancellation_time'] == null
          ? null
          : DateTime.parse(json['cancellation_time'] as String),
      estimatedEta: (json['estimated_eta'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FainzyUserOrderToJson(FainzyUserOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'code': instance.code,
      'restaurant': instance.restaurant,
      'location': instance.deliveryLocation,
      'menu': instance.menu,
      'total_price': instance.totalPrice,
      'delivery_fee': instance.deliveryFee,
      'service_fee': instance.serviceFee,
      'coupon_discount': instance.couponDiscount,
      'coupon_code': instance.couponCode,
      'status': instance.status,
      'user': instance.user,
      'updated': instance.updated?.toIso8601String(),
      'created': instance.created?.toIso8601String(),
      'cancellation_time': instance.cancellationTime?.toIso8601String(),
      'estimated_eta': instance.estimatedEta,
    };
