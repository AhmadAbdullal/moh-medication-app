import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/medication_models.dart';
import '../../../core/models/reminder_models.dart';
import '../../medications/list/medication_list_controller.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final remindersAsync = ref.watch(reminderEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('remindersTitle')),
      ),
      body: remindersAsync.when(
        data: (reminders) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return _ReminderCard(
              reminder: reminder,
              translate: localizations.translate,
              onStatusSelected: (status) => ref
                  .read(medicationPlansProvider.notifier)
                  .updateDoseStatus(
                    planId: reminder.planId,
                    doseId: reminder.dose.id,
                    status: status,
                  ),
              onViewDetail: () => Navigator.of(context).pushNamed(
                AppRouter.reminderDetailRoute,
                arguments: reminder.id,
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

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.translate,
    required this.onStatusSelected,
    required this.onViewDetail,
  });

  final ReminderEntry reminder;
  final String Function(String key) translate;
  final ValueChanged<DoseStatus> onStatusSelected;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(reminder.dose.scheduledAt).format(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reminder.medicationName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${translate('timeField')}: $time'),
                Text('${translate('channelLabel')}: ${reminder.patientChannel}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(reminder.dose.instructions),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: DoseStatus.values.map((status) {
                return ChoiceChip(
                  label: Text(translate(status.localizationKey)),
                  selected: reminder.dose.status == status,
                  onSelected: (_) => onStatusSelected(status),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewDetail,
                child: Text(translate('viewReminderDetail')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
