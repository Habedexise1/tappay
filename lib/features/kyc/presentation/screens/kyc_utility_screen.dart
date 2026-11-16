import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "Utility verification" frame.
class KycUtilityScreen extends StatelessWidget {
  const KycUtilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycController>();
    const slot = KycDocumentSlot.utilityBill;

    Future<void> upload() async {
      final origin = await showKycMediaOriginSheet(context);
      if (origin != null) await kyc.attach(slot, origin);
    }

    return KycStepScaffold(
      title: 'Utility verification',
      subtitle:
          'Please provide electricity bills, water bills or any detailed invoice showing the usage of a service.',
      footerHint: kyc.blockerFor(KycStep.utility),
      onContinue: kyc.canContinue(KycStep.utility)
          ? () => KycNavigator.next(context, KycStep.utility)
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) => KycUploadBox(
          key: const ValueKey('kyc_utility_upload'),
          caption: 'Upload a clear recent receipt of a utility bill',
          // Square drop zone as in Figma, capped on tablets.
          height: constraints.maxWidth.clamp(0, 400).toDouble(),
          document: kyc.application.utilityBill,
          state: kyc.attachState(slot),
          onTap: upload,
          onRemove: () => kyc.removeDocument(slot),
        ),
      ),
    );
  }
}
