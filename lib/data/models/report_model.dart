import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String hostelId;
  final String reportedBy;
  final String reason;
  final String details;
  final String status; // "open" | "resolved"
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.hostelId,
    required this.reportedBy,
    required this.reason,
    required this.details,
    required this.status,
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      hostelId: data['hostelId'] ?? '',
      reportedBy: data['reportedBy'] ?? '',
      reason: data['reason'] ?? '',
      details: data['details'] ?? '',
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hostelId': hostelId,
      'reportedBy': reportedBy,
      'reason': reason,
      'details': details,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ReportModel copyWith({
    String? id,
    String? hostelId,
    String? reportedBy,
    String? reason,
    String? details,
    String? status,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      hostelId: hostelId ?? this.hostelId,
      reportedBy: reportedBy ?? this.reportedBy,
      reason: reason ?? this.reason,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
