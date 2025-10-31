import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class MedicationDetailScreen extends StatelessWidget {
  const MedicationDetailScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('medicationDetailTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.translate('medicationDetailTitle')}: ${id ?? '-'}'),
            const SizedBox(height: 8),
            Text('${localizations.translate('dosageField')}: --'),
            const SizedBox(height: 8),
            Text('${localizations.translate('scheduleField')}: --'),
          ],
        ),
      ),
    );
  }
}
