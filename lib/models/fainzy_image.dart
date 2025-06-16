import 'package:json_annotation/json_annotation.dart';

part 'fainzy_image.g.dart';

@JsonSerializable()
class FainzyImage {
  final int? id;
  final String? created;
  final String? modified;
  final String? upload;
  final int? menu;
  final int? subentity;

  const FainzyImage({
    this.id,
    this.created,
    this.modified,
    this.upload,
    this.menu,
    this.subentity,
  });

  factory FainzyImage.fromJson(Map<String, dynamic> json) =>
      _$FainzyImageFromJson(json);

  Map<String, dynamic> toJson() => _$FainzyImageToJson(this);

  FainzyImage copyWith({
    int? id,
    String? created,
    String? modified,
    String? upload,
    int? menu,
    int? subentity,
  }) {
    return FainzyImage(
      id: id ?? this.id,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      upload: upload ?? this.upload,
      menu: menu ?? this.menu,
      subentity: subentity ?? this.subentity,
    );
  }

  @override
  String toString() {
    return 'FainzyImage(id: $id, created: $created, modified: $modified, upload: $upload, menu: $menu, subentity: $subentity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FainzyImage &&
        other.id == id &&
        other.created == created &&
        other.modified == modified &&
        other.upload == upload &&
        other.menu == menu &&
        other.subentity == subentity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        created.hashCode ^
        modified.hashCode ^
        upload.hashCode ^
        menu.hashCode ^
        subentity.hashCode;
  }
}
