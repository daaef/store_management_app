class FainzyMenu {
    FainzyMenu({
        this.id,
        this.category,
        this.subentity,
        this.subentityDetails,
        this.sides = const [],
        this.name,
        this.price,
        this.description,
        this.ingredients,
        this.status,
        this.discount,
        this.discountPrice,
        this.images,
        this.created,
        this.modified,
    });

    final int? id;
    final int? category;
    final int? subentity;
    final Subentity? subentityDetails;
    final List<Side> sides;
    final String? name;
    final double? price;
    final String? description;
    final String? ingredients;
    final String? status;
    final double? discount;
    final double? discountPrice;
    final List<ImageElement>? images;
    final DateTime? created;
    final DateTime? modified;

    // Status convenience getters
    bool get isSoldOut => status == 'sold_out';
    bool get isAvailable => status == 'available';
    bool get isUnavailable => status == 'unavailable';
    
    // Currency symbol getter (for compatibility with last_mile_store)
    String? get currencySymbol => '¥'; // Default to Japanese Yen for this app

    factory FainzyMenu.fromJson(Map<String, dynamic> json){ 
        return FainzyMenu(
            id: json["id"],
            category: json["category"],
            subentity: json["subentity"],
            subentityDetails: json["subentity_details"] == null ? null : Subentity.fromJson(json["subentity_details"]),
            sides: json["sides"] == null ? [] : List<Side>.from(json["sides"]!.map((x) => Side.fromJson(x))),
            name: json["name"],
            price: json["price"] != null ? (json["price"] as num).toDouble() : null,
            description: json["description"],
            ingredients: json["ingredients"],
            status: json["status"],
            discount: json["discount"] != null ? (json["discount"] as num).toDouble() : null,
            discountPrice: json["discount_price"] != null ? (json["discount_price"] as num).toDouble() : null,
            images: json["images"] == null ? null : List<ImageElement>.from(json["images"]!.map((x) => ImageElement.fromJson(x))),
            created: json["created"] == null ? null : DateTime.tryParse(json["created"].toString()),
            modified: json["modified"] == null ? null : DateTime.tryParse(json["modified"].toString()),
        );
    }

    Map<String, dynamic> toJson({bool includeSides = false}) => {
        "id": id,
        "category": category,
        "subentity": subentity,
        "subentity_details": subentityDetails?.toJson(),
        // Only include sides if explicitly requested
        if (includeSides) "sides": sides.map((x) => x.toJson()).toList(),
        "name": name,
        "price": price,
        "description": description,
        "ingredients": ingredients,
        "status": status,
        // Always send discount field (0 by default)
        "discount": discount ?? 0,
        // Send discount_price field when calculated
        if (discountPrice != null) "discount_price": discountPrice,
        "images": images?.map((x) => x.toJson()).toList(),
        "created": created?.toIso8601String(),
        "modified": modified?.toIso8601String(),
    };

}

class ImageElement {
    ImageElement({
        this.id,
        this.upload,
        this.created,
        this.modified,
        this.menu,
        this.subentity,
    });

    final int? id;
    final String? upload;
    final DateTime? created;
    final DateTime? modified;
    final int? menu;
    final int? subentity;

    factory ImageElement.fromJson(Map<String, dynamic> json){ 
        return ImageElement(
            id: json["id"],
            upload: json["upload"],
            created: json["created"] == null ? null : DateTime.tryParse(json["created"].toString()),
            modified: json["modified"] == null ? null : DateTime.tryParse(json["modified"].toString()),
            menu: json["menu"],
            subentity: json["subentity"],
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "upload": upload,
        "created": created?.toIso8601String(),
        "modified": modified?.toIso8601String(),
        "menu": menu,
        "subentity": subentity,
    };

}

class Side {
    Side({
        this.id,
        this.created,
        this.modified,
        this.name,
        this.price,
        this.isDefault,
        this.subentity,
        this.menu,
    });

