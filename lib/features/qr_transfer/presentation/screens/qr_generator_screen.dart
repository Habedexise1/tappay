import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/qr_payload.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  double? _requestedAmount;
  String _note = '';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  QrTransferPayload get _currentPayload => QrTransferPayload(
    recipient: 'Alex Pay',
    accountHandle: '@alexpay',
    amount: _requestedAmount,
    note: _note.isNotEmpty ? _note : null,
  );

  void _updatePayload() {
    setState(() {
      final parsed = double.tryParse(_amountController.text.trim());
      _requestedAmount = (parsed != null && parsed > 0) ? parsed : null;
      _note = _noteController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final rawQr = _currentPayload.toRawString();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Receive via QR',
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 480,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Alex Pay',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@alexpay',
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: QrImageView(
                          data: rawQr,
                          version: QrVersions.auto,
                          size: 210,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF081711),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF081711),
                          ),
                        ),
                      ),
                      if (_requestedAmount != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Requested: \$${_requestedAmount!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Scan with any TapPay app to send money instantly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Request Specific Amount (Optional)',
                  hintText: '0.00',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  onChanged: (_) => _updatePayload(),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Payment Note (Optional)',
                  hintText: 'e.g. Dinner invoice',
                  controller: _noteController,
                  prefixIcon: const Icon(Icons.note_outlined),
                  onChanged: (_) => _updatePayload(),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Share Payment Link',
                  icon: Icons.share_rounded,
                  onPressed: () {
                    final amountText = _requestedAmount != null
                        ? ' for \$${_requestedAmount!.toStringAsFixed(2)}'
                        : '';
                    Share.share(
                      'Send money to Alex Pay (@alexpay) on TapPay$amountText.',
                      subject: 'TapPay Payment Request',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
