import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/result_state_screen.dart';
import '../../../transactions/presentation/screens/receipt_screen.dart';
import '../../domain/qr_payload.dart';
import '../qr_transfer_controller.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isDialogOpen = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isDialogOpen) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _handleRawPayload(rawValue);
  }

  void _handleRawPayload(String rawValue) {
    final qrController = context.read<QrTransferController>();
    qrController.handleQrCodeScanned(rawValue);
    final payload = qrController.scannedPayload;
    if (payload == null) return;

    _isDialogOpen = true;
    _showPaymentConfirmationSheet(payload).whenComplete(() {
      if (mounted) {
        setState(() {
          _isDialogOpen = false;
        });
      }
    });
  }

  Future<void> _showPaymentConfirmationSheet(QrTransferPayload payload) async {
    final amountController = TextEditingController(
      text: payload.amount != null ? payload.amount!.toStringAsFixed(2) : '',
    );
    final noteController = TextEditingController(text: payload.note ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;
        final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Consumer<QrTransferController>(
            builder: (context, controller, _) {
              final isLoading = controller.transferState is Loading;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Confirm QR Payment',
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Paying ${payload.recipient} (${payload.accountHandle})',
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Amount (USD)',
                    hintText: '0.00',
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Reference Note',
                    hintText: 'What is this for?',
                    controller: noteController,
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Authenticate & Pay',
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () async {
                            final amount =
                                double.tryParse(amountController.text.trim()) ??
                                0.0;
                            if (amount <= 0) return;

                            final tx = await controller.executeTransfer(
                              amount: amount,
                              note: noteController.text.trim(),
                            );

                            if (!sheetCtx.mounted || !mounted) return;
                            Navigator.of(sheetCtx).pop();

                            final navigator = Navigator.of(context);
                            final state = controller.transferState;
                            if (tx != null && state is Success) {
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => ResultStateScreen(
                                    isSuccess: true,
                                    title: 'Transfer Sent',
                                    subtitle:
                                        '${CurrencyFormatter.format(tx.amount)} sent to ${tx.recipientName}.',
                                    summaryDetails: {
                                      'Recipient': tx.recipientName,
                                      'Handle': payload.accountHandle,
                                      'Amount': CurrencyFormatter.format(
                                        tx.amount,
                                      ),
                                      'Reference': tx.referenceNumber,
                                    },
                                    primaryButtonText: 'View Receipt',
                                    onPrimaryPressed: () {
                                      navigator.pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ReceiptScreen(transaction: tx),
                                        ),
                                      );
                                    },
                                    secondaryButtonText: 'Done',
                                    onSecondaryPressed: () => navigator.pop(),
                                  ),
                                ),
                              );
                            } else if (state case Failure(:final message)) {
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => ResultStateScreen(
                                    isSuccess: false,
                                    title: 'Transfer Failed',
                                    subtitle: message,
                                    primaryButtonText: 'Try Again',
                                    onPrimaryPressed: () => navigator.pop(),
                                  ),
                                ),
                              );
                            }
                          },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrController = context.watch<QrTransferController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Scan to Pay',
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: qrController.isTorchOn
                ? 'Turn off flash'
                : 'Turn on flash',
            icon: Icon(
              qrController.isTorchOn
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              color: qrController.isTorchOn
                  ? AppColors.primaryYellow
                  : Colors.white,
            ),
            onPressed: () async {
              qrController.toggleTorch();
              await _scannerController.toggleTorch();
            },
          ),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 540,
        child: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 64,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera unavailable on this device',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Grant camera permissions in Settings or use a sample TapPay QR payload below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            IgnorePointer(
              child: Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primaryGreen, width: 3),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Align a TapPay QR code inside the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Simulate Scan (@sarahj)',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.qr_code_rounded,
                    onPressed: () {
                      const sample = QrTransferPayload(
                        recipient: 'Sarah Jenkins',
                        accountHandle: '@sarahj',
                        amount: 45.00,
                        note: 'Coffee split',
                      );
                      _handleRawPayload(sample.toRawString());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
