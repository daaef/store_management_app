import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'location.dart';

part 'store_data.g.dart';

@JsonSerializable()
class StoreData extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  @JsonKey(name: 'mobile_number')
  final String? phoneNumber;
  final String? currency;
  @JsonKey(name: 'start_time')
  final String? startTime;
  @JsonKey(name: 'closing_time')
  final String? closingTime;
  @JsonKey(name: 'opening_days')
  final String? openingDays;
  final Location? location;
  final StoreImage? image;
  @JsonKey(name: 'carousel_uploads')
  final List<CarouselUpload>? carouselUploads;
  final bool? setup;
  final String? branch;
  @JsonKey(name: 'store_type')
  final String? storeType;
  @JsonKey(name: 'store_category')
  final String? storeCategory;
  final double? rating;
  @JsonKey(name: 'total_reviews')
  final int? totalReviews;
  final int? status;
  @JsonKey(name: 'notification_id')
  final String? notificationId;
  @JsonKey(name: 'gps_coordinates')
  final GpsCoordinatesData? gpsCoordinates;
  final AddressData? address;
  @JsonKey(name: 'is_open')
  final bool? isOpen;

  // Helper property to convert opening_days string to List<int> for working days
  List<int> get workingDays {
    if (openingDays == null || openingDays!.isEmpty) return [];
    
    final dayMap = {
      'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4, 
      'fri': 5, 'sat': 6, 'sun': 0
    };
    
    return openingDays!
        .split(',')
        .map((day) => dayMap[day.trim().toLowerCase()] ?? 0)
        .where((day) => day != 0)
        .toList();
  }

  // Helper property to get the main image URL
  String? get imagePath => image?.upload;

  // Helper property to get carousel image URLs
  List<String> get carouselImageUrls {
    return carouselUploads?.map((upload) => upload.upload).toList() ?? [];
  }

  // Backward compatibility getter for isSetup
  bool? get isSetup => setup;

  const StoreData({
    this.id,
    this.name,
    this.description,
    this.phoneNumber,
    this.currency,
    this.startTime,
    this.closingTime,
    this.openingDays,
    this.location,
    this.image,
    this.carouselUploads,
    this.setup,
    this.branch,
    this.storeType,
    this.storeCategory,
    this.rating,
    this.totalReviews,
    this.status,
    this.notificationId,
    this.gpsCoordinates,
    this.address,
    this.isOpen,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) =>
      _$StoreDataFromJson(json);

  Map<String, dynamic> toJson() => _$StoreDataToJson(this);

  StoreData copyWith({
    int? id,
    String? name,
    String? description,
    String? phoneNumber,
    String? currency,
    String? startTime,
    String? closingTime,
    String? openingDays,
    Location? location,
    StoreImage? image,
    List<CarouselUpload>? carouselUploads,
    bool? setup,
    String? branch,
    String? storeType,
    String? storeCategory,
    double? rating,
    int? totalReviews,
    int? status,
    String? notificationId,
    GpsCoordinatesData? gpsCoordinates,
    AddressData? address,
    bool? isOpen,
  }) {
    return StoreData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currency: currency ?? this.currency,
      startTime: startTime ?? this.startTime,
      closingTime: closingTime ?? this.closingTime,
      openingDays: openingDays ?? this.openingDays,
      location: location ?? this.location,
      image: image ?? this.image,
      carouselUploads: carouselUploads ?? this.carouselUploads,
      setup: setup ?? this.setup,
      branch: branch ?? this.branch,
      storeType: storeType ?? this.storeType,
      storeCategory: storeCategory ?? this.storeCategory,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      status: status ?? this.status,
      notificationId: notificationId ?? this.notificationId,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      address: address ?? this.address,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        phoneNumber,
        currency,
        startTime,
        closingTime,
        openingDays,
        location,
        image,
        carouselUploads,
        setup,
        branch,
        storeType,
        storeCategory,
        rating,
        totalReviews,
        status,
        notificationId,
        gpsCoordinates,
        address,
        isOpen,
      ];

  @override
  String toString() {
    return 'StoreData(id: $id, name: $name, description: $description, phoneNumber: $phoneNumber, currency: $currency, startTime: $startTime, closingTime: $closingTime, openingDays: $openingDays, setup: $setup)';
  }
}

