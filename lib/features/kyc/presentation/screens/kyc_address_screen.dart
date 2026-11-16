import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/settings_form_field.dart';
import '../../domain/kyc_models.dart';
import '../kyc_controller.dart';
import '../kyc_navigation.dart';
import '../widgets/kyc_widgets.dart';

/// Figma "Address verification" frame (four address inputs).
class KycAddressScreen extends StatefulWidget {
  const KycAddressScreen({super.key});

  @override
  State<KycAddressScreen> createState() => _KycAddressScreenState();
}

class _KycAddressScreenState extends State<KycAddressScreen> {
  late final TextEditingController _country;
  late final TextEditingController _state;
  late final TextEditingController _city;
  late final TextEditingController _street;

  @override
  void initState() {
    super.initState();
    final a = context.read<KycController>().application.address;
    _country = TextEditingController(text: a.country);
    _state = TextEditingController(text: a.state);
    _city = TextEditingController(text: a.city);
    _street = TextEditingController(text: a.street);
  }

  @override
  void dispose() {
    for (final c in [_country, _state, _city, _street]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycController>();

    Widget field(
      String key,
      String label,
      String hint,
      TextEditingController controller,
      ValueChanged<String> onChanged,
      Iterable<String> autofill, {
      TextInputAction action = TextInputAction.next,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SettingsFormField(
          key: ValueKey('kyc_address_$key'),
          label: label,
          hintText: hint,
          controller: controller,
          textInputAction: action,
          autofillHints: autofill,
          onChanged: onChanged,
        ),
      );
    }

    return KycStepScaffold(
      title: 'Address verification',
      subtitle: 'Please provide the information, let us verify your address',
      footerHint: kyc.blockerFor(KycStep.address),
      onContinue: kyc.canContinue(KycStep.address)
          ? () => KycNavigator.next(context, KycStep.address)
          : null,
      body: AutofillGroup(
        child: Column(
          children: [
            field(
              'country',
              'Country',
              'e.g. United Kingdom',
              _country,
              (v) => kyc.setAddress(country: v),
              const [AutofillHints.countryName],
            ),
            field(
              'state',
              'State / County',
              'e.g. Greater London',
              _state,
              (v) => kyc.setAddress(state: v),
              const [AutofillHints.addressState],
            ),
            field(
              'city',
              'City',
              'e.g. London',
              _city,
              (v) => kyc.setAddress(city: v),
              const [AutofillHints.addressCity],
            ),
            field(
              'street',
              'Street address',
              'House number and street',
              _street,
              (v) => kyc.setAddress(street: v),
              const [AutofillHints.streetAddressLine1],
              action: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
