import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/widgets/onboarding_step_header.dart';
import '../../domain/dashboard_models.dart';
import '../dashboard_controller.dart';
import 'send_money_form_screen.dart';

class BeneficiariesScreen extends StatefulWidget {
  final bool isBankTransfer;

  const BeneficiariesScreen({super.key, this.isBankTransfer = false});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Beneficiary> _filterBeneficiaries(List<Beneficiary> items) {
    final trimmed = _query.trim().toLowerCase();
    if (trimmed.isEmpty) return items;
    return items
        .where(
          (b) =>
              b.name.toLowerCase().contains(trimmed) ||
              b.handle.toLowerCase().contains(trimmed),
        )
        .toList();
  }

  void _openForm({Beneficiary? beneficiary}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendMoneyFormScreen(
          preselectedBeneficiary: beneficiary,
          isBankTransfer: widget.isBankTransfer,
        ),
      ),
    );
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
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final beneficiaries = _filterBeneficiaries(
      context.watch<DashboardController>().beneficiaries,
    );

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
                  onChanged: (value) {
                    setState(() => _query = value);
                  },
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
                const SizedBox(height: 12),
                Expanded(
                  child: beneficiaries.isEmpty
                      ? Center(
                          child: Text(
                            'No beneficiaries found',
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 13,
                              color: subColor,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: beneficiaries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final beneficiary = beneficiaries[index];
                            return InkWell(
                              onTap: () => _openForm(beneficiary: beneficiary),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.14,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        beneficiary.initials,
                                        style: const TextStyle(
                                          fontFamily: 'Gordita',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            beneficiary.name,
                                            style: TextStyle(
                                              fontFamily: 'Gordita',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: titleColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            beneficiary.handle,
                                            style: TextStyle(
                                              fontFamily: 'Gordita',
                                              fontSize: 12,
                                              color: subColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: subColor,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
