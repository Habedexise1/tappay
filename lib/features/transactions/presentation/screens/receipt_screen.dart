import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/transaction_model.dart';

class ReceiptScreen extends StatefulWidget {
  final TransactionModel transaction;

  const ReceiptScreen({super.key, required this.transaction});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final GlobalKey _receiptBoundaryKey = GlobalKey();
  bool _isExporting = false;

  Future<File?> _captureReceiptImage() async {
    try {
      final boundary =
          _receiptBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/TapPay_Receipt_${widget.transaction.referenceNumber}.png',
      );
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  Future<void> _shareReceipt() async {
    setState(() => _isExporting = true);
    final file = await _captureReceiptImage();
    setState(() => _isExporting = false);

    if (file != null) {
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'TapPay Transaction Receipt (${widget.transaction.referenceNumber})',
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not generate receipt image'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  Future<void> _saveReceiptLocally() async {
    setState(() => _isExporting = true);
    final file = await _captureReceiptImage();
    setState(() => _isExporting = false);

    if (mounted) {
      if (file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Receipt saved to device: ${file.path.split('/').last}',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save receipt'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final tx = widget.transaction;

    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Transaction Receipt',
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 460,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: RepaintBoundary(
                    key: _receiptBoundaryKey,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorderSubtle,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'tappay.',
                                style: TextStyle(
                                  fontFamily: 'Gordita',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.primaryGreen
                                      : const Color(0xFF0D1311),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tx.status.label.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Gordita',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Text(
                            '${tx.isOutflow ? '-' : '+'} ${CurrencyFormatter.format(tx.amount)}',
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tx.title,
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),

                          const SizedBox(height: 24),
                          Divider(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorderSubtle,
                          ),
                          const SizedBox(height: 16),

                          _buildReceiptRow(
                            context,
                            'Reference Number',
                            tx.referenceNumber,
                            isDark,
                          ),
                          _buildReceiptRow(
                            context,
                            'Date & Time',
                            DateFormatter.formatFull(tx.date),
                            isDark,
                          ),
                          _buildReceiptRow(
                            context,
                            'Recipient',
                            tx.recipientName,
                            isDark,
                          ),
                          _buildReceiptRow(
                            context,
                            'Category',
                            tx.category,
                            isDark,
                          ),
                          _buildReceiptRow(
                            context,
                            'Transfer Fee',
                            CurrencyFormatter.format(tx.fee),
                            isDark,
                          ),
                          if (tx.note != null && tx.note!.isNotEmpty)
                            _buildReceiptRow(context, 'Note', tx.note!, isDark),

                          const SizedBox(height: 16),
                          Divider(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorderSubtle,
                          ),
                          const SizedBox(height: 12),

                          Text(
                            'Generated securely by TapPay Engine',
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Save Image',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.download_rounded,
                      isLoading: _isExporting,
                      onPressed: _saveReceiptLocally,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Share',
                      icon: Icons.share_rounded,
                      isLoading: _isExporting,
                      onPressed: _shareReceipt,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    BuildContext context,
    String label,
    String value,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
