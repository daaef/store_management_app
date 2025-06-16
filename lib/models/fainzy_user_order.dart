import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'fainzy_cart_item.dart';
import 'fainzy_store.dart';
import 'fainzy_user.dart';
import 'location.dart';

part 'fainzy_user_order.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory FainzyUserOrder.fromJson(Map<String, dynamic> json) =>
      _$FainzyUserOrderFromJson(json);

  final int? id;
  final String? orderId;
  final String? code;
  final FainzyStore? restaurant;
  @JsonKey(name: 'location')
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

  Map<String, dynamic> toJson() => _$FainzyUserOrderToJson(this);

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
    return menu!.fold(0.0, (sum, item) => sum + (item.price ?? 0.0));
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