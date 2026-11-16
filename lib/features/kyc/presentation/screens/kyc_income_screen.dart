import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "Income infos" frames (income band + bank statement).
class KycIncomeScreen extends StatelessWidget {
  const KycIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycController>();
    final app = kyc.application;
    const slot = KycDocumentSlot.bankStatement;

    Future<void> pickBand() async {
      final picked = await showKycOptionSheet<IncomeBand>(
        context: context,
        title: 'Income band',
        options: IncomeBand.values,
        labelOf: (b) => b.label,
        selected: app.incomeBand,
      );
      if (picked != null) kyc.setIncomeBand(picked);
    }

    Future<void> upload() async {
      final origin = await showKycMediaOriginSheet(context);
      if (origin != null) await kyc.attach(slot, origin);
    }

    return KycStepScaffold(
      title: 'Income verification',
      subtitle:
          'Please provide the information, let us help you manage your finances better',
      footerHint: kyc.blockerFor(KycStep.income),
      onContinue: kyc.canContinue(KycStep.income)
          ? () => KycNavigator.next(context, KycStep.income)
          : null,
      body: Column(
        children: [
          KycSelectField(
            key: const ValueKey('kyc_income_band_field'),
            label: 'Income band',
            value: app.incomeBand?.label,
            onTap: pickBand,
          ),
          const SizedBox(height: 20),
          KycUploadBox(
            key: const ValueKey('kyc_bank_statement_upload'),
            label: 'Bank statement',
            caption: 'Last 3 months statement, PDF or image, max 10 MB',
            height: 268,
            document: app.bankStatement,
            state: kyc.attachState(slot),
            onTap: upload,
            onRemove: () => kyc.removeDocument(slot),
          ),
        ],
      ),
    );
  }
}
