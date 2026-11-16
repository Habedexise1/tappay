import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/dashboard_models.dart';
import '../dashboard_controller.dart';
import '../transfer_flow.dart';

class SendMoneyRecipientScreen extends StatefulWidget {
  final Beneficiary? preselectedBeneficiary;

  const SendMoneyRecipientScreen({
    super.key,
    this.preselectedBeneficiary,
  });

  @override
  State<SendMoneyRecipientScreen> createState() => _SendMoneyRecipientScreenState();
}

class _SendMoneyRecipientScreenState extends State<SendMoneyRecipientScreen> {
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _bankOptionController = TextEditingController(text: 'TapPay');

  bool _saveAsBeneficiary = false;
  String? _tagError;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedBeneficiary != null) {
      _tagController.text = widget.preselectedBeneficiary!.handle;
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    _bankOptionController.dispose();
    super.dispose();
  }

  String _resolveAccountName(List<Beneficiary> beneficiaries) {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) return 'Account name';

    final normalized = raw.startsWith('@') ? raw.toLowerCase() : '@${raw.toLowerCase()}';
    for (final b in beneficiaries) {
      if (b.handle.toLowerCase() == normalized) {
        return b.name;
      }
    }

    final clean = raw.replaceFirst('@', '').trim();
    if (clean.isEmpty) return 'Account name';
    return clean[0].toUpperCase() + clean.substring(1);
  }

  void _onSendMoney() {
    final rawTag = _tagController.text.trim();
    if (rawTag.isEmpty) {
      setState(() => _tagError = 'Enter a TapTag');
      return;
    }

    final dashboard = context.read<DashboardController>();
    final resolvedName = _resolveAccountName(dashboard.beneficiaries);
    final displayTag = rawTag.startsWith('@') ? rawTag : '@$rawTag';
    final recipientName = resolvedName == 'Account name' ? displayTag : resolvedName;

    if (_saveAsBeneficiary) {
      dashboard.addBeneficiary(
        name: recipientName,
        handle: displayTag,
      );
    }

    startTransferFlow(
      context,
      recipientName: recipientName,
      recipientDetail: 'TapTag • $displayTag',
      note: 'TapPay Transfer',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final dashboard = context.watch<DashboardController>();
    final resolvedAccountName = _resolveAccountName(dashboard.beneficiaries);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 520,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          key: const ValueKey('send_money_recipient_back_btn'),
                          icon: Icon(
                            Icons.arrow_back,
                            size: 26,
                            color: titleColor,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
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
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'TapTag',
                        hintText: 'Type tag',
                        controller: _tagController,
                        errorText: _tagError,
                        onChanged: (_) {
                          if (_tagError != null) {
                            setState(() => _tagError = null);
                          } else {
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          resolvedAccountName,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _tagController.text.trim().isEmpty ? subColor : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Bank Option',
                        hintText: 'Select option',
                        controller: _bankOptionController,
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _saveAsBeneficiary = !_saveAsBeneficiary;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: _saveAsBeneficiary ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _saveAsBeneficiary ? AppColors.primary : borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: _saveAsBeneficiary
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: AppColors.lightTextPrimary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Save as beneficiary',
                              style: TextStyle(
                                fontFamily: 'Gordita',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: AppButton(
                  text: 'Send money',
                  onPressed: _onSendMoney,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
