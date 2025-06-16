import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'fainzy_menu.dart';

part 'fainzy_cart_item.g.dart';

@JsonSerializable()
class FainzyCartItem {
  final String? id;
  final FainzyMenu? menu;
  final int? quantity;
  final double? price;

  const FainzyCartItem({
    this.id,
    this.menu,
    this.quantity,
    this.price,
  });

  double get cost => (price ?? 0) * (quantity ?? 0);

  FainzyCartItem copyWith({
    String? id,
    FainzyMenu? menu,
    int? quantity,
    double? price,
  }) {
    return FainzyCartItem(
      id: id ?? this.id,
      menu: menu ?? this.menu,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  factory FainzyCartItem.fromJson(Map<String, dynamic> json) =>
      _$FainzyCartItemFromJson(json);

  Map<String, dynamic> toJson() => _$FainzyCartItemToJson(this);

  @override
  String toString() {
    return 'FainzyCartItem(id: $id, menu: $menu, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FainzyCartItem &&
        other.id == id &&
        other.menu == menu &&
        other.quantity == quantity &&
        other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        menu.hashCode ^
        quantity.hashCode ^
        price.hashCode;
  }
}
