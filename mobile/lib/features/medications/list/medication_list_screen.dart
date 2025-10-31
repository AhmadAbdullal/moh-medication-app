import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import 'medication_list_controller.dart';

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final medicationsAsync = ref.watch(medicationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('medicationListTitle')),
      ),
      body: medicationsAsync.when(
        data: (medications) => ListView.builder(
          itemCount: medications.length,
          itemBuilder: (context, index) {
            final medication = medications[index];
            return ListTile(
              title: Text(medication['name']?.toString() ?? '---'),
              subtitle: Text(medication['dosage']?.toString() ?? ''),
              onTap: () => Navigator.of(context).pushNamed(
                AppRouter.medicationDetailRoute,
                arguments: medication['id']?.toString(),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