    final int? id;
    final DateTime? created;
    final DateTime? modified;
    final String? name;
    final double? price;
    final bool? isDefault;
    final int? subentity;
    final int? menu;

    factory Side.fromJson(Map<String, dynamic> json){ 
        return Side(
            id: json["id"],
            created: json["created"] == null ? null : DateTime.tryParse(json["created"].toString()),
            modified: json["modified"] == null ? null : DateTime.tryParse(json["modified"].toString()),
            name: json["name"],
            price: json["price"] != null ? (json["price"] as num).toDouble() : null,
            isDefault: json["is_default"],
            subentity: json["subentity"],
            menu: json["menu"],
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "created": created?.toIso8601String(),
        "modified": modified?.toIso8601String(),
        "name": name,
        "price": price,
        "is_default": isDefault,
        "subentity": subentity,
        "menu": menu,
    };

}

class LocationDetails {
    LocationDetails({
        this.subentity,
    });

    final Subentity? subentity;

    factory LocationDetails.fromJson(Map<String, dynamic> json){ 
        return LocationDetails(
            subentity: json["subentity"] == null ? null : Subentity.fromJson(json["subentity"]),
        );
    }

    Map<String, dynamic> toJson() => {
        "subentity": subentity?.toJson(),
    };

}

class Subentity {
    Subentity({
        this.id,
        this.name,
        this.branch,
        this.email,
        this.mobileNumber,
        this.currency,
        this.storeCategory,
        this.storeType,
        this.otherStoreType,
        this.description,
        this.openingDays,
        this.startTime,
        this.closingTime,
        this.setup,
        this.storeId,
        this.notificationId,
        this.carouselUploads = const [],
        this.status,
        this.image,
        this.locationDetails,
        this.rating,
        this.totalReviews,
        this.gpsCoordinates,
        this.address,
    });

    final int? id;
    final String? name;
    final String? branch;
    final dynamic email;
    final String? mobileNumber;
    final String? currency;
    final String? storeCategory;
    final String? storeType;
    final dynamic otherStoreType;
    final String? description;
    final String? openingDays;
    final String? startTime;
    final String? closingTime;
    final bool? setup;
    final String? storeId;
    final String? notificationId;
    final List<ImageElement> carouselUploads;
    final int? status;
    final PurpleImage? image;
    final LocationDetails? locationDetails;
    final double? rating;
    final int? totalReviews;
    final GpsCoordinates? gpsCoordinates;
    final Address? address;

