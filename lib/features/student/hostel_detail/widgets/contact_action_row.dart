import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

class ContactActionRow extends StatelessWidget {
  final String phone;
  final String whatsapp;

  const ContactActionRow({
    super.key,
    required this.phone,
    required this.whatsapp,
  });

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsapp() async {
    final formattedNum = whatsapp.replaceAll(' ', '').replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$formattedNum');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: AppStrings.callButton,
            intent: ButtonIntent.secondary,
            onPressed: _launchPhone,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: PrimaryButton(
            text: AppStrings.whatsappButton,
            onPressed: _launchWhatsapp,
          ),
        ),
      ],
    );
  }
}
