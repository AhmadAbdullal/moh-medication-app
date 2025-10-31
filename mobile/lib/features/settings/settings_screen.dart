import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settingsTitle')),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(localizations.translate('languageLabel')),
            subtitle: const Text('العربية / English'),
          ),
          SwitchListTile(
            title: Text(localizations.translate('notificationsToggle')),
            value: true,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}
