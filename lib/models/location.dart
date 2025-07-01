import 'package:equatable/equatable.dart';

class GpsCoordinates extends Equatable {
  final String type;
  final List<double> coordinates;

  const GpsCoordinates({
    required this.type,
    required this.coordinates,
  });
 
  // Convenience getters for backward compatibility
  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;

  // Factory constructor to create from lat/lng
  factory GpsCoordinates.fromLatLng(double latitude, double longitude) {
    return GpsCoordinates(
      type: 'Point',
      coordinates: [longitude, latitude],
    );
  }

  factory GpsCoordinates.fromJson(Map<String, dynamic> json) {
    return GpsCoordinates(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  @override
  List<Object?> get props => [type, coordinates];

  @override
  String toString() {
    return 'GpsCoordinates(type: $type, coordinates: $coordinates)';
  }
}

class Location extends Equatable {
  final String? name;
  final String? country;
  final String? postCode;
  final String? state;
  final String? city;
  final String? ward;
  final String? village;
  final String? locationType;
  final GpsCoordinates? gpsCoordinates;
  final String? addressDetails;
  final int? serviceArea;

  // Additional convenience getters
  String? get street => addressDetails;

  const Location({
    this.name,
    this.country,
    this.postCode,
    this.state,
    this.city,
    this.ward,
    this.village,
    this.locationType,
    this.gpsCoordinates,
    this.addressDetails,
    this.serviceArea,
  });

  @override
  String toString() {
    return 'Location(name: $name, country: $country, postCode: $postCode, state: $state, city: $city, ward: $ward, village: $village, locationType: $locationType, gpsCoordinates: $gpsCoordinates, addressDetails: $addressDetails, serviceArea: $serviceArea)';
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String?,
      country: json['country'] as String?,
      postCode: json['post_code'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      ward: json['ward'] as String?,
      village: json['village'] as String?,
      locationType: json['location_type'] as String?,
      gpsCoordinates: json['gps_coordinates'] != null 
          ? GpsCoordinates.fromJson(json['gps_coordinates'] as Map<String, dynamic>)
          : null,
      addressDetails: json['address_details'] as String?,
      serviceArea: json['service_area'] != null 
          ? (json['service_area'] is int 
              ? json['service_area'] as int 
              : int.tryParse(json['service_area'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'post_code': postCode,
      'state': state,
      'city': city,
      'ward': ward,
      'village': village,
      'location_type': locationType,
      'gps_coordinates': gpsCoordinates?.toJson(),
      'address_details': addressDetails,
      'service_area': serviceArea,
    };
  }

  Location copyWith({
    String? name,
    String? country,
    String? postCode,
    String? state,
    String? city,
    String? ward,
    String? village,
    String? locationType,
    GpsCoordinates? gpsCoordinates,
    String? addressDetails,
    int? serviceArea,
  }) {
    return Location(
      name: name ?? this.name,
      country: country ?? this.country,
      postCode: postCode ?? this.postCode,
      state: state ?? this.state,
      city: city ?? this.city,
      ward: ward ?? this.ward,
      village: village ?? this.village,
      locationType: locationType ?? this.locationType,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      addressDetails: addressDetails ?? this.addressDetails,
      serviceArea: serviceArea ?? this.serviceArea,
    );
  }

  @override
  List<Object?> get props => [
        name,
        country,
        postCode,
        state,
        city,
        ward,
        village,
        locationType,
        gpsCoordinates,
        addressDetails,
        serviceArea,
      ];
}
