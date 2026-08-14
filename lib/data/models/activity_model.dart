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
