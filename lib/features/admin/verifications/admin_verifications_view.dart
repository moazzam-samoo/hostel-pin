import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_verifications_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/verification_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/feedback/confirm_dialog.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../core/utils/responsive.dart';

/// Phase 9 Block G — Verification Queue + Review, the highest-consequence
/// screen in this phase. One controller, two states: the queue list (tabs +
/// table) and a per-submission Review detail — driven by
/// [AdminVerificationsController.selected] rather than a separate route, so
/// this reuses the shared shell's tab slot directly.
class AdminVerificationsView extends GetView<AdminVerificationsController> {
  const AdminVerificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final submission = controller.selected.value;
      if (submission != null) {
        return _ReviewDetail(submission: submission);
      }
      return const _QueueList();
    });
  }
}

class _QueueList extends GetView<AdminVerificationsController> {
  const _QueueList();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.adminVerificationQueueTitle, style: AppTextStyles.screenTitle),
                      const SizedBox(height: 4),
                      Text(AppStrings.adminVerificationQueueSubtitle, style: AppTextStyles.screenSubtitle),
                    ],
                  ),
                ),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        AppStrings.adminPendingCountBadge(controller.identityPendingTab.length),
                        style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: AppTextStyles.body,
              unselectedLabelStyle: AppTextStyles.body,
              tabs: const [
                Tab(text: AppStrings.adminTabAll),
                Tab(text: AppStrings.adminTabIdentityPending),
                Tab(text: AppStrings.adminTabHostelPending),
                Tab(text: AppStrings.adminTabChangesRequired),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Obx(() => _buildTable(context, controller.allTab)),
                Obx(() => _buildTable(context, controller.identityPendingTab)),
                Obx(() => _buildTable(context, controller.hostelPendingTab)),
                Obx(() => _buildTable(context, controller.changesRequiredTab)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<VerificationModel> rows) {
    if (controller.isLoading.value && rows.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (rows.isEmpty) {
      return Center(
        child: Text(
          AppStrings.adminNoSubmissionsFound,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.background),
          columns: [
            DataColumn(label: Text(AppStrings.adminColSubmissionDate, style: AppTextStyles.labelMicro)),
            DataColumn(label: Text(AppStrings.adminColOwnerName, style: AppTextStyles.labelMicro)),
            DataColumn(label: Text(AppStrings.adminColHostelName, style: AppTextStyles.labelMicro)),
            DataColumn(label: Text(AppStrings.adminColCity, style: AppTextStyles.labelMicro)),
            DataColumn(label: Text(AppStrings.adminColType, style: AppTextStyles.labelMicro)),
            DataColumn(label: Text(AppStrings.adminColStatus, style: AppTextStyles.labelMicro)),
            DataColumn(label: Text(AppStrings.adminColActions, style: AppTextStyles.labelMicro)),
          ],
          rows: rows.map((submission) => _buildRow(submission)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(VerificationModel submission) {
    final hostel = submission.hostelId != null ? controller.hostelCache[submission.hostelId] : null;
    final isHostelType = submission.hostelId != null && submission.hostelId!.isNotEmpty;
    final fullName = (submission.personalInfo['fullName'] as String?) ?? '';

    Color statusColor;
    String statusLabel;
    switch (submission.status) {
      case 'changesRequested':
        statusColor = AppColors.textSecondary;
        statusLabel = AppStrings.adminTabChangesRequired;
        break;
      default:
        statusColor = AppColors.primary;
        statusLabel = submission.status.capitalizeFirst ?? submission.status;
    }

    return DataRow(cells: [
      DataCell(Text(
        submission.submittedAt?.toString().split(' ')[0] ?? AppStrings.notAvailableDash,
        style: AppTextStyles.body,
      )),
      DataCell(Text(fullName, style: AppTextStyles.body)),
      DataCell(Text(hostel?.name ?? AppStrings.adminLoadingLabel, style: AppTextStyles.body)),
      DataCell(Text(hostel?.city ?? AppStrings.notAvailableDash, style: AppTextStyles.body)),
      DataCell(Text(
        isHostelType ? AppStrings.adminTypeHostel : AppStrings.adminTypeIdentity,
        style: AppTextStyles.body,
      )),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(statusLabel, style: AppTextStyles.labelMicro.copyWith(color: statusColor)),
        ),
      ),
      DataCell(
        SecondaryButton(
          text: AppStrings.adminReviewButton,
          intent: ButtonIntent.primary,
          width: 100,
          onPressed: () => controller.selectSubmission(submission),
        ),
      ),
    ]);
  }
}

class _ReviewDetail extends GetView<AdminVerificationsController> {
  final VerificationModel submission;
  const _ReviewDetail({required this.submission});

  @override
  Widget build(BuildContext context) {
    final fullName = (submission.personalInfo['fullName'] as String?) ?? '';
    final cnic = (submission.personalInfo['cnicNumber'] as String?) ?? '';
    final phone = (submission.personalInfo['phone'] as String?) ?? '';
    final dob = (submission.personalInfo['dob'] as String?) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: controller.clearSelection,
                  icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.textSecondary),
                  label: Text(
                    AppStrings.adminBackToQueue,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(AppStrings.adminReviewHeading(fullName), style: AppTextStyles.screenTitle),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final left = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        icon: Icons.person_outline,
                        title: AppStrings.adminOwnerDetailsSection,
                        child: _ownerDetails(fullName, cnic, phone, dob),
                      ),
                      const SizedBox(height: 20),
                      _sectionCard(
                        icon: Icons.badge_outlined,
                        title: AppStrings.adminIdentityDocumentsSection,
                        trailing: _aiMatchedBadge(),
                        child: _identityDocuments(),
                      ),
                    ],
                  );
                  final right = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        icon: Icons.apartment_outlined,
                        title: AppStrings.adminPropertyDetailsSection,
                        child: _propertyDetails(),
                      ),
                      const SizedBox(height: 20),
                      _sectionCard(
                        icon: Icons.description_outlined,
                        title: AppStrings.adminOwnershipProofSection,
                        child: _ownershipProof(),
                      ),
                      const SizedBox(height: 20),
                      _sectionCard(
                        icon: Icons.image_outlined,
                        title: AppStrings.adminPropertyPhotosSection,
                        child: _propertyPhotos(),
                      ),
                    ],
                  );

                  if (!isWide) {
                    return Column(children: [left, const SizedBox(height: 20), right]);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 20),
                      Expanded(child: right),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        _actionBar(context),
      ],
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: AppTextStyles.cardTitle)),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          child,
        ],
      ),
    );
  }

  Widget _aiMatchedBadge() {
    // Per IMPLEMENTATION_PLAN §9.A/D1 and TASK-Phase-9 Block G.2: identity
    // verification stays manual. This badge is purely decorative UI that
    // echoes the mockup's layout — it is NOT wired to any real computation,
    // and never will be from this widget alone.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(AppStrings.adminAiMatchedBadge, style: AppTextStyles.labelMicro.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? AppStrings.notAvailableDash : value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _ownerDetails(String fullName, String cnic, String phone, String dob) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _field(AppStrings.adminFullNameLabel, fullName),
          _field(AppStrings.adminPhoneNumberLabel, phone),
        ])),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _field(AppStrings.adminCnicNumberLabel, cnic),
          _field(AppStrings.adminDobLabel, dob),
        ])),
      ],
    );
  }

  Widget _propertyDetails() {
    return Obx(() {
      final hostel = controller.selectedHostel.value;
      if (controller.isLoadingDetail.value && hostel == null) {
        return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary)));
      }
      if (hostel == null) {
        return Text(AppStrings.notAvailableDash, style: AppTextStyles.body);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _field(AppStrings.adminHostelNameFieldLabel, hostel.name),
        _field(AppStrings.adminAddressLabel, hostel.fullAddress),
        Row(children: [
          Expanded(child: _field(AppStrings.adminCityLabel, hostel.city)),
          Expanded(child: _field(AppStrings.adminCapacityLabel, AppStrings.adminCapacityValue(hostel.totalRooms, hostel.totalBeds))),
        ]),
      ]);
    });
  }

  Widget _docThumb(String? publicId, String label) {
    return Obx(() {
      final url = publicId != null ? controller.resolvedDocUrls[publicId] : null;
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 6),
            AspectRatio(
              aspectRatio: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceTonal,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: url == null
                    ? (controller.isLoadingDetail.value
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : Center(
                            child: Text(
                              AppStrings.adminDocumentLoadError,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption,
                            ),
                          ))
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(AppStrings.adminDocumentLoadError, style: AppTextStyles.caption),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _identityDocuments() {
    final cnicFrontId = submission.identityDocuments['cnicFrontUrl'] as String?;
    final cnicBackId = submission.identityDocuments['cnicBackUrl'] as String?;
    final selfieId = submission.identityDocuments['selfieUrl'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _docThumb(cnicFrontId, AppStrings.adminCnicFrontLabel),
          const SizedBox(width: 12),
          _docThumb(cnicBackId, AppStrings.adminCnicBackLabel),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceTonal,
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          child: Row(
            children: [
              Obx(() {
                final url = selfieId != null ? controller.resolvedDocUrls[selfieId] : null;
                return CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.border,
                  backgroundImage: url != null ? NetworkImage(url) : null,
                  child: url == null ? const Icon(Icons.person, color: AppColors.textSecondary) : null,
                );
              }),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.adminLiveSelfieCheckLabel, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.92,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.adminAiMatchDecorativeValue,
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(AppStrings.adminAiMatchDecorativeCaption, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ownershipProof() {
    final publicId = submission.ownershipDocumentUrl;
    if (publicId == null || publicId.isEmpty) {
      return Text(AppStrings.adminDocumentNotProvided, style: AppTextStyles.body);
    }
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          child: const Icon(Icons.description, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SecondaryButton(
            text: AppStrings.adminViewFullDocumentButton,
            intent: ButtonIntent.primary,
            onPressed: () => _openDocument(publicId),
          ),
        ),
      ],
    );
  }

  void _openDocument(String publicId) {
    final url = controller.resolvedDocUrls[publicId];
    Get.dialog(
      Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: url == null
              ? Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(AppStrings.adminDocumentLoadError, style: AppTextStyles.body),
                )
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(AppStrings.adminDocumentLoadError, style: AppTextStyles.body),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _propertyPhotos() {
    return Obx(() {
      final hostel = controller.selectedHostel.value;
      if (hostel == null || hostel.photos.isEmpty) {
        return Text(AppStrings.notAvailableDash, style: AppTextStyles.body);
      }
      return SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: hostel.photos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.field),
            child: Image.network(
              hostel.photos[index].url,
              width: 110,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 110,
                height: 90,
                color: AppColors.surfaceTonal,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _actionBar(BuildContext context) {
    final infoWidget = Row(
      children: [
        const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppStrings.adminReviewFooterNote,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );

    final isDesktop = Responsive.isDesktop(context);

    final actionsWidget = Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.end,
      children: [
        Obx(() => SecondaryButton(
              text: AppStrings.adminRequestChangesButton,
              intent: ButtonIntent.primary,
              width: isDesktop ? 180 : null,
              isLoading: controller.isSubmittingDecision.value,
              onPressed: () => _showReasonDialog(
                title: AppStrings.adminRequestChangesDialogTitle,
                onSubmit: controller.requestChanges,
              ),
            )),
        Obx(() => SecondaryButton(
              text: AppStrings.adminRejectButton,
              intent: ButtonIntent.secondary,
              width: isDesktop ? 140 : null,
              isLoading: controller.isSubmittingDecision.value,
              onPressed: () => _showReasonDialog(
                title: AppStrings.adminRejectDialogTitle,
                onSubmit: controller.reject,
              ),
            )),
        Obx(() => SizedBox(
              width: isDesktop ? 220 : double.infinity,
              child: PrimaryButton(
                text: AppStrings.adminApproveButton,
                isLoading: controller.isSubmittingDecision.value,
                onPressed: () => _confirmApprove(context),
              ),
            )),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: infoWidget),
                const SizedBox(width: 24),
                actionsWidget,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                infoWidget,
                const SizedBox(height: 16),
                actionsWidget,
              ],
            ),
    );
  }

  void _confirmApprove(BuildContext context) {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.adminApproveButton,
        message: AppStrings.adminReviewFooterNote,
        confirmText: AppStrings.adminApproveButton,
        cancelText: AppStrings.adminCancelButton,
        onCancel: () => Get.back(),
        onConfirm: () {
          Get.back();
          controller.approve();
        },
      ),
    );
  }

  void _showReasonDialog({required String title, required Future<void> Function(String reason) onSubmit}) {
    final reasonController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppTextStyles.sectionHeader),
              const SizedBox(height: 16),
              AppTextField(
                controller: reasonController,
                hintText: AppStrings.adminReasonFieldLabel,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: title,
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) return;
                  Get.back();
                  onSubmit(reason);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
