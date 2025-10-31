import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('supportTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.translate('faq1')),
            const SizedBox(height: 8),
            Text(localizations.translate('faq2')),
          ],
        ),
      ),
    );
  }
}
