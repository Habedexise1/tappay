import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../dashboard_controller.dart';
import '../transfer_flow.dart';

class SendToBankScreen extends StatefulWidget {
  const SendToBankScreen({super.key});

  @override
  State<SendToBankScreen> createState() => _SendToBankScreenState();
}

class _SendToBankScreenState extends State<SendToBankScreen> {
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedBank;
  bool _saveAsBeneficiary = false;
  String? _bankError;
  String? _accountError;

  static const List<String> _banks = [
    'Keystone Bank',
    'Access Bank',
    'Guaranty Trust Bank (GTBank)',
    'Zenith Bank',
    'Providus Bank',
    'Kuda Bank',
    'United Bank for Africa (UBA)',
    'First Bank of Nigeria',
    'OPay',
    'PalmPay',
    'Stanbic IBTC Bank',
    'Wema Bank (ALAT)',
    'Fidelity Bank',
    'Union Bank',
    'Sterling Bank',
  ];

  @override
  void dispose() {
    _bankController.dispose();
    _accountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _resolveAccountName() {
    final text = _accountController.text.trim();
    if (text.length >= 10) {
      return 'John Doe';
    }
    return 'Account name';
  }

  void _showBankPicker() {
    String searchQuery = '';
    showAppBottomSheet<void>(
      context: context,
      title: 'Select Bank',
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
            final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
            final filtered = _banks
                .where((b) => b.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    hintText: 'Search bank',
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: subColor),
                    onChanged: (val) {
                      setModalState(() => searchQuery = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, index) => Divider(
                        height: 1,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      itemBuilder: (ctx, idx) {
                        final bank = filtered[idx];
                        final isSelected = bank == _selectedBank;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          title: Text(
                            bank,
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.primary : titleColor,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedBank = bank;
                              _bankController.text = bank;
                              _bankError = null;
                            });
                            Navigator.of(sheetContext).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onSendMoney() {
    final accountText = _accountController.text.trim();
    setState(() {
      _bankError = _selectedBank == null ? 'Please select a bank' : null;
      _accountError = accountText.length < 10 ? 'Enter a 10-digit account number' : null;
    });

    if (_bankError != null || _accountError != null) return;

    final resolvedName = _resolveAccountName();
    final note = _descriptionController.text.trim().isEmpty
        ? 'Bank Transfer'
        : _descriptionController.text.trim();

    if (_saveAsBeneficiary) {
      context.read<DashboardController>().addBeneficiary(
        name: resolvedName,
        handle: '$_selectedBank • $accountText',
      );
    }

    startTransferFlow(
      context,
      recipientName: resolvedName,
      recipientDetail: '$_selectedBank • $accountText',
      isBankTransfer: true,
      note: note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final resolvedName = _resolveAccountName();
    final isResolved = _accountController.text.trim().length >= 10;

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
                          key: const ValueKey('send_to_bank_back_btn'),
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
                        'Send to bank',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Bank',
                        hintText: 'Select bank',
                        controller: _bankController,
                        readOnly: true,
                        errorText: _bankError,
                        onTap: _showBankPicker,
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 24,
                          color: subColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Account number',
                        hintText: '0123456789',
                        controller: _accountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        errorText: _accountError,
                        onChanged: (_) {
                          if (_accountError != null) {
                            setState(() => _accountError = null);
                          } else {
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          resolvedName,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isResolved ? AppColors.primary : subColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Description',
                        hintText: 'Write short note',
                        controller: _descriptionController,
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
