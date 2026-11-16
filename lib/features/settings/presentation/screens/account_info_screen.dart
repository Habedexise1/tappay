import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/view_state.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../dashboard/presentation/dashboard_controller.dart';
import '../../../kyc/domain/kyc_models.dart';
import '../../../kyc/presentation/kyc_controller.dart';
import '../settings_controller.dart';
import '../widgets/settings_widgets.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final kycStatus = context.select<KycController, KycStatus>(
      (k) => k.statusFor(
        KycFlow.forCurrencyCode(
          context.read<DashboardController>().selectedCurrency.code,
        ),
      ),
    );
    final isVerified = kycStatus == KycStatus.verified;

    final body = switch (settings.accountState) {
      Success(:final data) => Column(
        children: [
          _InfoRow(label: 'Bank name', value: data.bankName),
          _InfoRow(
            label: 'Account Number',
            value: data.accountNumber,
            trailing: CopyValueButton(
              value: data.accountNumber,
              confirmation: 'Account number copied',
              size: 20,
              tooltip: 'Copy account number',
            ),
          ),
          _InfoRow(label: 'Account Name', value: data.accountName),
          _InfoRow(
            label: 'Verification status',
            value: kycStatus.label,
            trailing: StatusChip(label: kycStatus.label, positive: isVerified),
          ),
        ],
      ),
      Failure(:final message) => Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Gordita',
              color: AppColors.accentRed,
            ),
          ),
          TextButton(onPressed: settings.load, child: const Text('Retry')),
        ],
      ),
      _ => Column(
        children: [
          for (var i = 0; i < 4; i++)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 140, height: 16),
                  SizedBox(height: 8),
                  SkeletonLoader(width: 90, height: 12),
                ],
              ),
            ),
        ],
      ),
    };

    return SettingsPageScaffold(title: 'Account info', body: body);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: palette.title,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: palette.body,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
