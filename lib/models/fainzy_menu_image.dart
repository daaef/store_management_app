import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'fainzy_menu_image.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FainzyMenuImage {
  const FainzyMenuImage({
    this.id,
    this.menu,
    this.upload,
    this.created,
    this.modified,
    this.subentity,
  });

  factory FainzyMenuImage.fromJson(Map<String, dynamic> json) =>
      _$FainzyMenuImageFromJson(json);

  final int? id;
  final int? menu;
  final String? upload;
  final DateTime? created;
  final DateTime? modified;
  final int? subentity;

  FainzyMenuImage copyWith({
    int? id,
    int? menu,
    String? upload,
    DateTime? created,
    DateTime? modified,
    int? subentity,
  }) {
    return FainzyMenuImage(
      id: id ?? this.id,
      menu: menu ?? this.menu,
      upload: upload ?? this.upload,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      subentity: subentity ?? this.subentity,
    );
  }

  Map<String, dynamic> toJson() => _$FainzyMenuImageToJson(this);

  @override
  String toString() {
    return 'FainzyMenuImage(id: $id, menu: $menu, upload: $upload, created: $created, modified: $modified, subentity: $subentity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FainzyMenuImage &&
        other.id == id &&
        other.menu == menu &&
        other.upload == upload &&
        other.created == created &&
        other.modified == modified &&
        other.subentity == subentity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        menu.hashCode ^
        upload.hashCode ^
        created.hashCode ^
        modified.hashCode ^
        subentity.hashCode;
  }

  /// Convenience getters
  bool get hasValidUrl => upload != null && upload!.isNotEmpty;
  
  String get fileName {
    if (upload == null) return '';
    return upload!.split('/').last.split('_').first;
  }
  
  bool get isCloudinaryImage => upload?.contains('cloudinary.com') ?? false;
}