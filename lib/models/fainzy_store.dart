class FainzyStore {
  final int? id;
  final String? name;

  const FainzyStore({
    this.id,
    this.name,
  });

  factory FainzyStore.fromJson(Map<String, dynamic> json) {
    return FainzyStore(
      id: json['id'] != null 
          ? (json['id'] is int 
              ? json['id'] as int 
              : int.tryParse(json['id'].toString()))
          : null,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
