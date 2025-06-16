import 'package:json_annotation/json_annotation.dart';
import 'address.dart';
import 'fainzy_image.dart';

part 'fainzy_store.g.dart';

@JsonSerializable()
class FainzyStore {
  final int? id;
  final String? name;
  @JsonKey(name: 'mobile_number')
  final String? mobileNumber;
  @JsonKey(name: 'gps_coordinates')
  final Map<String, dynamic>? gpsCoordinates;
  final double? rating;
  @JsonKey(name: 'is_open')
  final bool? isOpen;
  final Address? address;
  @JsonKey(name: 'notification_id')
  final String? notificationId;
  final FainzyImage? image;

  const FainzyStore({
    this.id,
    this.name,
    this.mobileNumber,
    this.gpsCoordinates,
    this.rating,
    this.isOpen,
    this.address,
    this.notificationId,
    this.image,
  });

  FainzyStore copyWith({
    int? id,
    String? name,
    String? mobileNumber,
    Map<String, dynamic>? gpsCoordinates,
    double? rating,
    bool? isOpen,
    Address? address,
    String? notificationId,
    FainzyImage? image,
  }) {
    return FainzyStore(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      rating: rating ?? this.rating,
      isOpen: isOpen ?? this.isOpen,
      address: address ?? this.address,
      notificationId: notificationId ?? this.notificationId,
      image: image ?? this.image,
    );
  }

  factory FainzyStore.fromJson(Map<String, dynamic> json) =>
      _$FainzyStoreFromJson(json);

  Map<String, dynamic> toJson() => _$FainzyStoreToJson(this);

  @override
  String toString() {
    return 'FainzyStore(id: $id, name: $name, mobileNumber: $mobileNumber, gpsCoordinates: $gpsCoordinates, rating: $rating, isOpen: $isOpen, address: $address, notificationId: $notificationId, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FainzyStore &&
        other.id == id &&
        other.name == name &&
        other.mobileNumber == mobileNumber &&
        other.gpsCoordinates == gpsCoordinates &&
        other.rating == rating &&
        other.isOpen == isOpen &&
        other.address == address &&
        other.notificationId == notificationId &&
        other.image == image;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        mobileNumber.hashCode ^
        gpsCoordinates.hashCode ^
        rating.hashCode ^
        isOpen.hashCode ^
        address.hashCode ^
        notificationId.hashCode ^
        image.hashCode;
  }
}
