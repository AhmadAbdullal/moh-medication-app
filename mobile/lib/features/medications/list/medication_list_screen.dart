import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/medication_models.dart';
import 'medication_list_controller.dart';

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final medicationsAsync = ref.watch(medicationPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('medicationListTitle')),
      ),
      body: medicationsAsync.when(
        data: (plans) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final plan = plans[index];
            final nextDose = plan.nextUpcomingDose(DateTime.now());
            return Card(
              child: ListTile(
                title: Text(plan.displayNameAr),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${localizations.translate('dosageField')}: ${plan.strength}'),
                    Text('${localizations.translate('prescribedByLabel')}: ${plan.prescriberName}'),
                    if (nextDose != null)
                      Text(
                        '${localizations.translate('nextDoseAt')} ${TimeOfDay.fromDateTime(nextDose.scheduledAt).format(context)}',
                      )
                    else
                      Text(localizations.translate('noUpcomingDoses')),
                  ],
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.of(context).pushNamed(
                  AppRouter.medicationDetailRoute,
                  arguments: plan.id,
                ),
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
