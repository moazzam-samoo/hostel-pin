import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/amenity.dart';
import '../../core/enums/availability_status.dart';
import '../../core/enums/listing_status.dart';
import 'upload_result_model.dart';

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
  final int totalRooms; // NEW in Phase 7
  final int totalBeds; // NEW in Phase 8
  final List<UploadResultModel> photos; // Updated in Phase 7
  final Set<Amenity> amenities;
  final AvailabilityStatus availability;
  final String contactPhone;
  final String contactWhatsapp;
  final double rating;
  final int reviewCount;
  final int viewCount;
  final bool isFeatured;
  final ListingStatus status;
  final GeoPoint? location; // NEW in Phase 7
  final String? geohash; // NEW in Phase 7
  // Cloudinary public_id (NOT a URL, despite the name mirroring
  // VerificationModel.ownershipDocumentUrl's same misleading naming) for the
  // property-ownership document AddListingController now requires for every
  // brand-new hostel added via the normal Add Listing screen (an already-
  // verified owner's 2nd, 3rd, ... listing) — see
  // AddListingController._requiresOwnershipDocument. It's a `type:
  // authenticated` signed asset uploaded via
  // CloudinaryService.uploadSignedDocument, same scheme as the wizard's CNIC/
  // selfie/ownership documents.
  //
  // Null for two legitimate reasons, not just "not uploaded yet": (1) a
  // hostel created by the owner-verification wizard's step 3
  // (VerificationController._completeHostelInfoStep) — that flow's ownership
  // proof lives on the separate verifications/{uid} doc instead, never on
  // this one; (2) any listing created before this field existed.
  final String? ownershipDocumentId;

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
    this.totalRooms = 1,
    this.totalBeds = 1,
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
    this.location,
    this.geohash,
    this.ownershipDocumentId,
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
    int? totalRooms,
    int? totalBeds,
    List<UploadResultModel>? photos,
    Set<Amenity>? amenities,
    AvailabilityStatus? availability,
    String? contactPhone,
    String? contactWhatsapp,
    double? rating,
    int? reviewCount,
    int? viewCount,
    bool? isFeatured,
    ListingStatus? status,
    GeoPoint? location,
    String? geohash,
    String? ownershipDocumentId,
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
      totalRooms: totalRooms ?? this.totalRooms,
      totalBeds: totalBeds ?? this.totalBeds,
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
      location: location ?? this.location,
      geohash: geohash ?? this.geohash,
      ownershipDocumentId: ownershipDocumentId ?? this.ownershipDocumentId,
    );
  }

  factory HostelModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;

    // Two on-disk shapes exist for a hostel's position:
    //   legacy — `location` is a bare GeoPoint, `geohash` a sibling field
    //   current — `location` is a {geopoint, geohash} map, which is
    //             GeoFirePoint.data's shape and the only thing
    //             geoflutterfire_plus's orderBy('location.geohash') can
    //             query (see toFirestore below).
    // Documents written before that change still carry the legacy shape,
    // so read both rather than blowing up on a cast.
    final rawLocation = data['location'];
    final GeoPoint? parsedLocation;
    final String? parsedGeohash;
    if (rawLocation is Map) {
      parsedLocation = rawLocation['geopoint'] as GeoPoint?;
      parsedGeohash = rawLocation['geohash'] as String?;
    } else {
      parsedLocation = rawLocation as GeoPoint?;
      parsedGeohash = data['geohash'] as String?;
    }

    final rawAddress = data['fullAddress'] as String? ?? '';
    final rawCity = data['city'] as String? ?? '';
    String resolvedCity = rawCity;
    if (resolvedCity.isEmpty || resolvedCity.toLowerCase() == 'unknown city') {
      final parts = rawAddress.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      resolvedCity = parts.isNotEmpty ? parts.last : 'Hyderabad';
    }

    return HostelModel(
      id: snapshot.id,
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      name: data['name'] as String? ?? '',
      fullAddress: rawAddress,
      city: resolvedCity,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      pricePerMonth: data['pricePerMonth'] as num? ?? 0,
      totalRooms: data['totalRooms'] as int? ?? 1,
      totalBeds: data['totalBeds'] as int? ?? 1,
      photos: (data['photos'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return UploadResultModel.fromMap(e);
                } else if (e is Map) {
                  return UploadResultModel.fromMap(Map<String, dynamic>.from(e));
                } else if (e is String) {
                  return UploadResultModel(url: e, publicId: '');
                }
                return const UploadResultModel(url: '', publicId: '');
              })
              .where((p) => p.url.isNotEmpty)
              .toList() ??
          [],
      amenities: (data['amenities'] as List<dynamic>?)
              ?.map((e) => Amenity.values.firstWhere(
                    (a) => a.name == e,
                    orElse: () => Amenity.wifi,
                  ))
              .toSet() ??
          {},
      availability: AvailabilityStatus.values.firstWhere(
        (e) => e.name == data['availability'],
        orElse: () => AvailabilityStatus.available,
      ),
      contactPhone: data['contactPhone'] as String? ?? '',
      contactWhatsapp: data['contactWhatsapp'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      viewCount: data['viewCount'] as int? ?? 0,
      isFeatured: data['isFeatured'] as bool? ?? false,
      status: ListingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ListingStatus.draft,
      ),
      location: parsedLocation,
      geohash: parsedGeohash,
      ownershipDocumentId: data['ownershipDocumentId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'name': name,
      'fullAddress': fullAddress,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'pricePerMonth': pricePerMonth,
      'totalRooms': totalRooms,
      'totalBeds': totalBeds,
      'photos': photos.map((p) => p.toMap()).toList(),
      'amenities': amenities.map((a) => a.name).toList(),
      'availability': availability.name,
      'contactPhone': contactPhone,
      'contactWhatsapp': contactWhatsapp,
      'rating': rating,
      'reviewCount': reviewCount,
      'viewCount': viewCount,
      'isFeatured': isFeatured,
      'status': status.name,
      // geoflutterfire_plus's queries (HostelRepository.streamNearbyHostels)
      // do `orderBy('location.geohash')` — it expects ONE field ("location")
      // holding a {geopoint, geohash} map (GeoFirePoint.data's exact shape),
      // not two flat top-level fields. Writing them flat meant the geo query
      // could never match any document — new listings never appeared on the
      // Map tab, regardless of where they were actually located.
      if (location != null && geohash != null)
        'location': {'geopoint': location, 'geohash': geohash},
      if (ownershipDocumentId != null) 'ownershipDocumentId': ownershipDocumentId,
      // Stamped server-side on create (FIX-7.5/FIX-7.11).
      // `HostelRepository.update` strips this key before merging so an edit
      // never re-dates the listing. Documents created before this field
      // existed have no `createdAt` at all and must be backfilled before any
      // query orders by it — Firestore drops documents missing the ordered
      // field, which would silently empty the feed.
      'createdAt': FieldValue.serverTimestamp(),
    };
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
        other.totalRooms == totalRooms &&
        other.totalBeds == totalBeds &&
        listEquals(other.photos, photos) &&
        setEquals(other.amenities, amenities) &&
        other.availability == availability &&
        other.contactPhone == contactPhone &&
        other.contactWhatsapp == contactWhatsapp &&
        other.rating == rating &&
        other.reviewCount == reviewCount &&
        other.viewCount == viewCount &&
        other.isFeatured == isFeatured &&
        other.status == status &&
        other.location == location &&
        other.geohash == geohash &&
        other.ownershipDocumentId == ownershipDocumentId;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      ownerId,
      ownerName,
      name,
      fullAddress,
      city,
      latitude,
      longitude,
      description,
      pricePerMonth,
      totalRooms,
      totalBeds,
      Object.hashAll(photos),
      Object.hashAll(amenities),
      availability,
      contactPhone,
      contactWhatsapp,
      rating,
      reviewCount,
      viewCount,
      isFeatured,
      status,
      location,
      geohash,
      ownershipDocumentId,
    ]);
  }
}
