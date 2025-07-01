class FainzyCategory {
  const FainzyCategory({
    required this.id,
    required this.name,
    this.created,
    this.modified,
    this.subentity,
  });

  factory FainzyCategory.fromJson(Map<String, dynamic> json) {
    return FainzyCategory(
      id: json['id'] as int?,
      name: json['name'] as String?,
      created: json['created'] as String?,
      modified: json['modified'] as String?,
      subentity: json['subentity'] as int?,
    );
  }

  factory FainzyCategory.all() {
    return const FainzyCategory(
      id: -1,
      name: 'All',
    );
  }

  final int? id;
  final String? name;
  final String? created;
  final String? modified;
  final int? subentity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created': created,
      'modified': modified,
      'subentity': subentity,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FainzyCategory &&
        other.id == id &&
        other.name == name &&
        other.created == created &&
        other.modified == modified &&
        other.subentity == subentity;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ created.hashCode ^ modified.hashCode ^ subentity.hashCode;

  @override
  String toString() => 'FainzyCategory(id: $id, name: $name, created: $created, modified: $modified, subentity: $subentity)';
}
