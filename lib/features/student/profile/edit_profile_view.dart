import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profile_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.editProfileButton,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.gutter),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel(AppStrings.editProfileNameLabel,
                  style: FieldLabelStyle.form),
              SizedBox(height: AppSpacing.xs),
              FormField<String>(
                validator: (val) =>
                    Validators.required(controller.nameController.text),
                builder: (state) => AppTextField(
                  controller: controller.nameController,
                  hintText: AppStrings.editProfileNameLabel,
                  leadingIcon: Icons.person_outline,
                  errorText: state.errorText,
                  onChanged: (val) {
                    state.didChange(val);
                    if (state.hasError) state.validate();
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Obx(
                () => PrimaryButton(
                  text: AppStrings.okButton,
                  expand: true,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