    factory Subentity.fromJson(Map<String, dynamic> json){ 
        return Subentity(
            id: json["id"],
            name: json["name"],
            branch: json["branch"],
            email: json["email"],
            mobileNumber: json["mobile_number"],
            currency: json["currency"],
            storeCategory: json["store_category"],
            storeType: json["store_type"],
            otherStoreType: json["other_store_type"],
            description: json["description"],
            openingDays: json["opening_days"],
            startTime: json["start_time"],
            closingTime: json["closing_time"],
            setup: json["setup"],
            storeId: json["store_id"],
            notificationId: json["notification_id"],
            carouselUploads: json["carousel_uploads"] == null ? [] : List<ImageElement>.from(json["carousel_uploads"]!.map((x) => ImageElement.fromJson(x))),
            status: json["status"],
            image: json["image"] == null ? null : PurpleImage.fromJson(json["image"]),
            locationDetails: json["location_details"] == null ? null : LocationDetails.fromJson(json["location_details"]),
            rating: json["rating"] != null ? (json["rating"] as num).toDouble() : null,
            totalReviews: json["total_reviews"],
            gpsCoordinates: json["gps_coordinates"] == null ? null : GpsCoordinates.fromJson(json["gps_coordinates"]),
            address: json["address"] == null ? null : Address.fromJson(json["address"]),
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "branch": branch,
        "email": email,
        "mobile_number": mobileNumber,
        "currency": currency,
        "store_category": storeCategory,
        "store_type": storeType,
        "other_store_type": otherStoreType,
        "description": description,
        "opening_days": openingDays,
        "start_time": startTime,
        "closing_time": closingTime,
        "setup": setup,
        "store_id": storeId,
        "notification_id": notificationId,
        "carousel_uploads": carouselUploads.map((x) => x.toJson()).toList(),
        "status": status,
        "image": image?.toJson(),
        "location_details": locationDetails?.toJson(),
        "rating": rating,
        "total_reviews": totalReviews,
        "gps_coordinates": gpsCoordinates?.toJson(),
        "address": address?.toJson(),
    };

}

class Address {
    Address({
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
        this.serviceAreaDetails,
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

    final int? id;
    final String? name;
    final int? subentity;
    final String? floorNumber;
    final String? country;
    final String? postCode;
    final String? state;
    final String? city;
    final String? ward;
    final String? village;
    final int? serviceArea;
    final ServiceAreaDetails? serviceAreaDetails;
    final String? locationType;
    final GpsCoordinates? gpsCoordinates;
    final String? houseDetails;
    final String? addressDetails;
    final String? operationMode;
    final String? positionLocation;
    final double? rosXPosition;
    final double? rosYPosition;
    final double? rosZPosition;
    final double? rosOrientationX;
    final double? rosOrientationY;
    final double? rosOrientationZ;
    final double? rosOrientationW;
    final bool? isDefault;
    final bool? isActive;

    factory Address.fromJson(Map<String, dynamic> json){ 
        return Address(
            id: json["id"],
            name: json["name"],
            subentity: json["subentity"],
            floorNumber: json["floor_number"],
            country: json["country"],
            postCode: json["post_code"],
            state: json["state"],
            city: json["city"],
            ward: json["ward"],
            village: json["village"],
            serviceArea: json["service_area"],
            serviceAreaDetails: json["service_area_details"] == null ? null : ServiceAreaDetails.fromJson(json["service_area_details"]),
            locationType: json["location_type"],
            gpsCoordinates: json["gps_coordinates"] == null ? null : GpsCoordinates.fromJson(json["gps_coordinates"]),
            houseDetails: json["house_details"],
            addressDetails: json["address_details"],
            operationMode: json["operation_mode"],
            positionLocation: json["position_location"],
            rosXPosition: json["ros_x_position"] != null ? (json["ros_x_position"] as num).toDouble() : null,
            rosYPosition: json["ros_y_position"] != null ? (json["ros_y_position"] as num).toDouble() : null,
            rosZPosition: json["ros_z_position"] != null ? (json["ros_z_position"] as num).toDouble() : null,
            rosOrientationX: json["ros_orientation_x"] != null ? (json["ros_orientation_x"] as num).toDouble() : null,
            rosOrientationY: json["ros_orientation_y"] != null ? (json["ros_orientation_y"] as num).toDouble() : null,
            rosOrientationZ: json["ros_orientation_z"] != null ? (json["ros_orientation_z"] as num).toDouble() : null,
            rosOrientationW: json["ros_orientation_w"] != null ? (json["ros_orientation_w"] as num).toDouble() : null,
            isDefault: json["is_default"],
            isActive: json["is_active"],
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "subentity": subentity,
        "floor_number": floorNumber,
        "country": country,
        "post_code": postCode,
        "state": state,
        "city": city,
        "ward": ward,
        "village": village,
        "service_area": serviceArea,
        "service_area_details": serviceAreaDetails?.toJson(),
        "location_type": locationType,
        "gps_coordinates": gpsCoordinates?.toJson(),
        "house_details": houseDetails,
        "address_details": addressDetails,
        "operation_mode": operationMode,
        "position_location": positionLocation,
        "ros_x_position": rosXPosition,
        "ros_y_position": rosYPosition,
        "ros_z_position": rosZPosition,
        "ros_orientation_x": rosOrientationX,
        "ros_orientation_y": rosOrientationY,
        "ros_orientation_z": rosOrientationZ,
        "ros_orientation_w": rosOrientationW,
        "is_default": isDefault,
        "is_active": isActive,
    };

}

class GpsCoordinates {
    GpsCoordinates({
        this.type,
        this.coordinates = const [],
    });

    final String? type;
    final List<double> coordinates;

    factory GpsCoordinates.fromJson(Map<String, dynamic> json){ 
        return GpsCoordinates(
            type: json["type"],
            coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => (x as num).toDouble())),
        );
    }

    Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates.map((x) => x).toList(),
    };

}

class ServiceAreaDetails {
    ServiceAreaDetails({
        this.id,
        this.serviceCenter,
        this.gpsCoordinates,
        this.operationMode,
        this.mapped,
        this.village,
        this.ward,
        this.city,
        this.state,
        this.country,
        this.building = const [],
    });

