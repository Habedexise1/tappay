import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../../dashboard/domain/dashboard_models.dart';
import '../../../dashboard/presentation/dashboard_controller.dart';
import '../../domain/settings_models.dart';

class SettingsBeneficiariesScreen extends StatefulWidget {
  const SettingsBeneficiariesScreen({super.key});

  @override
  State<SettingsBeneficiariesScreen> createState() =>
      _SettingsBeneficiariesScreenState();
}

class _SettingsBeneficiariesScreenState
    extends State<SettingsBeneficiariesScreen> {
  BeneficiaryTab _tab = BeneficiaryTab.tapTag;

  @override
  Widget build(BuildContext context) {
    final tapTagBeneficiaries = context
        .select<DashboardController, List<Beneficiary>>((c) => c.beneficiaries);
    final palette = SettingsPalette.of(context);

    final items = switch (_tab) {
      BeneficiaryTab.tapTag => tapTagBeneficiaries,
      BeneficiaryTab.bank => const <Beneficiary>[],
    };

    return SettingsPageScaffold(
      title: 'Beneficiaries',
      scrollable: false,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: _tabButton(BeneficiaryTab.tapTag, 'TapTag')),
              Container(width: 1, height: 28, color: palette.divider),
              Expanded(child: _tabButton(BeneficiaryTab.bank, 'Bank')),
            ],
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: items.isEmpty
                  ? Center(
                      key: ValueKey('empty_${_tab.name}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'You have not saved any accounts to your beneficiary list yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 14,
                            height: 1.45,
                            color: palette.body,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: ValueKey('list_${_tab.name}'),
                      padding: const EdgeInsets.only(top: 20, bottom: 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _BeneficiaryTile(items[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(BeneficiaryTab tab, String label) {
    final palette = SettingsPalette.of(context);
    final selected = _tab == tab;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        key: ValueKey('beneficiary_tab_${tab.name}'),
        onTap: () => setState(() => _tab = tab),
        child: SizedBox(
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? palette.heading : palette.body,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 14 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BeneficiaryTile extends StatelessWidget {
  final Beneficiary beneficiary;

  const _BeneficiaryTile(this.beneficiary);

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.successTint,
            child: Text(
              beneficiary.initials,
              style: const TextStyle(
                fontFamily: 'Gordita',
                fontWeight: FontWeight.w700,
                color: AppColors.successText,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiary.name,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: palette.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  beneficiary.handle,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 12,
                    color: palette.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
