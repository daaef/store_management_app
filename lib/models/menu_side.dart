import 'package:json_annotation/json_annotation.dart';

part 'menu_side.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MenuSide {
  final int? id;
  final String? title;
  final String? name;
  final double? price;
  final bool? isDefault;
  final bool? isSelected;
  final DateTime? created;
  final DateTime? modified;
  final int? menu;
  final int? subentity;

  const MenuSide({
    this.id,
    this.title,
    this.name,
    this.price,
    this.isDefault,
    this.isSelected,
    this.created,
    this.modified,
    this.menu,
    this.subentity,
  });

  factory MenuSide.fromJson(Map<String, dynamic> json) =>
      _$MenuSideFromJson(json);

  Map<String, dynamic> toJson() => _$MenuSideToJson(this);

  MenuSide copyWith({
    int? id,
    String? title,
    String? name,
    double? price,
    bool? isDefault,
    bool? isSelected,
    DateTime? created,
    DateTime? modified,
    int? menu,
    int? subentity,
  }) {
    return MenuSide(
      id: id ?? this.id,
      title: title ?? this.title,
      name: name ?? this.name,
      price: price ?? this.price,
      isDefault: isDefault ?? this.isDefault,
      isSelected: isSelected ?? this.isSelected,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      menu: menu ?? this.menu,
      subentity: subentity ?? this.subentity,
    );
  }

  // Convenience getter for display name
  String get displayName => title ?? name ?? '';

  @override
  String toString() {
    return 'MenuSide(id: $id, title: $title, name: $name, price: $price, isDefault: $isDefault, isSelected: $isSelected, created: $created, modified: $modified, menu: $menu, subentity: $subentity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MenuSide &&
        other.id == id &&
        other.title == title &&
        other.name == name &&
        other.price == price &&
        other.isDefault == isDefault &&
        other.isSelected == isSelected &&
        other.created == created &&
        other.modified == modified &&
        other.menu == menu &&
        other.subentity == subentity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        name.hashCode ^
        price.hashCode ^
        isDefault.hashCode ^
        isSelected.hashCode ^
        created.hashCode ^
        modified.hashCode ^
        menu.hashCode ^
        subentity.hashCode;
  }
}
