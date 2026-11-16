import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/settings_form_field.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "Identity verification" (details) frame: ID number with issue and
/// expiry dates entered as MM/YY.
class KycIdDetailsScreen extends StatefulWidget {
  const KycIdDetailsScreen({super.key});

  @override
  State<KycIdDetailsScreen> createState() => _KycIdDetailsScreenState();
}

class _KycIdDetailsScreenState extends State<KycIdDetailsScreen> {
  late final TextEditingController _number;
  late final TextEditingController _issue;
  late final TextEditingController _expiry;

  @override
  void initState() {
    super.initState();
    final app = context.read<KycController>().application;
    _number = TextEditingController(text: app.idNumber);
    _issue = TextEditingController(text: app.idIssueDate?.toString() ?? '');
    _expiry = TextEditingController(text: app.idExpiryDate?.toString() ?? '');
  }

  @override
  void dispose() {
    _number.dispose();
    _issue.dispose();
    _expiry.dispose();
    super.dispose();
  }

  /// Only show a field's error once the user has typed something into it.
  String? _shown(String text, String? error) => text.isEmpty ? null : error;

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycController>();
    final app = kyc.application;
    final idLabel = app.meansOfId == null
        ? 'ID number'
        : '${app.meansOfId!.label} number';
    final numberError = _shown(
      _number.text,
      KycRules.validateIdNumber(app.idNumber),
    );
    final issueError = _shown(
      _issue.text,
      KycRules.validateIssueDate(app.idIssueDate),
    );
    final expiryError = _shown(
      _expiry.text,
      KycRules.validateExpiryDate(app.idExpiryDate, issue: app.idIssueDate),
    );
    // Inline errors already explain the problem; avoid repeating them.
    final hasInlineError = [
      numberError,
      issueError,
      expiryError,
    ].any((e) => e != null);

    return KycStepScaffold(
      title: 'Identity verification',
      subtitle: 'Please provide the information, let us verify your identity',
      footerHint: hasInlineError ? null : kyc.blockerFor(KycStep.idDetails),
      onContinue: kyc.canContinue(KycStep.idDetails)
          ? () => KycNavigator.next(context, KycStep.idDetails)
          : null,
      body: Column(
        children: [
          SettingsFormField(
            key: const ValueKey('kyc_id_number_field'),
            label: idLabel,
            hintText: 'Enter your ID number',
            controller: _number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(20),
            ],
            errorText: numberError,
            onChanged: kyc.setIdNumber,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MonthYearField(
                  key: const ValueKey('kyc_issue_date_field'),
                  label: 'Issue date',
                  controller: _issue,
                  errorText: issueError,
                  onChanged: kyc.setIdIssueDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MonthYearField(
                  key: const ValueKey('kyc_expiry_date_field'),
                  label: 'Expiry date',
                  controller: _expiry,
                  errorText: expiryError,
                  onChanged: kyc.setIdExpiryDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthYearField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _MonthYearField({
    super.key,
    required this.label,
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return SettingsFormField(
      label: label,
      hintText: 'MM/YY',
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [_MonthYearFormatter()],
      errorText: errorText,
      onChanged: onChanged,
      suffix: Icon(
        Icons.calendar_month_outlined,
        size: 24,
        color: palette.icon,
      ),
    );
  }
}

/// Keeps input as digits and inserts the slash: `0927` -> `09/27`.
class _MonthYearFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = clipped.length > 2
        ? '${clipped.substring(0, 2)}/${clipped.substring(2)}'
        : clipped;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
