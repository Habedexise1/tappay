import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_assets.dart';
import '../../../../core/widgets/settings_page_scaffold.dart';
import '../../domain/settings_models.dart';
import '../settings_controller.dart';
import '../widgets/settings_widgets.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final prefs = settings.notifications;

    Widget toggle(NotificationChannel channel, String svgAsset, String label) {
      return SettingsSwitchCard(
        key: ValueKey('notification_${channel.name}'),
        svgAsset: svgAsset,
        label: label,
        value: prefs.isEnabled(channel),
        onChanged: (on) => settings.setNotification(channel, on),
      );
    }

    return SettingsPageScaffold(
      title: 'Notifications',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsGroupLabel('Login'),
          toggle(
            NotificationChannel.loginEmail,
            AppAssets.iconNotificationStatus,
            'Email',
          ),
          const SizedBox(height: 20),
          const SettingsGroupLabel('Transactions'),
          toggle(
            NotificationChannel.transactionEmail,
            AppAssets.iconNotificationStatus,
            'Email',
          ),
          const SizedBox(height: 20),
          toggle(
            NotificationChannel.transactionPush,
            AppAssets.iconNotification,
            'Push',
          ),
        ],
      ),
    );
  }
}
