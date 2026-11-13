import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../account/account_settings_body.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.accountSettingsTitle,
      ),
      body: AccountSettingsBody(),
    );
  }
}
