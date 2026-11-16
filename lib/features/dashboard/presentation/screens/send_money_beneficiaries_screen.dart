import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/widgets/onboarding_step_header.dart';
import '../../domain/dashboard_models.dart';
import '../dashboard_controller.dart';
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
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
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

    final dashboard = context.watch<DashboardController>();
    final query = _searchController.text.trim().toLowerCase();
    final beneficiaries = dashboard.beneficiaries.where((b) {
      if (query.isEmpty) return true;
      return b.name.toLowerCase().contains(query) ||
          b.handle.toLowerCase().contains(query);
    }).toList();

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
                const SizedBox(height: 16),
                Expanded(
                  child: beneficiaries.isEmpty
                      ? Center(
                          child: Text(
                            query.isEmpty
                                ? 'No beneficiaries yet'
                                : 'No beneficiaries found',
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 14,
                              color: subColor,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: beneficiaries.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final b = beneficiaries[index];
                            return _BeneficiaryCard(
                              beneficiary: b,
                              isDark: isDark,
                              titleColor: titleColor,
                              subColor: subColor,
                              onTap: () => _openForm(beneficiary: b),
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

class _BeneficiaryCard extends StatelessWidget {
  final Beneficiary beneficiary;
  final bool isDark;
  final Color titleColor;
  final Color subColor;
  final VoidCallback onTap;

  const _BeneficiaryCard({
    required this.beneficiary,
    required this.isDark,
    required this.titleColor,
    required this.subColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF071F17) : const Color(0xFFF6F8F7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF143427) : AppColors.lightBorderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF093824) : const Color(0xFFE8F7F0),
                ),
                alignment: Alignment.center,
                child: Text(
                  beneficiary.initials,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF00D084) : AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      beneficiary.name,
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      beneficiary.handle,
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 13,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: subColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
