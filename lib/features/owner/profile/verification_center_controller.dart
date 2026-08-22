import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/services/session_service.dart';
import '../../../../core/enums/verification_status.dart';

class VerificationCenterController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();

  UserModel? get user => _sessionService.currentUser.value;
  VerificationStatus get status =>
      user?.verificationStatus ?? VerificationStatus.unverified;
}
