import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('reportDetailTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.translate('reportDetailTitle')}: ${id ?? '-'}'),
            const SizedBox(height: 8),
            Text('${localizations.translate('summaryField')}: --'),
            const SizedBox(height: 8),
            Text('${localizations.translate('detailsField')}: --'),
          ],
        ),
      ),
    );
  }
}
