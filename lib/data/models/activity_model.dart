import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String ownerId;
  final String type;
  final String title;
  final String message;
  final String? hostelId;
  final String? hostelName;
  final String? thumbnailUrl;
  final DateTime createdAt;

  const ActivityModel({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.message,
    this.hostelId,
    this.hostelName,
    this.thumbnailUrl,
    required this.createdAt,
  });

  ActivityModel copyWith({
    String? id,
    String? ownerId,
    String? type,
    String? title,
    String? message,
    String? hostelId,
    String? hostelName,
    String? thumbnailUrl,
    DateTime? createdAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      hostelId: hostelId ?? this.hostelId,
      hostelName: hostelName ?? this.hostelName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ActivityModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ActivityModel(
      id: snapshot.id,
      ownerId: data['ownerId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      hostelId: data['hostelId'] as String?,
      hostelName: data['hostelName'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'type': type,
      'title': title,
      'message': message,
      if (hostelId != null) 'hostelId': hostelId,
      if (hostelName != null) 'hostelName': hostelName,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ActivityModel &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.type == type &&
        other.title == title &&
        other.message == message &&
        other.hostelId == hostelId &&
        other.hostelName == hostelName &&
        other.thumbnailUrl == thumbnailUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      ownerId,
      type,
      title,
      message,
      hostelId,
      hostelName,
      thumbnailUrl,
      createdAt,
    );
  }
}
