import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/widgets/onboarding_step_header.dart';
import '../../domain/dashboard_models.dart';
import 'send_money_recipient_screen.dart';
import 'send_to_bank_screen.dart';

class BeneficiariesScreen extends StatefulWidget {
  final bool isBankTransfer;

  const BeneficiariesScreen({super.key, this.isBankTransfer = false});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm({Beneficiary? beneficiary}) {
    if (widget.isBankTransfer) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SendToBankScreen(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SendMoneyRecipientScreen(
            preselectedBeneficiary: beneficiary,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 520,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const OnboardingStepHeader(),
                const SizedBox(height: 20),
                Text(
                  'Send Money',
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hintText: 'Search beneficiaries',
                  controller: _searchController,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: subColor,
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => _openForm(),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.add_rounded, size: 22, color: titleColor),
                        const SizedBox(width: 14),
                        Text(
                          'New account',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
