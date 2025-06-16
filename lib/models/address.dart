import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final int? id;
  final String? name;
  final int? subentity;
  @JsonKey(name: 'floor_number')
  final String? floorNumber;
  final String? country;
  @JsonKey(name: 'post_code')
  final String? postCode;
  final String? state;
  final String? city;
  final String? ward;
  final String? village;
  @JsonKey(name: 'service_area')
  final int? serviceArea;
  @JsonKey(name: 'address_details')
  final String? addressDetails;
  @JsonKey(name: 'location_type')
  final String? locationType;

  const Address({
    this.id,
    this.name,
    this.subentity,
    this.floorNumber,
    this.country,
    this.postCode,
    this.state,
    this.city,
    this.ward,
    this.village,
    this.serviceArea,
    this.addressDetails,
    this.locationType,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  String toString() {
    return 'Address(id: $id, name: $name, subentity: $subentity, floorNumber: $floorNumber, country: $country, postCode: $postCode, state: $state, city: $city, ward: $ward, village: $village, serviceArea: $serviceArea, addressDetails: $addressDetails, locationType: $locationType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Address &&
        other.id == id &&
        other.name == name &&
        other.subentity == subentity &&
        other.floorNumber == floorNumber &&
        other.country == country &&
        other.postCode == postCode &&
        other.state == state &&
        other.city == city &&
        other.ward == ward &&
        other.village == village &&
        other.serviceArea == serviceArea &&
        other.addressDetails == addressDetails &&
        other.locationType == locationType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        subentity.hashCode ^
        floorNumber.hashCode ^
        country.hashCode ^
        postCode.hashCode ^
        state.hashCode ^
        city.hashCode ^
        ward.hashCode ^
        village.hashCode ^
        serviceArea.hashCode ^
        addressDetails.hashCode ^
        locationType.hashCode;
  }
}
