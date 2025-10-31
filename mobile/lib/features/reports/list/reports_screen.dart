import 'package:flutter/material.dart';

import '../../../core/app_router.dart';
import '../../../core/localization/app_localizations.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final reports =
        List.generate(3, (index) => '${localizations.translate('reportsTitle')} #$index');

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('reportsTitle')),
      ),
      body: ListView.separated(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return ListTile(
            title: Text(report),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.reportDetailRoute,
              arguments: report,
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
      ),
    );
  }
}
