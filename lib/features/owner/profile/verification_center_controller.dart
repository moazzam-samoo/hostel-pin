import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../core/enums/verification_status.dart';

class VerificationCenterController extends GetxController {
  final MockDataService _dataService = Get.find<MockDataService>();

  UserModel? get user => _dataService.currentUser.value;
  VerificationStatus get status =>
      user?.verificationStatus ?? VerificationStatus.unverified;
}
