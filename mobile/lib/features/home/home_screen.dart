import 'package:flutter/material.dart';

import '../../core/app_router.dart';
import '../../core/localization/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final options = [
      _HomeOption(localizations.translate('medicationListTitle'), AppRouter.medicationListRoute),
      _HomeOption(localizations.translate('remindersTitle'), AppRouter.remindersRoute),
      _HomeOption(localizations.translate('reportsTitle'), AppRouter.reportsRoute),
      _HomeOption(localizations.translate('notificationsTitle'), AppRouter.notificationsRoute),
      _HomeOption(localizations.translate('profileTitle'), AppRouter.profileRoute),
      _HomeOption(localizations.translate('supportTitle'), AppRouter.supportRoute),
      _HomeOption(localizations.translate('settingsTitle'), AppRouter.settingsRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('homeTitle')),
      ),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return ListTile(
            title: Text(option.title),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.of(context).pushNamed(option.route),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRouter.addMedicationRoute),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomeOption {
  _HomeOption(this.title, this.route);

  final String title;
  final String route;
}
