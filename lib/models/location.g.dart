// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GpsCoordinates _$GpsCoordinatesFromJson(Map<String, dynamic> json) =>
    GpsCoordinates(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$GpsCoordinatesToJson(GpsCoordinates instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      name: json['name'] as String?,
      country: json['country'] as String?,
      postCode: json['post_code'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      ward: json['ward'] as String?,
      village: json['village'] as String?,
      locationType: json['location_type'] as String?,
      gpsCoordinates: json['gps_cordinates'] == null
          ? null
          : GpsCoordinates.fromJson(
              json['gps_cordinates'] as Map<String, dynamic>),
      addressDetails: json['address_details'] as String?,
      serviceArea: (json['service_area'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'name': instance.name,
      'country': instance.country,
      'post_code': instance.postCode,
      'state': instance.state,
      'city': instance.city,
      'ward': instance.ward,
      'village': instance.village,
      'location_type': instance.locationType,
      'gps_cordinates': instance.gpsCoordinates,
      'address_details': instance.addressDetails,
      'service_area': instance.serviceArea,
    };
