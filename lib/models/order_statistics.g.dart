// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderStatistics _$OrderStatisticsFromJson(Map<String, dynamic> json) =>
    OrderStatistics(
      id: (json['id'] as num?)?.toInt(),
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      modified: json['modified'] == null
          ? null
          : DateTime.parse(json['modified'] as String),
      subentityId: (json['subentity_id'] as num?)?.toInt(),
      totalOrders: (json['total_orders'] as num?)?.toInt(),
      totalPendingOrders: (json['total_pending_orders'] as num?)?.toInt(),
      totalCompletedOrders: (json['total_completed_orders'] as num?)?.toInt(),
      totalRevenue: (json['total_revenue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$OrderStatisticsToJson(OrderStatistics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created?.toIso8601String(),
      'modified': instance.modified?.toIso8601String(),
      'subentity_id': instance.subentityId,
      'total_orders': instance.totalOrders,
      'total_pending_orders': instance.totalPendingOrders,
      'total_completed_orders': instance.totalCompletedOrders,
      'total_revenue': instance.totalRevenue,
    };
