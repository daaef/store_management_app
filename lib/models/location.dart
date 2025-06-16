import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
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

  factory GpsCoordinates.fromJson(Map<String, dynamic> json) =>
      _$GpsCoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$GpsCoordinatesToJson(this);

  @override
  List<Object?> get props => [type, coordinates];

  @override
  String toString() {
    return 'GpsCoordinates(type: $type, coordinates: $coordinates)';
  }
}

@JsonSerializable()
class Location extends Equatable {
  final String? name;
  final String? country;
  @JsonKey(name: 'post_code')
  final String? postCode;
  final String? state;
  final String? city;
  final String? ward;
  final String? village;
  @JsonKey(name: 'location_type')
  final String? locationType;
  @JsonKey(name: 'gps_cordinates')
  final GpsCoordinates? gpsCoordinates;
  @JsonKey(name: 'address_details')
  final String? addressDetails;
  @JsonKey(name: 'service_area')
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

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

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
