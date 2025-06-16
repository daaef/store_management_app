// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fainzy_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FainzyStore _$FainzyStoreFromJson(Map<String, dynamic> json) => FainzyStore(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      mobileNumber: json['mobile_number'] as String?,
      gpsCoordinates: json['gps_coordinates'] as Map<String, dynamic>?,
      rating: (json['rating'] as num?)?.toDouble(),
      isOpen: json['is_open'] as bool?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      notificationId: json['notification_id'] as String?,
      image: json['image'] == null
          ? null
          : FainzyImage.fromJson(json['image'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FainzyStoreToJson(FainzyStore instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mobile_number': instance.mobileNumber,
      'gps_coordinates': instance.gpsCoordinates,
      'rating': instance.rating,
      'is_open': instance.isOpen,
      'address': instance.address,
      'notification_id': instance.notificationId,
      'image': instance.image,
    };