// Supporting classes for nested data
@JsonSerializable()
class StoreImage extends Equatable {
  final int? id;
  final int? subentity;
  final String upload;

  const StoreImage({
    this.id,
    this.subentity,
    required this.upload,
  });

  factory StoreImage.fromJson(Map<String, dynamic> json) =>
      _$StoreImageFromJson(json);

  Map<String, dynamic> toJson() => _$StoreImageToJson(this);

  @override
  List<Object?> get props => [id, subentity, upload];
}

@JsonSerializable()
class CarouselUpload extends Equatable {
  final int id;
  final String? menu;
  final String upload;
  final String created;
  final String modified;
  final int subentity;

  const CarouselUpload({
    required this.id,
    this.menu,
    required this.upload,
    required this.created,
    required this.modified,
    required this.subentity,
  });

  factory CarouselUpload.fromJson(Map<String, dynamic> json) =>
      _$CarouselUploadFromJson(json);

  Map<String, dynamic> toJson() => _$CarouselUploadToJson(this);

  @override
  List<Object?> get props => [id, menu, upload, created, modified, subentity];
}

@JsonSerializable()
class GpsCoordinatesData extends Equatable {
  final String type;
  final List<double> coordinates;

  const GpsCoordinatesData({
    required this.type,
    required this.coordinates,
  });

  factory GpsCoordinatesData.fromJson(Map<String, dynamic> json) {
    return GpsCoordinatesData(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List).cast<double>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;
  double get longitude => coordinates.length > 0 ? coordinates[0] : 0.0;

  @override
  List<Object?> get props => [type, coordinates];
}

@JsonSerializable()
class AddressData extends Equatable {
  final int id;
  final String name;
  final int subentity;
  @JsonKey(name: 'floor_number')
  final String? floorNumber;
  final String country;
  @JsonKey(name: 'post_code')
  final String? postCode;
  final String state;
  final String city;
  final String? ward;
  final String? village;
  @JsonKey(name: 'service_area')
  final int? serviceArea;
  @JsonKey(name: 'location_type')
  final String? locationType;
  @JsonKey(name: 'gps_coordinates')
  final GpsCoordinatesData? gpsCoordinates;
  @JsonKey(name: 'house_details')
  final String? houseDetails;
  @JsonKey(name: 'address_details')
  final String? addressDetails;
  @JsonKey(name: 'operation_mode')
  final String? operationMode;
  @JsonKey(name: 'position_location')
  final String? positionLocation;
  @JsonKey(name: 'ros_x_position')
  final double? rosXPosition;
  @JsonKey(name: 'ros_y_position')
  final double? rosYPosition;
  @JsonKey(name: 'ros_z_position')
  final double? rosZPosition;
  @JsonKey(name: 'ros_orientation_x')
  final double? rosOrientationX;
  @JsonKey(name: 'ros_orientation_y')
  final double? rosOrientationY;
  @JsonKey(name: 'ros_orientation_z')
  final double? rosOrientationZ;
  @JsonKey(name: 'ros_orientation_w')
  final double? rosOrientationW;
  @JsonKey(name: 'is_default')
  final bool? isDefault;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  const AddressData({
    required this.id,
    required this.name,
    required this.subentity,
    this.floorNumber,
    required this.country,
    this.postCode,
    required this.state,
    required this.city,
    this.ward,
    this.village,
    this.serviceArea,
    this.locationType,
    this.gpsCoordinates,
    this.houseDetails,
    this.addressDetails,
    this.operationMode,
    this.positionLocation,
    this.rosXPosition,
    this.rosYPosition,
    this.rosZPosition,
    this.rosOrientationX,
    this.rosOrientationY,
    this.rosOrientationZ,
    this.rosOrientationW,
    this.isDefault,
    this.isActive,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) =>
      _$AddressDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddressDataToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        subentity,
        floorNumber,
        country,
        postCode,
        state,
        city,
        ward,
        village,
        serviceArea,
        locationType,
        gpsCoordinates,
        houseDetails,
        addressDetails,
        operationMode,
        positionLocation,
        rosXPosition,
        rosYPosition,
        rosZPosition,
        rosOrientationX,
        rosOrientationY,
        rosOrientationZ,
        rosOrientationW,
        isDefault,
        isActive,
      ];
}
