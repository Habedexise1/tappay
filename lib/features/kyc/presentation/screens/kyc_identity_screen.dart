import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "Identity verification" frames: date of birth, means of ID and a
/// front-view picture of the ID.
class KycIdentityScreen extends StatelessWidget {
  const KycIdentityScreen({super.key});

  static final _dobFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycController>();
    final app = kyc.application;
    const slot = KycDocumentSlot.idFront;
    final dob = app.dateOfBirth;
    final dobError = dob == null ? null : KycRules.validateDateOfBirth(dob);

    Future<void> pickDob() async {
      final picked = await _showDateOfBirthSheet(context, initial: dob);
      if (picked != null) kyc.setDateOfBirth(picked);
    }

    Future<void> pickId() async {
      final picked = await showKycOptionSheet<MeansOfId>(
        context: context,
        title: 'Means of ID',
        options: MeansOfId.values,
        labelOf: (m) => m.label,
        selected: app.meansOfId,
      );
      if (picked != null) kyc.setMeansOfId(picked);
    }

    Future<void> upload() async {
      final origin = await showKycMediaOriginSheet(context, allowFiles: false);
      if (origin != null) await kyc.attach(slot, origin);
    }

    return KycStepScaffold(
      title: 'Identity verification',
      subtitle: 'Please provide the information, let us verify your identity',
      footerHint: dobError != null ? null : kyc.blockerFor(KycStep.identity),
      onContinue: kyc.canContinue(KycStep.identity)
          ? () => KycNavigator.next(context, KycStep.identity)
          : null,
      body: Column(
        children: [
          KycSelectField(
            key: const ValueKey('kyc_dob_field'),
            label: 'Date of birth',
            hint: 'DD/MM/YYYY',
            value: dob == null ? null : _dobFormat.format(dob),
            icon: Icons.calendar_month_outlined,
            errorText: dobError,
            onTap: pickDob,
          ),
          const SizedBox(height: 20),
          KycSelectField(
            key: const ValueKey('kyc_means_of_id_field'),
            label: 'Means of ID',
            value: app.meansOfId?.label,
            onTap: pickId,
          ),
          const SizedBox(height: 20),
          KycUploadBox(
            key: const ValueKey('kyc_id_front_upload'),
            caption: 'Upload a front-view picture of your ID',
            height: 169,
            document: app.idFront,
            state: kyc.attachState(slot),
            onTap: upload,
            onRemove: () => kyc.removeDocument(slot),
          ),
        ],
      ),
    );
  }
}

/// Figma "Date of birth" sheet with a month calendar.
Future<DateTime?> _showDateOfBirthSheet(
  BuildContext context, {
  DateTime? initial,
}) {
  final now = DateTime.now();
  final latest = DateTime(now.year - KycRules.minimumAge, now.month, now.day);
  final first = DateTime(now.year - 120);
  final start = initial ?? DateTime(latest.year - 7, latest.month, 1);

  return showAppBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    title: 'Date of birth',
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: AppColors.primaryGreen,
            onPrimary: AppColors.lightTextPrimary,
          ),
        ),
        child: CalendarDatePicker(
          initialDate: start.isAfter(latest) ? latest : start,
          firstDate: first,
          lastDate: latest,
          initialCalendarMode: initial == null
              ? DatePickerMode.year
              : DatePickerMode.day,
          onDateChanged: (d) => Navigator.of(sheetContext).pop(d),
        ),
      );
    },
  );
}
