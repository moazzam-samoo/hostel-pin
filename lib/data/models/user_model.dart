import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/verification_status.dart';

// Phase 6 / Block B.1 decision: this is the same `UserModel` that already
// backed `MockDataService`/`ProfileController`/`OwnerProfileController`
// before Firebase Auth landed — extended in place with the Firestore-facing
// shape (`fromFirestore`/`toFirestore`, `phone`, `createdAt`/`updatedAt`)
// rather than introducing a second, parallel `app_user_model.dart` type.
// Same precedent as `HostelModel.status` being added in place during
// Phase 4 instead of a separate `ListingModel`.

class UserPrefs {
  final bool darkMode;
  final bool notifications;
  final String language;

  const UserPrefs({
    this.darkMode = false,
    this.notifications = true,
    this.language = 'English(US)',
  });

  UserPrefs copyWith({
    bool? darkMode,
    bool? notifications,
    String? language,
  }) {
    return UserPrefs(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      language: language ?? this.language,
    );
  }

  factory UserPrefs.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserPrefs();
    return UserPrefs(
      darkMode: map['darkMode'] as bool? ?? false,
      notifications: map['notifications'] as bool? ?? true,
      language: map['language'] as String? ?? 'English(US)',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'notifications': notifications,
      'language': language,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPrefs &&
        other.darkMode == darkMode &&
        other.notifications == notifications &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(darkMode, notifications, language);
}

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? phone;
  final UserRole role;
  final List<String> savedHostelIds;
  final UserPrefs prefs;
  final VerificationStatus verificationStatus;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.phone,
    required this.role,
    this.savedHostelIds = const [],
    this.prefs = const UserPrefs(),
    this.verificationStatus = VerificationStatus.unverified,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    String? phone,
    UserRole? role,
    List<String>? savedHostelIds,
    UserPrefs? prefs,
    VerificationStatus? verificationStatus,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      savedHostelIds: savedHostelIds ?? this.savedHostelIds,
      prefs: prefs ?? this.prefs,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == (data['role'] as String?),
        orElse: () => UserRole.student,
      ),
      savedHostelIds: List<String>.from(data['savedHostelIds'] ?? []),
      prefs: UserPrefs.fromMap(data['prefs'] as Map<String, dynamic>?),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == (data['verificationStatus'] as String?),
        orElse: () => VerificationStatus.unverified,
      ),
      status: data['status'] as String? ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// The document's own field values — deliberately excludes `createdAt`/
  /// `updatedAt`. `UserRepository` stamps those with `FieldValue.serverTimestamp()`
  /// at write time (create sets both; update touches only `updatedAt`), so
  /// this model doesn't need to carry a client clock value for them.
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'role': role.name,
      'savedHostelIds': savedHostelIds,
      'prefs': prefs.toMap(),
      'verificationStatus': verificationStatus.name,
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.displayName == displayName &&
        other.email == email &&
        other.photoUrl == photoUrl &&
        other.phone == phone &&
        other.role == role &&
        listEquals(other.savedHostelIds, savedHostelIds) &&
        other.prefs == prefs &&
        other.verificationStatus == verificationStatus &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
        uid,
        displayName,
        email,
        photoUrl,
        phone,
        role,
        Object.hashAll(savedHostelIds),
        prefs,
        verificationStatus,
        status,
        createdAt,
        updatedAt);
  }
}
