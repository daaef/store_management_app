import 'fainzy_store.dart';
import 'fainzy_user.dart';
import 'location.dart';
import 'cart_item.dart';

// part 'fainzy_user_order.g.dart';

// @JsonSerializable(fieldRename: FieldRename.snake)
class FainzyUserOrder {
  const FainzyUserOrder({
    this.id,
    this.orderId,
    this.code,
    this.restaurant,
    this.deliveryLocation,
    this.menu,
    this.totalPrice,
    this.deliveryFee,
    this.serviceFee,
    this.couponDiscount,
    this.couponCode,
    this.status,
    this.user,
    this.updated,
    this.created,
    this.cancellationTime,
    this.estimatedEta,
  });

  factory FainzyUserOrder.fromJson(Map<String, dynamic> json) {
    return FainzyUserOrder(
      id: json['id'] != null 
          ? (json['id'] is int 
              ? json['id'] as int 
              : int.tryParse(json['id'].toString()))
          : null,
      orderId: json['order_id'] as String?,
      code: json['code'] as String?,
      restaurant: json['restaurant'] != null 
          ? FainzyStore.fromJson(json['restaurant'] as Map<String, dynamic>)
          : null,
      deliveryLocation: json['location'] != null 
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      menu: json['menu'] != null 
          ? List<FainzyCartItem>.from(json['menu'].map((x) => FainzyCartItem.fromJson(x)))
          : null,
      totalPrice: json['total_price'] != null 
          ? (json['total_price'] as num).toDouble()
          : null,
      deliveryFee: json['delivery_fee'] != null 
          ? (json['delivery_fee'] as num).toDouble()
          : null,
      serviceFee: json['service_fee'] != null 
          ? (json['service_fee'] as num).toDouble()
          : null,
      couponDiscount: json['coupon_discount'] != null 
          ? (json['coupon_discount'] as num).toDouble()
          : null,
      couponCode: json['coupon_code'] as String?,
      status: json['status'] as String?,
      user: json['user'] != null 
          ? FainzyUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      updated: json['updated'] != null 
          ? DateTime.parse(json['updated'] as String)
          : null,
      created: json['created'] != null 
          ? DateTime.parse(json['created'] as String)
          : null,
      cancellationTime: json['cancellation_time'] != null 
          ? DateTime.parse(json['cancellation_time'] as String)
          : null,
      estimatedEta: json['estimated_eta'] != null 
          ? (json['estimated_eta'] as num).toDouble()
          : null,
    );
  }

  final int? id;
  final String? orderId;
  final String? code;
  final FainzyStore? restaurant;
  final Location? deliveryLocation;
  final List<FainzyCartItem>? menu;
  final double? totalPrice;
  final double? deliveryFee;
  final double? serviceFee;
  final double? couponDiscount;
  final String? couponCode;
  final String? status;
  final FainzyUser? user;
  final DateTime? updated;
  final DateTime? created;
  final DateTime? cancellationTime;
  final double? estimatedEta;

  FainzyUserOrder copyWith({
    int? id,
    String? orderId,
    String? code,
    FainzyStore? restaurant,
    Location? deliveryLocation,
    List<FainzyCartItem>? menu,
    double? totalPrice,
    double? deliveryFee,
    double? serviceFee,
    double? couponDiscount,
    String? couponCode,
    String? status,
    FainzyUser? user,
    DateTime? updated,
    DateTime? created,
    DateTime? cancellationTime,
    double? estimatedEta,
  }) {
    return FainzyUserOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      code: code ?? this.code,
      restaurant: restaurant ?? this.restaurant,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      menu: menu ?? this.menu,
      totalPrice: totalPrice ?? this.totalPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      couponCode: couponCode ?? this.couponCode,
      status: status ?? this.status,
      user: user ?? this.user,
      updated: updated ?? this.updated,
      created: created ?? this.created,
      cancellationTime: cancellationTime ?? this.cancellationTime,
      estimatedEta: estimatedEta ?? this.estimatedEta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'code': code,
      'restaurant': restaurant?.toJson(),
      'location': deliveryLocation?.toJson(),
      'menu': menu?.map((x) => x.toJson()).toList(),
      'total_price': totalPrice,
      'delivery_fee': deliveryFee,
      'service_fee': serviceFee,
      'coupon_discount': couponDiscount,
      'coupon_code': couponCode,
      'status': status,
      'user': user?.toJson(),
      'updated': updated?.toIso8601String(),
      'created': created?.toIso8601String(),
      'cancellation_time': cancellationTime?.toIso8601String(),
      'estimated_eta': estimatedEta,
    };
  }

  @override
  String toString() {
    return 'FainzyUserOrder(id: $id, orderId: $orderId, code: $code, restaurant: $restaurant, deliveryLocation: $deliveryLocation, menu: $menu, totalPrice: $totalPrice, deliveryFee: $deliveryFee, serviceFee: $serviceFee, couponDiscount: $couponDiscount, couponCode: $couponCode, status: $status, user: $user, updated: $updated, created: $created, cancellationTime: $cancellationTime, estimatedEta: $estimatedEta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FainzyUserOrder &&
        other.id == id &&
        other.orderId == orderId &&
        other.code == code &&
        other.restaurant == restaurant &&
        other.deliveryLocation == deliveryLocation &&
        other.menu == menu &&
        other.totalPrice == totalPrice &&
        other.deliveryFee == deliveryFee &&
        other.serviceFee == serviceFee &&
        other.couponDiscount == couponDiscount &&
        other.couponCode == couponCode &&
        other.status == status &&
        other.user == user &&
        other.updated == updated &&
        other.created == created &&
        other.cancellationTime == cancellationTime &&
        other.estimatedEta == estimatedEta;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderId.hashCode ^
        code.hashCode ^
        restaurant.hashCode ^
        deliveryLocation.hashCode ^
        menu.hashCode ^
        totalPrice.hashCode ^
        deliveryFee.hashCode ^
        serviceFee.hashCode ^
        couponDiscount.hashCode ^
        couponCode.hashCode ^
        status.hashCode ^
        user.hashCode ^
        updated.hashCode ^
        created.hashCode ^
        cancellationTime.hashCode ^
        estimatedEta.hashCode;
  }

  /// Convenience getters for pricing calculations
  double get subtotal {
    if (menu == null) return 0.0;
    return menu!.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get totalDiscount {
    return (couponDiscount ?? 0.0);
  }

  double get finalTotal {
    return (totalPrice ?? 0.0) + (deliveryFee ?? 0.0) + (serviceFee ?? 0.0) - totalDiscount;
  }

  bool get isCancelled => status?.toLowerCase() == 'cancelled';
  bool get isCompleted => status?.toLowerCase() == 'completed';
  bool get isPending => status?.toLowerCase() == 'pending';
  bool get isProcessing => status?.toLowerCase() == 'processing';
}