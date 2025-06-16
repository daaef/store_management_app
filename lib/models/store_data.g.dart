// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreData _$StoreDataFromJson(Map<String, dynamic> json) => StoreData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      phoneNumber: json['mobile_number'] as String?,
      currency: json['currency'] as String?,
      startTime: json['start_time'] as String?,
      closingTime: json['closing_time'] as String?,
      openingDays: json['opening_days'] as String?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      image: json['image'] == null
          ? null
          : StoreImage.fromJson(json['image'] as Map<String, dynamic>),
      carouselUploads: (json['carousel_uploads'] as List<dynamic>?)
          ?.map((e) => CarouselUpload.fromJson(e as Map<String, dynamic>))
          .toList(),
      setup: json['setup'] as bool?,
      branch: json['branch'] as String?,
      storeType: json['store_type'] as String?,
      storeCategory: json['store_category'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalReviews: (json['total_reviews'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      notificationId: json['notification_id'] as String?,
      gpsCoordinates: json['gps_coordinates'] == null
          ? null
          : GpsCoordinatesData.fromJson(
              json['gps_coordinates'] as Map<String, dynamic>),
      address: json['address'] == null
          ? null
          : AddressData.fromJson(json['address'] as Map<String, dynamic>),
      isOpen: json['is_open'] as bool?,
    );

Map<String, dynamic> _$StoreDataToJson(StoreData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'mobile_number': instance.phoneNumber,
      'currency': instance.currency,
      'start_time': instance.startTime,
      'closing_time': instance.closingTime,
      'opening_days': instance.openingDays,
      'location': instance.location,
      'image': instance.image,
      'carousel_uploads': instance.carouselUploads,
      'setup': instance.setup,
      'branch': instance.branch,
      'store_type': instance.storeType,
      'store_category': instance.storeCategory,
      'rating': instance.rating,
      'total_reviews': instance.totalReviews,
      'status': instance.status,
      'notification_id': instance.notificationId,
      'gps_coordinates': instance.gpsCoordinates,
      'address': instance.address,
      'is_open': instance.isOpen,
    };

StoreImage _$StoreImageFromJson(Map<String, dynamic> json) => StoreImage(
      id: (json['id'] as num?)?.toInt(),
      subentity: (json['subentity'] as num?)?.toInt(),
      upload: json['upload'] as String,
    );

Map<String, dynamic> _$StoreImageToJson(StoreImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subentity': instance.subentity,
      'upload': instance.upload,
    };

CarouselUpload _$CarouselUploadFromJson(Map<String, dynamic> json) =>
    CarouselUpload(
      id: (json['id'] as num).toInt(),
      menu: json['menu'] as String?,
      upload: json['upload'] as String,
      created: json['created'] as String,
      modified: json['modified'] as String,
      subentity: (json['subentity'] as num).toInt(),
    );

Map<String, dynamic> _$CarouselUploadToJson(CarouselUpload instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menu': instance.menu,
      'upload': instance.upload,
      'created': instance.created,
      'modified': instance.modified,
      'subentity': instance.subentity,
    };

GpsCoordinatesData _$GpsCoordinatesDataFromJson(Map<String, dynamic> json) =>
    GpsCoordinatesData(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$GpsCoordinatesDataToJson(GpsCoordinatesData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

AddressData _$AddressDataFromJson(Map<String, dynamic> json) => AddressData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      subentity: (json['subentity'] as num).toInt(),
      floorNumber: json['floor_number'] as String?,
      country: json['country'] as String,
      postCode: json['post_code'] as String?,
      state: json['state'] as String,
      city: json['city'] as String,
      ward: json['ward'] as String?,
      village: json['village'] as String?,
      serviceArea: (json['service_area'] as num?)?.toInt(),
      locationType: json['location_type'] as String?,
      gpsCoordinates: json['gps_coordinates'] == null
          ? null
          : GpsCoordinatesData.fromJson(
              json['gps_coordinates'] as Map<String, dynamic>),
      houseDetails: json['house_details'] as String?,
      addressDetails: json['address_details'] as String?,
      operationMode: json['operation_mode'] as String?,
      positionLocation: json['position_location'] as String?,
      rosXPosition: (json['ros_x_position'] as num?)?.toDouble(),
      rosYPosition: (json['ros_y_position'] as num?)?.toDouble(),
      rosZPosition: (json['ros_z_position'] as num?)?.toDouble(),
      rosOrientationX: (json['ros_orientation_x'] as num?)?.toDouble(),
      rosOrientationY: (json['ros_orientation_y'] as num?)?.toDouble(),
      rosOrientationZ: (json['ros_orientation_z'] as num?)?.toDouble(),
      rosOrientationW: (json['ros_orientation_w'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool?,
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$AddressDataToJson(AddressData instance) =>
    <String, dynamic>{
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
      'location_type': instance.locationType,
      'gps_coordinates': instance.gpsCoordinates,
      'house_details': instance.houseDetails,
      'address_details': instance.addressDetails,
      'operation_mode': instance.operationMode,
      'position_location': instance.positionLocation,
      'ros_x_position': instance.rosXPosition,
      'ros_y_position': instance.rosYPosition,
      'ros_z_position': instance.rosZPosition,
      'ros_orientation_x': instance.rosOrientationX,
      'ros_orientation_y': instance.rosOrientationY,
      'ros_orientation_z': instance.rosOrientationZ,
      'ros_orientation_w': instance.rosOrientationW,
      'is_default': instance.isDefault,
      'is_active': instance.isActive,
    };
