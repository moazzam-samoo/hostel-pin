import 'package:flutter/foundation.dart';
import '../../core/enums/amenity.dart';
import '../../core/enums/availability_status.dart';
import '../../core/enums/listing_status.dart';

class HostelModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String name;
  final String fullAddress;
  final String city;
  final double latitude;
  final double longitude;
  final String description;
  final num pricePerMonth;
  final List<String> photos;
  final Set<Amenity> amenities;
  final AvailabilityStatus availability;
  final String contactPhone;
  final String contactWhatsapp;
  final double rating;
  final int reviewCount;
  final int viewCount;
  final bool isFeatured;
  final ListingStatus status;

  const HostelModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.name,
    required this.fullAddress,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.pricePerMonth,
    required this.photos,
    required this.amenities,
    required this.availability,
    required this.contactPhone,
    required this.contactWhatsapp,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.viewCount = 0,
    this.isFeatured = false,
    required this.status,
  });

  HostelModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? name,
    String? fullAddress,
    String? city,
    double? latitude,
    double? longitude,
    String? description,
    num? pricePerMonth,
    List<String>? photos,
    Set<Amenity>? amenities,
    AvailabilityStatus? availability,
    String? contactPhone,
    String? contactWhatsapp,
    double? rating,
    int? reviewCount,
    int? viewCount,
    bool? isFeatured,
    ListingStatus? status,
  }) {
    return HostelModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      name: name ?? this.name,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      photos: photos ?? this.photos,
      amenities: amenities ?? this.amenities,
      availability: availability ?? this.availability,
      contactPhone: contactPhone ?? this.contactPhone,
      contactWhatsapp: contactWhatsapp ?? this.contactWhatsapp,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      viewCount: viewCount ?? this.viewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is HostelModel &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.ownerName == ownerName &&
      other.name == name &&
      other.fullAddress == fullAddress &&
      other.city == city &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.description == description &&
      other.pricePerMonth == pricePerMonth &&
      listEquals(other.photos, photos) &&
      setEquals(other.amenities, amenities) &&
      other.availability == availability &&
      other.contactPhone == contactPhone &&
      other.contactWhatsapp == contactWhatsapp &&
      other.rating == rating &&
      other.reviewCount == reviewCount &&
      other.viewCount == viewCount &&
      other.isFeatured == isFeatured &&
      other.status == status;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id, ownerId, ownerName, name, fullAddress, city,
      latitude, longitude, description, pricePerMonth,
      Object.hashAll(photos), Object.hashAll(amenities),
      availability, contactPhone, contactWhatsapp,
      rating, reviewCount, viewCount, isFeatured, status,
    ]);
  }
}
