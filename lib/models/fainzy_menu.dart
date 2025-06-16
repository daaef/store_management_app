import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'fainzy_menu_image.dart';

part 'fainzy_menu.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FainzyMenu {
  const FainzyMenu({
    this.id,
    this.name,
    this.description,
    this.ingredients,
    this.price,
    this.discount,
    this.discountPrice,
    this.currencySymbol,
    this.status,
    this.category,
    this.subentity,
    this.created,
    this.modified,
    this.images,
    this.sides,
  });

  factory FainzyMenu.fromJson(Map<String, dynamic> json) =>
      _$FainzyMenuFromJson(json);

  final int? id;
  final String? name;
  final String? description;
  final String? ingredients;
  final double? price;
  final double? discount;
  final double? discountPrice;
  final String? currencySymbol;
  final String? status;
  final int? category;
  final int? subentity;
  final DateTime? created;
  final DateTime? modified;
  final List<FainzyMenuImage>? images;
  final List<dynamic>? sides;  // Changed from List<String>? to List<dynamic>?

  FainzyMenu copyWith({
    int? id,
    String? name,
    String? description,
    String? ingredients,
    double? price,
    double? discount,
    double? discountPrice,
    String? currencySymbol,
    String? status,
    int? category,
    int? subentity,
    DateTime? created,
    DateTime? modified,
    List<FainzyMenuImage>? images,
    List<dynamic>? sides,  // Changed from List<String>? to List<dynamic>?
  }) {
    return FainzyMenu(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      discountPrice: discountPrice ?? this.discountPrice,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      status: status ?? this.status,
      category: category ?? this.category,
      subentity: subentity ?? this.subentity,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      images: images ?? this.images,
      sides: sides ?? this.sides,
    );
  }

  Map<String, dynamic> toJson() => _$FainzyMenuToJson(this);

  @override
  String toString() {
    return 'FainzyMenu(id: $id, name: $name, description: $description, ingredients: $ingredients, price: $price, discount: $discount, discountPrice: $discountPrice, currencySymbol: $currencySymbol, status: $status, category: $category, subentity: $subentity, created: $created, modified: $modified, images: $images, sides: $sides)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FainzyMenu &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.ingredients == ingredients &&
        other.price == price &&
        other.discount == discount &&
        other.discountPrice == discountPrice &&
        other.currencySymbol == currencySymbol &&
        other.status == status &&
        other.category == category &&
        other.subentity == subentity &&
        other.created == created &&
        other.modified == modified &&
        other.images == images &&
        other.sides == sides;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        ingredients.hashCode ^
        price.hashCode ^
        discount.hashCode ^
        discountPrice.hashCode ^
        currencySymbol.hashCode ^
        status.hashCode ^
        category.hashCode ^
        subentity.hashCode ^
        created.hashCode ^
        modified.hashCode ^
        images.hashCode ^
        sides.hashCode;
  }

  /// Convenience getters
  bool get isAvailable => status?.toLowerCase() == 'available';
  bool get isOutOfStock => status?.toLowerCase() == 'out_of_stock';
  bool get isUnavailable => status?.toLowerCase() == 'unavailable';
  
  bool get hasDiscount => (discount ?? 0.0) > 0.0;
  
  double get finalPrice {
    if (hasDiscount && discountPrice != null && discountPrice! > 0.0) {
      return discountPrice!;
    }
    return price ?? 0.0;
  }
  
  double get savingsAmount {
    if (hasDiscount && price != null) {
      return price! - finalPrice;
    }
    return 0.0;
  }
  
  double get discountPercentage {
    if (hasDiscount && price != null && price! > 0) {
      return ((discount ?? 0.0) / 100.0);
    }
    return 0.0;
  }
  
  String? get primaryImageUrl {
    if (images != null && images!.isNotEmpty) {
      return images!.first.upload;
    }
    return null;
  }
  
  bool get hasImages => images != null && images!.isNotEmpty;
  bool get hasSides => sides != null && sides!.isNotEmpty;
  
  // Helper method to get sides as strings
  List<String> get sidesAsStrings {
    if (sides == null) return [];
    return sides!.map((e) => e.toString()).toList();
  }
}