    final int? id;
    final String? serviceCenter;
    final GpsCoordinates? gpsCoordinates;
    final String? operationMode;
    final bool? mapped;
    final String? village;
    final String? ward;
    final String? city;
    final String? state;
    final String? country;
    final List<Building> building;

    factory ServiceAreaDetails.fromJson(Map<String, dynamic> json){ 
        return ServiceAreaDetails(
            id: json["id"],
            serviceCenter: json["service_center"],
            gpsCoordinates: json["gps_coordinates"] == null ? null : GpsCoordinates.fromJson(json["gps_coordinates"]),
            operationMode: json["operation_mode"],
            mapped: json["mapped"],
            village: json["village"],
            ward: json["ward"],
            city: json["city"],
            state: json["state"],
            country: json["country"],
            building: json["building"] == null ? [] : List<Building>.from(json["building"]!.map((x) => Building.fromJson(x))),
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "service_center": serviceCenter,
        "gps_coordinates": gpsCoordinates?.toJson(),
        "operation_mode": operationMode,
        "mapped": mapped,
        "village": village,
        "ward": ward,
        "city": city,
        "state": state,
        "country": country,
        "building": building.map((x) => x.toJson()).toList(),
    };

}

class Building {
    Building({
        this.id,
        this.name,
        this.address,
        this.serviceArea,
        this.floorDetails = const [],
        this.created,
    });

    final int? id;
    final String? name;
    final String? address;
    final int? serviceArea;
    final List<FloorDetail> floorDetails;
    final DateTime? created;

    factory Building.fromJson(Map<String, dynamic> json){ 
        return Building(
            id: json["id"],
            name: json["name"],
            address: json["address"],
            serviceArea: json["service_area"],
            floorDetails: json["floor_details"] == null ? [] : List<FloorDetail>.from(json["floor_details"]!.map((x) => FloorDetail.fromJson(x))),
            created: json["created"] == null ? null : DateTime.tryParse(json["created"].toString()),
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "service_area": serviceArea,
        "floor_details": floorDetails.map((x) => x.toJson()).toList(),
        "created": created?.toIso8601String(),
    };

}

class FloorDetail {
    FloorDetail({
        this.id,
        this.created,
        this.modified,
        this.number,
        this.building,
    });

    final int? id;
    final DateTime? created;
    final DateTime? modified;
    final int? number;
    final int? building;

    factory FloorDetail.fromJson(Map<String, dynamic> json){ 
        return FloorDetail(
            id: json["id"],
            created: json["created"] == null ? null : DateTime.tryParse(json["created"].toString()),
            modified: json["modified"] == null ? null : DateTime.tryParse(json["modified"].toString()),
            number: json["number"],
            building: json["building"],
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "created": created?.toIso8601String(),
        "modified": modified?.toIso8601String(),
        "number": number,
        "building": building,
    };

}

class PurpleImage {
    PurpleImage({
        this.id,
        this.subentity,
        this.upload,
    });

    final dynamic id;
    final int? subentity;
    final String? upload;

    factory PurpleImage.fromJson(Map<String, dynamic> json){ 
        return PurpleImage(
            id: json["id"],
            subentity: json["subentity"],
            upload: json["upload"],
        );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "subentity": subentity,
        "upload": upload,
    };

}
