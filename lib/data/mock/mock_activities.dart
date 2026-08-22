import '../models/activity_model.dart';

final List<ActivityModel> mockActivities = [
  ActivityModel(
    id: 'activity_1',
    ownerId: 'owner_1',
    type: 'verification',
    title: 'Pending Verification',
    message:
        'Hostel "Bismilla Hostal" is currently under review by our team. This usually takes 24 hours.',
    hostelId: 'hostel_1',
    hostelName: 'Bismilla Hostal',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  ActivityModel(
    id: 'activity_2',
    ownerId: 'owner_1',
    type: 'verification',
    title: 'Pending Verification',
    message:
        'Hostel "Bismilla Hostal" is currently under review by our team. This usually takes 24 hours.',
    hostelId: 'hostel_1',
    hostelName: 'Bismilla Hostal',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  ActivityModel(
    id: 'activity_3',
    ownerId: 'owner_1',
    type: 'verification',
    title: 'Pending Verification',
    message:
        'Hostel "Bismilla Hostal" is currently under review by our team. This usually takes 24 hours.',
    hostelId: 'hostel_1',
    hostelName: 'Bismilla Hostal',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ActivityModel(
    id: 'activity_4',
    ownerId: 'owner_1',
    type: 'verification',
    title: 'Pending Verification',
    message:
        'Hostel "Bismilla Hostal" is currently under review by our team. This usually takes 24 hours.',
    hostelId: 'hostel_1',
    hostelName: 'Bismilla Hostal',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
