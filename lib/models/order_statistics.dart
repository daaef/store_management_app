class OrderStatistics {
  final int? id;
  final DateTime? created;
  final DateTime? modified;
  final int? subentityId;
  final int? totalOrders;
  final int? totalPendingOrders;
  final int? totalCompletedOrders;
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

  factory OrderStatistics.fromJson(Map<String, dynamic> json) {
    return OrderStatistics(
      id: json['id'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified: json['modified'] != null ? DateTime.parse(json['modified']) : null,
      subentityId: json['subentity_id'],
      totalOrders: json['total_orders'],
      totalPendingOrders: json['total_pending_orders'],
      totalCompletedOrders: json['total_completed_orders'],
      totalRevenue: json['total_revenue']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'subentity_id': subentityId,
      'total_orders': totalOrders,
      'total_pending_orders': totalPendingOrders,
      'total_completed_orders': totalCompletedOrders,
      'total_revenue': totalRevenue,
    };
  }

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
