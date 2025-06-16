import 'package:json_annotation/json_annotation.dart';

part 'order_statistics.g.dart';

@JsonSerializable()
class OrderStatistics {
  final int? id;
  final DateTime? created;
  final DateTime? modified;
  @JsonKey(name: 'subentity_id')
  final int? subentityId;
  @JsonKey(name: 'total_orders')
  final int? totalOrders;
  @JsonKey(name: 'total_pending_orders')
  final int? totalPendingOrders;
  @JsonKey(name: 'total_completed_orders')
  final int? totalCompletedOrders;
  @JsonKey(name: 'total_revenue')
  final double? totalRevenue;

  const OrderStatistics({
    this.id,
    this.created,
    this.modified,
    this.subentityId,
    this.totalOrders,
    this.totalPendingOrders,
    this.totalCompletedOrders,
    this.totalRevenue,
  });

  OrderStatistics copyWith({
    int? id,
    DateTime? created,
    DateTime? modified,
    int? subentityId,
    int? totalOrders,
    int? totalPendingOrders,
    int? totalCompletedOrders,
    double? totalRevenue,
  }) {
    return OrderStatistics(
      id: id ?? this.id,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      subentityId: subentityId ?? this.subentityId,
      totalOrders: totalOrders ?? this.totalOrders,
      totalPendingOrders: totalPendingOrders ?? this.totalPendingOrders,
      totalCompletedOrders: totalCompletedOrders ?? this.totalCompletedOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }

  factory OrderStatistics.fromJson(Map<String, dynamic> json) =>
      _$OrderStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatisticsToJson(this);

  @override
  String toString() {
    return 'OrderStatistics(id: $id, created: $created, modified: $modified, subentityId: $subentityId, totalOrders: $totalOrders, totalPendingOrders: $totalPendingOrders, totalCompletedOrders: $totalCompletedOrders, totalRevenue: $totalRevenue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderStatistics &&
        other.id == id &&
        other.created == created &&
        other.modified == modified &&
        other.subentityId == subentityId &&
        other.totalOrders == totalOrders &&
        other.totalPendingOrders == totalPendingOrders &&
        other.totalCompletedOrders == totalCompletedOrders &&
        other.totalRevenue == totalRevenue;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        created.hashCode ^
        modified.hashCode ^
        subentityId.hashCode ^
        totalOrders.hashCode ^
        totalPendingOrders.hashCode ^
        totalCompletedOrders.hashCode ^
        totalRevenue.hashCode;
  }
}
