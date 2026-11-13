import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ReportModel>> streamOpenReports() {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<ReportModel>> streamAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
    });
  }

  /// A user reports a listing (Play's UGC policy requires an in-app way to
  /// flag objectionable content). The doc id is `{hostelId}_{reporterUid}` so
  /// one user can report one listing once; a second attempt is an update,
  /// which the rules reserve for admins, and surfaces as permission-denied
  /// (callers treat that as "already reported").
  Future<void> createReport(ReportModel report) async {
    await _firestore
        .collection('reports')
        .doc('${report.hostelId}_${report.reportedBy}')
        .set(report.toMap());
  }

  Future<void> resolveReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': 'resolved',
    });
  }
}
