import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
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
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      await launchUrl(uri);
    } catch (e) {
      debugPrint('Error launching phone: $e');
    }
  }

  Future<void> _launchWhatsapp() async {
    String cleanNum = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNum.startsWith('0')) {
      cleanNum = '92${cleanNum.substring(1)}';
    }
    const message = "Hello i want to see your hostel and want further details.";
    final uri = Uri.parse(
        'https://wa.me/$cleanNum?text=${Uri.encodeComponent(message)}');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback to web URL or standard mode if external app launcher failed
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
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
            icon: const Icon(Icons.call, size: 18, color: AppColors.secondary),
            onPressed: _launchPhone,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: PrimaryButton(
            text: AppStrings.whatsappButton,
            icon: const Icon(Icons.chat_bubble_outline,
                size: 18, color: AppColors.background),
            onPressed: _launchWhatsapp,
          ),
        ),
      ],
    );
  }
}
