import 'package:get/get.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';

class AdminUsersController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentLimit = 10.obs;

  @override
  void onInit() {
    super.onInit();
    _subscribeToUsers();
  }

  void _subscribeToUsers() {
    isLoading.value = true;
    _userRepository.streamAllUsers(limit: currentLimit.value, roleFilter: UserRole.student).listen((data) {
      users.assignAll(data);
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      AppSnackbar.showGlobal(message: AppStrings.adminGenericLoadError, type: SnackbarType.error);
    });
  }

  void loadMore() {
    currentLimit.value += 10;
    _subscribeToUsers();
  }

  Future<void> toggleUserStatus(UserModel user) async {
    final newStatus = user.status == 'blocked' ? 'active' : 'blocked';
    try {
      await _userRepository.updateStatus(user.uid, newStatus);
      AppSnackbar.showGlobal(
        message: AppStrings.adminUserStatusUpdated(user.displayName, newStatus),
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminGenericUpdateError, type: SnackbarType.error);
    }
  }

  Future<void> deleteUser(UserModel user) async {
    try {
      await _userRepository.deleteUserDoc(user.uid);
      AppSnackbar.showGlobal(
        message: AppStrings.adminUserDeleted(user.displayName),
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminGenericDeleteError, type: SnackbarType.error);
    }
  }
}
