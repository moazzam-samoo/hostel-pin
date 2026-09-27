import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_config_model.dart';

/// Phase 9 Block H.2 — a minimal repository for the single `config/appSettings`
/// doc, keeping the repository-owns-writes boundary AdminSettingsController
/// would otherwise skip (this doc has no dedicated repository named in
/// IMPLEMENTATION_PLAN §9.B's file list at all — a small gap in the plan's
/// own file list, mirroring Block F.4's Notification Center finding).
class AppConfigRepository {
  final FirebaseFirestore _firestore;

  AppConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('config').doc('appSettings');

  Stream<AppConfigModel> streamConfig() {
    return _doc.snapshots().map((snap) => AppConfigModel.fromFirestore(snap.data()));
  }

  Future<AppConfigModel> getConfig() async {
    final snap = await _doc.get();
    return AppConfigModel.fromFirestore(snap.data());
  }

  Future<void> updateConfig(AppConfigModel config) async {
    await _doc.set(config.toFirestore(), SetOptions(merge: true));
  }
}
