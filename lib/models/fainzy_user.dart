class FainzyUser {
  final int? id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? phoneNumber;

  const FainzyUser({
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.phoneNumber,
  });

  factory FainzyUser.fromJson(Map<String, dynamic> json) {
    return FainzyUser(
      id: json['id'] != null 
          ? (json['id'] is int 
              ? json['id'] as int 
              : int.tryParse(json['id'].toString()))
          : null,
      name: json['name'] as String?,
      firstName: json['first_name'] as String? ?? json['firstName'] as String?,
      lastName: json['last_name'] as String? ?? json['lastName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'phone_number': phoneNumber,
    };
  }

  /// Get the full name of the user
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (name != null) {
      return name!;
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'Anonymous Customer';
  }
}
