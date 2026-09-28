import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_owners_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/user_model.dart';
import '../../../../shared/widgets/feedback/confirm_dialog.dart';

class AdminOwnersView extends GetView<AdminOwnersController> {
  const AdminOwnersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(AppStrings.adminManageOwnersTitle, style: AppTextStyles.screenTitle),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.owners.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (controller.owners.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.adminNoOwnersFound,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.isDesktop(context) ? 24.0 : 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 720),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dataTableTheme: DataTableThemeData(
                        headingRowColor: WidgetStateProperty.all(AppColors.background),
                        dataRowColor: WidgetStateProperty.all(Colors.white),
                      ),
                    ),
                    child: PaginatedDataTable(
                      header: Text(AppStrings.adminOwnersDirectory, style: AppTextStyles.cardTitle),
                      rowsPerPage: controller.owners.length > 10 ? 10 : (controller.owners.isNotEmpty ? controller.owners.length : 1),
                      columns: [
                        DataColumn(label: Text(AppStrings.adminColName, style: AppTextStyles.labelMicro)),
                        DataColumn(label: Text(AppStrings.adminColEmail, style: AppTextStyles.labelMicro)),
                        DataColumn(label: Text(AppStrings.adminColListings, style: AppTextStyles.labelMicro)),
                        DataColumn(label: Text(AppStrings.adminColVerification, style: AppTextStyles.labelMicro)),
                        DataColumn(label: Text(AppStrings.adminColStatus, style: AppTextStyles.labelMicro)),
                        DataColumn(label: Text(AppStrings.adminColActions, style: AppTextStyles.labelMicro)),
                      ],
                      source: _OwnerDataString(controller.owners, controller),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _OwnerDataString extends DataTableSource {
  final List<UserModel> users;
  final AdminOwnersController controller;

  _OwnerDataString(this.users, this.controller);

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    return DataRow(cells: [
      DataCell(Text(user.displayName, style: AppTextStyles.body)),
      DataCell(Text(user.email, style: AppTextStyles.body)),
      DataCell(Obx(() => Text(
            controller.ownerListingCounts[user.uid]?.toString() ?? AppStrings.adminLoadingLabel,
            style: AppTextStyles.body,
          ))),
      DataCell(Text(user.verificationStatus.name.capitalizeFirst ?? '', style: AppTextStyles.body)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user.status == 'blocked' ? AppColors.error.withAlpha(25) : AppColors.success.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.status.toUpperCase(),
            style: AppTextStyles.labelMicro.copyWith(
              color: user.status == 'blocked' ? AppColors.error : AppColors.success,
            ),
          ),
        ),
      ),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(user.status == 'blocked' ? Icons.lock_open : Icons.block, color: AppColors.textSecondary),
            onPressed: () => controller.toggleUserStatus(user),
            tooltip: user.status == 'blocked' ? AppStrings.adminUnblockOwnerTooltip : AppStrings.adminBlockOwnerTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteConfirm(user),
            tooltip: AppStrings.adminDeleteOwnerTooltip,
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
          controller.deleteOwner(user);
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
