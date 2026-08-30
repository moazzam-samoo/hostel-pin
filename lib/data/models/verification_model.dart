import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationModel {
  final String uid;
  final String status; // 'draft', 'pending', 'approved', 'rejected', 'changesRequested'
  final Map<String, dynamic> personalInfo;
  final Map<String, dynamic> identityDocuments;
  final String? hostelId;
  final String? ownershipDocumentUrl;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  VerificationModel({
    required this.uid,
    required this.status,
    this.personalInfo = const {},
    this.identityDocuments = const {},
    this.hostelId,
    this.ownershipDocumentUrl,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  VerificationModel copyWith({
    String? uid,
    String? status,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? identityDocuments,
    String? hostelId,
    String? ownershipDocumentUrl,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) {
    return VerificationModel(
      uid: uid ?? this.uid,
      status: status ?? this.status,
      personalInfo: personalInfo ?? this.personalInfo,
      identityDocuments: identityDocuments ?? this.identityDocuments,
      hostelId: hostelId ?? this.hostelId,
      ownershipDocumentUrl: ownershipDocumentUrl ?? this.ownershipDocumentUrl,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  factory VerificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('VerificationModel: Document data is null');
    }

    return VerificationModel(
      uid: data['uid'] as String? ?? '',
      status: data['status'] as String? ?? 'draft',
      personalInfo: data['personalInfo'] as Map<String, dynamic>? ?? {},
      identityDocuments: data['identityDocuments'] as Map<String, dynamic>? ?? {},
      hostelId: data['hostelId'] as String?,
      ownershipDocumentUrl: data['ownershipDocumentUrl'] as String?,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'status': status,
      'personalInfo': personalInfo,
      'identityDocuments': identityDocuments,
      if (hostelId != null) 'hostelId': hostelId,
      if (ownershipDocumentUrl != null) 'ownershipDocumentUrl': ownershipDocumentUrl,
      if (submittedAt != null) 'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      if (reviewedAt != null) 'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is VerificationModel &&
      other.uid == uid &&
      other.status == status &&
      other.hostelId == hostelId &&
      other.ownershipDocumentUrl == ownershipDocumentUrl &&
      other.submittedAt == submittedAt &&
      other.reviewedAt == reviewedAt &&
      other.reviewedBy == reviewedBy &&
      other.rejectionReason == rejectionReason;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      status.hashCode ^
      hostelId.hashCode ^
      ownershipDocumentUrl.hashCode ^
      submittedAt.hashCode ^
      reviewedAt.hashCode ^
      reviewedBy.hashCode ^
      rejectionReason.hashCode;
  }
}
