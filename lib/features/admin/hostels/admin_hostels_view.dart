import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_hostels_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/listing_status.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/confirm_dialog.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class AdminHostelsView extends GetView<AdminHostelsController> {
  const AdminHostelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(AppStrings.adminManageHostelsTitle,
              style: AppTextStyles.screenTitle),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.hostels.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (controller.hostels.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.adminNoHostelsFound,
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
                                    WidgetStateProperty.resolveWith<Color?>(
                                        (Set<WidgetState> states) =>
                                            Colors.white),
                              ),
                            ),
                            child: PaginatedDataTable(
                              header: Text(AppStrings.adminHostelsDirectory,
                                  style: AppTextStyles.cardTitle),
                              rowsPerPage: controller.hostels.length > 10
                                  ? 10
                                  : (controller.hostels.isNotEmpty
                                      ? controller.hostels.length
                                      : 1),
                              columns: [
                                DataColumn(
                                    label: Text(AppStrings.adminColName,
                                        style: AppTextStyles.labelMicro)),
                                DataColumn(
                                    label: Text(AppStrings.adminColCity,
                                        style: AppTextStyles.labelMicro)),
                                DataColumn(
                                    label: Text(AppStrings.adminColStatus,
                                        style: AppTextStyles.labelMicro)),
                                DataColumn(
                                    label: Text(AppStrings.adminColPrice,
                                        style: AppTextStyles.labelMicro)),
                                DataColumn(
                                    label: Text(AppStrings.adminColActions,
                                        style: AppTextStyles.labelMicro)),
                              ],
                              source: _HostelDataString(
                                  controller.hostels, controller),
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

class _HostelDataString extends DataTableSource {
  final List<HostelModel> hostels;
  final AdminHostelsController controller;

  _HostelDataString(this.hostels, this.controller);

  @override
  DataRow? getRow(int index) {
    if (index >= hostels.length) return null;
    final hostel = hostels[index];

    Color statusColor;
    switch (hostel.status) {
      case ListingStatus.published:
        statusColor = AppColors.success;
        break;
      case ListingStatus.pending:
        statusColor = AppColors.secondary;
        break;
      case ListingStatus.rejected:
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return DataRow(cells: [
      DataCell(Text(hostel.name, style: AppTextStyles.body)),
      DataCell(Text(hostel.city, style: AppTextStyles.body)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hostel.status.name.toUpperCase(),
            style: AppTextStyles.labelMicro.copyWith(color: statusColor),
          ),
        ),
      ),
      DataCell(Text(Formatters.currency(hostel.pricePerMonth),
          style: AppTextStyles.body)),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hostel.status == ListingStatus.pending) ...[
            IconButton(
              icon: const Icon(Icons.check_circle_outline,
                  color: AppColors.primary),
              onPressed: () => controller.approve(hostel),
              tooltip: AppStrings.adminApproveHostelTooltip,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              onPressed: () => _showRejectDialog(hostel),
              tooltip: AppStrings.adminRejectHostelTooltip,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteConfirm(hostel),
            tooltip: AppStrings.adminDeleteHostelTooltip,
          ),
        ],
      )),
    ]);
  }

  void _showRejectDialog(HostelModel hostel) {
    final reasonController = TextEditingController();
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.adminRejectHostelDialogTitle,
                  style: AppTextStyles.sectionHeader),
              const SizedBox(height: 16),
              AppTextField(
                controller: reasonController,
                hintText: AppStrings.adminReasonFieldLabel,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: AppStrings.adminRejectButton,
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) return;
                  Get.back();
                  controller.reject(hostel,
                      reason.length > 500 ? reason.substring(0, 500) : reason);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(HostelModel hostel) {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.adminConfirmDeleteTitle,
        message: AppStrings.adminConfirmDeleteMessage(hostel.name),
        confirmText: AppStrings.adminDeleteButton,
        cancelText: AppStrings.adminCancelButton,
        isDestructive: true,
        onCancel: () => Get.back(),
        onConfirm: () {
          Get.back();
          controller.deleteHostel(hostel);
        },
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => hostels.length;

  @override
  int get selectedRowCount => 0;
}
