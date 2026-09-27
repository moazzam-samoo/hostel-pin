import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> resolveReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': 'resolved',
    });
  }
}
