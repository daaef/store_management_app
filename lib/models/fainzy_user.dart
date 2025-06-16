import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'fainzy_user.g.dart';

@JsonSerializable()
class FainzyUser {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final DateTime? created;
  final DateTime? updated;

  const FainzyUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.created,
    this.updated,
  });

  FainzyUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    DateTime? created,
    DateTime? updated,
  }) {
    return FainzyUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  factory FainzyUser.fromJson(Map<String, dynamic> json) =>
      _$FainzyUserFromJson(json);

  Map<String, dynamic> toJson() => _$FainzyUserToJson(this);

  @override
  String toString() {
    return 'FainzyUser(id: $id, name: $name, email: $email, phone: $phone, created: $created, updated: $updated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FainzyUser &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.created == created &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        created.hashCode ^
        updated.hashCode;
  }
}
