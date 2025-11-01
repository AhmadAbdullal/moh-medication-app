import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/medication_models.dart';
import '../list/medication_list_controller.dart';

class MedicationDetailScreen extends ConsumerWidget {
  const MedicationDetailScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final planAsync = ref.watch(medicationPlanProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('medicationDetailTitle')),
      ),
      body: planAsync.when(
        data: (plan) {
          if (plan == null) {
            return Center(
              child: Text(localizations.translate('medicationNotFound')),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                plan.displayNameAr,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('${localizations.translate('dosageField')}: ${plan.strength}'),
              Text('${localizations.translate('dosageFormLabel')}: ${plan.dosageForm}'),
              Text('${localizations.translate('prescribedByLabel')}: ${plan.prescriberName}'),
              const SizedBox(height: 16),
              Text(
                localizations.translate('medicationScheduleHeader'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...plan.doses.map((dose) => _DoseCard(
                    dose: dose,
                    translate: localizations.translate,
                    onStatusChanged: (status) => ref
                        .read(medicationPlansProvider.notifier)
                        .updateDoseStatus(
                          planId: plan.id,
                          doseId: dose.id,
                          status: status,
                        ),
                  )),
              const SizedBox(height: 16),
              Text(
                localizations.translate('reminderPreferencesHeader'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: Text(plan.reminderSetting.channels.join(', ')),
                  subtitle: Text(
                    localizations.translate('reminderEscalationLabel').replaceFirst(
                          '{minutes}',
                          plan.reminderSetting.escalationMinutes.toString(),
                        ),
                  ),
                  trailing: Text(
                    localizations.translate('snoozeLabel').replaceFirst(
                          '{minutes}',
                          plan.reminderSetting.snoozeMinutes.toString(),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (plan.interactionAlerts.isNotEmpty) ...[
                Text(
                  localizations.translate('interactionAlertsHeader'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...plan.interactionAlerts.map(
                  (alert) => ListTile(
                    leading: const Icon(Icons.warning_amber_outlined),
                    title: Text(alert),
                  ),
                ),
              ],
              if (plan.notes != null) ...[
                const SizedBox(height: 16),
                Text(
                  localizations.translate('careTeamNotesHeader'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(plan.notes!),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _DoseCard extends StatelessWidget {
  const _DoseCard({
    required this.dose,
    required this.translate,
    required this.onStatusChanged,
  });

  final MedicationDose dose;
  final String Function(String key) translate;
  final ValueChanged<DoseStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final timeLabel = TimeOfDay.fromDateTime(dose.scheduledAt).format(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(timeLabel, style: Theme.of(context).textTheme.titleMedium),
                Chip(
                  label: Text(translate(dose.status.localizationKey)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(dose.instructions),
            const SizedBox(height: 8),
            Text(
              dose.requiresMeal
                  ? translate('requiresMealLabel')
                  : translate('noMealRequiredLabel'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: DoseStatus.values.map((status) {
                return ChoiceChip(
                  label: Text(translate(status.localizationKey)),
                  selected: dose.status == status,
                  onSelected: (_) => onStatusChanged(status),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
