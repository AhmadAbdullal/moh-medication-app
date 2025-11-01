import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/medication_models.dart';
import '../../medications/list/medication_list_controller.dart';

class ReminderDetailScreen extends ConsumerWidget {
  const ReminderDetailScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final remindersAsync = ref.watch(reminderEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('reminderDetailTitle')),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          final reminder = reminders.firstWhereOrNull((entry) => entry.id == id);
          if (reminder == null) {
            return Center(
              child: Text(localizations.translate('reminderNotFound')),
            );
          }
          final dose = reminder.dose;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                reminder.medicationName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${localizations.translate('timeField')}: '
                '${TimeOfDay.fromDateTime(dose.scheduledAt).format(context)}',
              ),
              Text(
                '${localizations.translate('channelLabel')}: ${reminder.patientChannel}',
              ),
              const SizedBox(height: 12),
              Text(dose.instructions),
              const SizedBox(height: 12),
              Text(
                localizations.translate('statusLabel').replaceFirst(
                      '{status}',
                      localizations.translate(dose.status.localizationKey),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.translate('requiresMealQuestion'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                dose.requiresMeal
                    ? localizations.translate('requiresMealLabel')
                    : localizations.translate('noMealRequiredLabel'),
              ),
              const SizedBox(height: 12),
              Text(localizations.translate('reminderChannelsLabel')),
              Text(dose.channels.join(', ')),
              const SizedBox(height: 24),
              Text(
                localizations.translate('adjustReminderPrompt'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: DoseStatus.values.map((status) {
                  return ChoiceChip(
                    label: Text(localizations.translate(status.localizationKey)),
                    selected: dose.status == status,
                    onSelected: (_) => ref
                        .read(medicationPlansProvider.notifier)
                        .updateDoseStatus(
                          planId: reminder.planId,
                          doseId: reminder.dose.id,
                          status: status,
                        ),
                  );
                }).toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
