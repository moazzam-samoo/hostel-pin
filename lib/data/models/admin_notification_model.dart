import 'package:cloud_firestore/cloud_firestore.dart';

enum AdminNotificationType { verification, report, system }

class AdminNotificationModel {
  final String id;
  final String title;
  final String message;
  final AdminNotificationType type;
  final bool isRead;
  final DateTime createdAt;

  AdminNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminNotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AdminNotificationModel(
      id: id,
      title: data['title'] as String? ?? 'No Title',
      message: data['message'] as String? ?? 'No Message',
      type: AdminNotificationType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => AdminNotificationType.system,
      ),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
