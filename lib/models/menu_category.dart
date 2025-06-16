import 'package:json_annotation/json_annotation.dart';

part 'menu_category.g.dart';

@JsonSerializable()
class MenuCategory {
  final int? id;
  final String? name;
  final DateTime? created;
  final DateTime? modified;
  final int? subentity;

  const MenuCategory({
    this.id,
    this.name,
    this.created,
    this.modified,
    this.subentity,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$MenuCategoryToJson(this);

  // Static method for "All" category
  factory MenuCategory.all() {
    return const MenuCategory(
      id: -1,
      name: 'All',
    );
  }

  MenuCategory copyWith({
    int? id,
    String? name,
    DateTime? created,
    DateTime? modified,
    int? subentity,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      subentity: subentity ?? this.subentity,
    );
  }

  @override
  String toString() {
    return 'MenuCategory(id: $id, name: $name, created: $created, modified: $modified, subentity: $subentity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MenuCategory &&
        other.id == id &&
        other.name == name &&
        other.created == created &&
        other.modified == modified &&
        other.subentity == subentity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        created.hashCode ^
        modified.hashCode ^
        subentity.hashCode;
  }
}
