import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import 'kyc_selfie_screen.dart';

class KycIdentityScreen extends StatefulWidget {
  const KycIdentityScreen({super.key});

  @override
  State<KycIdentityScreen> createState() => _KycIdentityScreenState();
}

class _KycIdentityScreenState extends State<KycIdentityScreen> {
  late final TextEditingController _idNumberController;

  @override
  void initState() {
    super.initState();
    final initialNumber = context.read<KycController>().profile.idNumber;
    _idNumberController = TextEditingController(text: initialNumber);
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth(KycController controller) async {
    final now = DateTime.now();
    final initial =
        controller.profile.dateOfBirth ??
        DateTime(now.year - 24, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (picked != null) {
      controller.updateDateOfBirth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycController = context.watch<KycController>();
    final profile = kycController.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final canProceed =
        profile.dateOfBirth != null &&
        profile.idNumber.trim().length >= 5 &&
        kycController.isIdFrontUploaded;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KYC Verification (2/3)',
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 520,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identity Details',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Verify your legal date of birth and upload a valid government ID.',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Date of Birth',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                AppCard(
                  onTap: () => _pickDateOfBirth(kycController),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profile.dateOfBirth != null
                              ? DateFormatter.formatFull(profile.dateOfBirth!)
                              : 'Select Date of Birth',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: profile.dateOfBirth != null
                                ? textPrimary
                                : textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Document Type',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ...IdType.values.map((idType) {
                  final selected = profile.idType == idType;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => kycController.updateIdType(idType),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      borderSide: selected
                          ? const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 1.5,
                            )
                          : null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  idType.label,
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  idType.description,
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: selected
                                ? AppColors.primaryGreen
                                : textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),

                AppTextField(
                  label: 'ID Document Number',
                  hintText: 'Enter document number',
                  controller: _idNumberController,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  onChanged: kycController.updateIdNumber,
                ),
                const SizedBox(height: 20),

                AppCard(
                  onTap: () => kycController.simulateUploadIdFront(),
                  borderSide: kycController.isIdFrontUploaded
                      ? const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 1.5,
                        )
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        kycController.isIdFrontUploaded
                            ? Icons.verified_user_rounded
                            : Icons.add_a_photo_outlined,
                        color: kycController.isIdFrontUploaded
                            ? AppColors.primaryGreen
                            : textSecondary,
                        size: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kycController.isIdFrontUploaded
                                  ? (profile.idFrontPath ?? 'id_front_scan.jpg')
                                  : 'Capture Front of ${profile.idType.label}',
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              kycController.isIdFrontUploaded
                                  ? 'Front view image captured'
                                  : 'Ensure all 4 corners are clearly visible',
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 12,
                                color: kycController.isIdFrontUploaded
                                    ? AppColors.primaryGreen
                                    : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                AppButton(
                  text: 'Continue to Selfie',
                  onPressed: canProceed
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const KycSelfieScreen(),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
