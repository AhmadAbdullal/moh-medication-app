import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('profileTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.translate('nameLabel')}: ---'),
            const SizedBox(height: 8),
            Text('${localizations.translate('emailLabel')}: ---'),
          ],
        ),
      ),
    );
  }
}
