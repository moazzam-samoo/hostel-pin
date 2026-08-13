import 'package:flutter/foundation.dart';
import '../../core/enums/user_role.dart';

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
  final UserRole role;
  final List<String> savedHostelIds;
  final UserPrefs prefs;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.role,
    this.savedHostelIds = const [],
    this.prefs = const UserPrefs(),
  });

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    UserRole? role,
    List<String>? savedHostelIds,
    UserPrefs? prefs,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      savedHostelIds: savedHostelIds ?? this.savedHostelIds,
      prefs: prefs ?? this.prefs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.uid == uid &&
      other.displayName == displayName &&
      other.email == email &&
      other.photoUrl == photoUrl &&
      other.role == role &&
      listEquals(other.savedHostelIds, savedHostelIds) &&
      other.prefs == prefs;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid, displayName, email, photoUrl, role, Object.hashAll(savedHostelIds), prefs
    );
  }
}
