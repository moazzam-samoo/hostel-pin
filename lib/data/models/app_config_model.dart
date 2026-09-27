import 'package:cloud_firestore/cloud_firestore.dart';

/// Phase 9 Block H.2 — the admin Settings screen's feature-flag doc,
/// `config/appSettings`. Exactly the 4 booleans Appendix C (IMPLEMENTATION_PLAN
/// Phase 8/9 addendum) names; nothing more. `firestore.rules`' `config/{docId}`
/// rule already permits `allow read: if true; allow write: if isAdmin();`.
///
/// These toggles only mean anything once the mobile app also reads this doc
/// and branches on it (Block H.4) — that mobile-side wiring is separate,
/// new work and is out of this model's scope.
class AppConfigModel {
  final bool allowNewSignups;
  final bool whatsappIntegration;
  final bool autoApproveOwners;
  final bool maintenanceMode;

  const AppConfigModel({
    this.allowNewSignups = true,
    this.whatsappIntegration = true,
    this.autoApproveOwners = false,
    this.maintenanceMode = false,
  });

  AppConfigModel copyWith({
    bool? allowNewSignups,
    bool? whatsappIntegration,
    bool? autoApproveOwners,
    bool? maintenanceMode,
  }) {
    return AppConfigModel(
      allowNewSignups: allowNewSignups ?? this.allowNewSignups,
      whatsappIntegration: whatsappIntegration ?? this.whatsappIntegration,
      autoApproveOwners: autoApproveOwners ?? this.autoApproveOwners,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    );
  }

  factory AppConfigModel.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const AppConfigModel();
    return AppConfigModel(
      allowNewSignups: data['allowNewSignups'] as bool? ?? true,
      whatsappIntegration: data['whatsappIntegration'] as bool? ?? true,
      autoApproveOwners: data['autoApproveOwners'] as bool? ?? false,
      maintenanceMode: data['maintenanceMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'allowNewSignups': allowNewSignups,
      'whatsappIntegration': whatsappIntegration,
      'autoApproveOwners': autoApproveOwners,
      'maintenanceMode': maintenanceMode,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
