import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/settings_form_field.dart';
import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "What do you do" frame.
class KycEmploymentScreen extends StatefulWidget {
  const KycEmploymentScreen({super.key});

  @override
  State<KycEmploymentScreen> createState() => _KycEmploymentScreenState();
}

class _KycEmploymentScreenState extends State<KycEmploymentScreen> {
  late final TextEditingController _occupation;

  @override
  void initState() {
    super.initState();
    _occupation = TextEditingController(
      text: context.read<KycController>().application.occupation,
    );
  }

  @override
  void dispose() {
    _occupation.dispose();
    super.dispose();
  }

  Future<void> _pickStatus() async {
    final kyc = context.read<KycController>();
    final picked = await showKycOptionSheet<EmploymentStatus>(
      context: context,
      title: 'Employment status',
      options: EmploymentStatus.values,
      labelOf: (s) => s.label,
      selected: kyc.application.employmentStatus,
    );
    if (picked != null) kyc.setEmploymentStatus(picked);
  }

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycController>();
    final app = kyc.application;

    return KycStepScaffold(
      title: 'What do you do?',
      subtitle: 'Provide your employment information below',
      footerHint: kyc.blockerFor(KycStep.employment),
      onContinue: kyc.canContinue(KycStep.employment)
          ? () => KycNavigator.next(context, KycStep.employment)
          : null,
      body: Column(
        children: [
          KycSelectField(
            key: const ValueKey('kyc_employment_field'),
            label: 'Employment status',
            value: app.employmentStatus?.label,
            onTap: _pickStatus,
          ),
          const SizedBox(height: 20),
          SettingsFormField(
            key: const ValueKey('kyc_occupation_field'),
            label: 'Occupation',
            hintText: 'e.g. Software engineer',
            controller: _occupation,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.jobTitle],
            onChanged: kyc.setOccupation,
          ),
        ],
      ),
    );
  }
}
