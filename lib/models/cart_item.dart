import 'fainzy_menu.dart';

class FainzyCartItem {
  final int? id;
  final String? name;
  final double? price;
  final int? quantity;
  final FainzyMenu? menu;
  final List<Side>? sides;

  const FainzyCartItem({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.menu,
    this.sides,
  });

  factory FainzyCartItem.fromJson(Map<String, dynamic> json) {
    return FainzyCartItem(
      id: json['id'] != null 
          ? (json['id'] is int 
              ? json['id'] as int 
              : int.tryParse(json['id'].toString()))
          : null,
      name: json['name'] as String?,
      price: json['price'] != null 
          ? (json['price'] as num).toDouble()
          : null,
      quantity: json['quantity'] != null 
          ? (json['quantity'] is int 
              ? json['quantity'] as int 
              : int.tryParse(json['quantity'].toString()))
          : null,
      menu: json['menu'] != null 
          ? FainzyMenu.fromJson(json['menu'] as Map<String, dynamic>)
          : null,
      sides: json['sides'] != null 
          ? List<Side>.from(json['sides'].map((x) => Side.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'menu': menu?.toJson(),
      'sides': sides?.map((x) => x.toJson()).toList(),
    };
  }

  double get totalPrice => (price ?? 0.0) * (quantity ?? 0);
  
  double get sidesTotal {
    if (sides == null || sides!.isEmpty) return 0.0;
    return sides!.fold(0.0, (sum, side) => sum + (side.price ?? 0.0));
  }
  
  double get totalWithSides => totalPrice + (sidesTotal * (quantity ?? 1));

  FainzyCartItem copyWith({
    int? id,
    String? name,
    double? price,
    int? quantity,
    FainzyMenu? menu,
    List<Side>? sides,
  }) {
    return FainzyCartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      menu: menu ?? this.menu,
      sides: sides ?? this.sides,
    );
  }
}
