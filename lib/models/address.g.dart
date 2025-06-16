// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      subentity: (json['subentity'] as num?)?.toInt(),
      floorNumber: json['floor_number'] as String?,
      country: json['country'] as String?,
      postCode: json['post_code'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      ward: json['ward'] as String?,
      village: json['village'] as String?,
      serviceArea: (json['service_area'] as num?)?.toInt(),
      addressDetails: json['address_details'] as String?,
      locationType: json['location_type'] as String?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subentity': instance.subentity,
      'floor_number': instance.floorNumber,
      'country': instance.country,
      'post_code': instance.postCode,
      'state': instance.state,
      'city': instance.city,
      'ward': instance.ward,
      'village': instance.village,
      'service_area': instance.serviceArea,
      'address_details': instance.addressDetails,
      'location_type': instance.locationType,
    };
