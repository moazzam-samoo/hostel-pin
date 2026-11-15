import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_users_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/user_model.dart';
import '../../../../shared/widgets/feedback/confirm_dialog.dart';

class AdminUsersView extends GetView<AdminUsersController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(AppStrings.adminManageUsersTitle,
              style: AppTextStyles.screenTitle),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.users.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (controller.users.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.adminNoUsersFound,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.isDesktop(context) ? 24.0 : 12.0),
              child: LayoutBuilder(
                  builder: (context, box) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        // A horizontal scroll view gives its child unbounded width, which
                        // PaginatedDataTable cannot lay out; give it a definite width
                        // (the available width, but never narrower than 720).
                        child: SizedBox(
                          width: box.maxWidth < 720 ? 720 : box.maxWidth,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dataTableTheme: DataTableThemeData(
                                headingRowColor: WidgetStateProperty.all(
                                    AppColors.background),
                                dataRowColor:
                                    WidgetStateProperty.all(Colors.white),
                              ),
                            ),
                            child: PaginatedDataTable(
                              header: Text(AppStrings.adminStudentsDirectory,
                                  style: AppTextStyles.cardTitle),
                              rowsPerPage: controller.users.length > 10
                                  ? 10
                                  : (controller.users.isNotEmpty
                                      ? controller.users.length
                                      : 1),
                              columns: [
                                DataColumn(
                                    label: Text(AppStrings.adminColName,
                                        style: AppTextStyles.labelMicro)),
                                DataColumn(
                                    label: Text(AppStrings.adminColEmail,
                                        style: AppTextStyles.labelMicro)),
                                DataColumn(
                                    label: Text(AppStrings.adminColJoined,
                                        style: AppTextStyles.labelMicro)),
                                DataColumn(
                                    label: Text(AppStrings.adminColStatus,
                                        style: AppTextStyles.labelMicro)),
                                DataColumn(
                                    label: Text(AppStrings.adminColActions,
                                        style: AppTextStyles.labelMicro)),
                              ],
                              source:
                                  _UserDataString(controller.users, controller),
                            ),
                          ),
                        ),
                      )),
            );
          }),
        ),
      ],
    );
  }
}

class _UserDataString extends DataTableSource {
  final List<UserModel> users;
  final AdminUsersController controller;

  _UserDataString(this.users, this.controller);

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    return DataRow(cells: [
      DataCell(Text(user.displayName, style: AppTextStyles.body)),
      DataCell(Text(user.email, style: AppTextStyles.body)),
      DataCell(Text(
        user.createdAt?.toString().split(' ')[0] ?? AppStrings.notAvailableDash,
        style: AppTextStyles.body,
      )),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user.status == 'blocked'
                ? AppColors.error.withAlpha(25)
                : AppColors.success.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.status.toUpperCase(),
            style: AppTextStyles.labelMicro.copyWith(
              color: user.status == 'blocked'
                  ? AppColors.error
                  : AppColors.success,
            ),
          ),
        ),
      ),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(user.status == 'blocked' ? Icons.lock_open : Icons.block,
                color: AppColors.textSecondary),
            onPressed: () => controller.toggleUserStatus(user),
            tooltip: user.status == 'blocked'
                ? AppStrings.adminUnblockUserTooltip
                : AppStrings.adminBlockUserTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteConfirm(user),
            tooltip: AppStrings.adminDeleteUserTooltip,
          ),
        ],
      )),
    ]);
  }

  void _showDeleteConfirm(UserModel user) {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.adminConfirmDeleteTitle,
        message: AppStrings.adminConfirmDeleteMessage(user.displayName),
        confirmText: AppStrings.adminDeleteButton,
        cancelText: AppStrings.adminCancelButton,
        isDestructive: true,
        onCancel: () => Get.back(),
        onConfirm: () {
          Get.back();
          controller.deleteUser(user);
        },
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
