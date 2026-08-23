import 'package:cloud_firestore/cloud_firestore.dart';

/// `users/{uid}/saved/{hostelId}` — matches Appendix C's denormalized shape
/// exactly (`hostelId, savedAt, hostelSummary: {name, ownerName, coverPhoto,
/// price, rating, city}`), flattened onto this model rather than nested,
/// per TASK-Phase-7.md Block B.3/C.2: the summary is written at save time
/// (`SavedRepository.toggleSave`) so the Saved tab can render entirely from
/// this collection's own stream — no second read against `hostels`, and no
/// need to load the full published catalog just to show a handful of
/// saved cards.
class SavedModel {
  final String id; // == hostelId; the saved doc's own ID.
  final String hostelId;
  final DateTime savedAt;
  final String name;
  final String ownerName;
  final String coverPhoto;
  final num price;
  final double rating;
  final String city;

  const SavedModel({
    required this.id,
    required this.hostelId,
    required this.savedAt,
    required this.name,
    required this.ownerName,
    required this.coverPhoto,
    required this.price,
    required this.rating,
    required this.city,
  });

  factory SavedModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return SavedModel(
      id: snapshot.id,
      hostelId: data['hostelId'] as String? ?? snapshot.id,
      savedAt: (data['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: data['name'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      coverPhoto: data['coverPhoto'] as String? ?? '',
      price: data['price'] as num? ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      city: data['city'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hostelId': hostelId,
      'savedAt': Timestamp.fromDate(savedAt),
      'name': name,
      'ownerName': ownerName,
      'coverPhoto': coverPhoto,
      'price': price,
      'rating': rating,
      'city': city,
    };
  }

  SavedModel copyWith({
    String? id,
    String? hostelId,
    DateTime? savedAt,
    String? name,
    String? ownerName,
    String? coverPhoto,
    num? price,
    double? rating,
    String? city,
  }) {
    return SavedModel(
      id: id ?? this.id,
      hostelId: hostelId ?? this.hostelId,
      savedAt: savedAt ?? this.savedAt,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      city: city ?? this.city,
    );
  }
}
