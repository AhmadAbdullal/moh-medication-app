import 'package:flutter/material.dart';

import '../../../core/app_router.dart';
import '../../../core/localization/app_localizations.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final reminders =
        List.generate(5, (index) => '${localizations.translate('remindersTitle')} #$index');

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('remindersTitle')),
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return ListTile(
            title: Text(reminder),
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.reminderDetailRoute,
              arguments: reminder,
            ),
          );
        },
      ),
    );
  }
}
