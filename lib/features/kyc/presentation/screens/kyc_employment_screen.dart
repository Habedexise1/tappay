import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import 'kyc_identity_screen.dart';

class KycEmploymentScreen extends StatelessWidget {
  const KycEmploymentScreen({super.key});

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
        profile.employmentStatus != null &&
        profile.incomeBand != null &&
        kycController.isBankStatementUploaded;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KYC Verification (1/3)',
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
                  'What do you do?',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select your current employment status and monthly income range.',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                ...EmploymentStatus.values.map((status) {
                  final selected = profile.employmentStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => kycController.updateEmploymentStatus(status),
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
                                  status.label,
                                  style: TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  status.description,
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
                const SizedBox(height: 20),

                Text(
                  'Monthly Income Band',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: IncomeBand.values.map((band) {
                    final selected = profile.incomeBand == band;
                    return ChoiceChip(
                      label: Text(
                        band.label,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.lightTextPrimary
                              : textPrimary,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppColors.primaryGreen,
                      onSelected: (_) => kycController.updateIncomeBand(band),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                Text(
                  'Supporting Document',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  onTap: () => kycController.simulateUploadBankStatement(),
                  borderSide: kycController.isBankStatementUploaded
                      ? const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 1.5,
                        )
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        kycController.isBankStatementUploaded
                            ? Icons.description_rounded
                            : Icons.upload_file_rounded,
                        color: kycController.isBankStatementUploaded
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
                              kycController.isBankStatementUploaded
                                  ? (profile.bankStatementPath ??
                                        'bank_statement_2026.pdf')
                                  : 'Upload Bank Statement (PDF)',
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              kycController.isBankStatementUploaded
                                  ? 'Uploaded and ready for verification'
                                  : 'Last 3 months statement • Max 10MB',
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 12,
                                color: kycController.isBankStatementUploaded
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
                  text: 'Continue to Identity',
                  onPressed: canProceed
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const KycIdentityScreen(),
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
