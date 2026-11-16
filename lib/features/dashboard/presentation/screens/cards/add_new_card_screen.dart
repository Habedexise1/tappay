import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../domain/dashboard_models.dart';
import '../../dashboard_controller.dart';

class AddNewCardScreen extends StatefulWidget {
  const AddNewCardScreen({super.key});

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String? _holderNameError;
  String? _cardNumberError;
  String? _expiryError;
  String? _cvvError;

  @override
  void dispose() {
    _holderNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submit() {
    final holderName = _holderNameController.text.trim();
    final cardNumber = _cardNumberController.text.trim();
    final rawCardNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final expiry = _expiryController.text.trim();
    final cvv = _cvvController.text.trim();

    setState(() {
      _holderNameError = null;
      _cardNumberError = null;
      _expiryError = null;
      _cvvError = null;
    });

    bool isValid = true;

    if (holderName.isEmpty) {
      _holderNameError = 'Enter card holder name';
      isValid = false;
    }

    if (rawCardNumber.length < 16) {
      _cardNumberError = 'Enter valid 16-digit card number';
      isValid = false;
    }

    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expiry)) {
      _expiryError = 'Enter MM/YY';
      isValid = false;
    }

    if (cvv.length < 3) {
      _cvvError = 'Enter 3-digit CVV';
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    final newCard = PaymentCard(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      holderName: holderName,
      cardNumber: cardNumber,
      expiryDate: expiry,
      cvv: cvv,
    );

    context.read<DashboardController>().addCard(newCard);

    Navigator.of(context).pop(newCard);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: const ValueKey('add_new_card_back_btn'),
                icon: Icon(
                  Icons.arrow_back,
                  size: 26,
                  color: textPrimary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 20),
              Text(
                'Add new card',
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Holder name',
                        hintText: 'John Doe',
                        controller: _holderNameController,
                        errorText: _holderNameError,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Card number',
                        hintText: '0000 0000 0000 0000',
                        controller: _cardNumberController,
                        errorText: _cardNumberError,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberFormatter(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Expiry date',
                              hintText: 'MM/YY',
                              controller: _expiryController,
                              errorText: _expiryError,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CardExpiryFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: 'CVV',
                              hintText: '000',
                              controller: _cvvController,
                              errorText: _cvvError,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppButton(
                  text: 'Add card',
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 4 ? digits.substring(0, 4) : digits;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
