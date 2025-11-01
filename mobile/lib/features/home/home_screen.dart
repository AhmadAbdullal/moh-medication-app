import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/medication_models.dart';
import '../medications/list/medication_list_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final plansAsync = ref.watch(medicationPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('homeTitle')),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(medicationPlansProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            summaryAsync.when(
              data: (summary) => _DashboardOverview(
                summary: summary,
                translate: localizations.translate,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Text(localizations.translate('errorLoadingDashboard')),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.translate('quickActions'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionChip(
                  icon: Icons.check_circle_outline,
                  label: localizations.translate('logDoseAction'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRouter.remindersRoute),
                ),
                _ActionChip(
                  icon: Icons.local_pharmacy,
                  label: localizations.translate('requestRefillAction'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRouter.medicationListRoute),
                ),
                _ActionChip(
                  icon: Icons.support_agent,
                  label: localizations.translate('contactClinicianAction'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRouter.supportRoute),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              localizations.translate('todayMedicationSchedule'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            plansAsync.when(
              data: (plans) {
                final doses = summaryAsync.maybeWhen(
                  data: (summary) => summary.todaysDoses,
                  orElse: () => <MedicationDose>[],
                );
                if (doses.isEmpty) {
                  return _EmptyState(
                    message: localizations.translate('noDosesScheduled'),
                  );
                }
                return Column(
                  children: doses
                      .map(
                        (dose) => _DoseTile(
                          dose: dose,
                          translate: localizations.translate,
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Text(localizations.translate('errorLoadingMedications')),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context)
                  .pushNamed(AppRouter.medicationListRoute),
              icon: const Icon(Icons.medication),
              label: Text(localizations.translate('viewAllMedications')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .pushNamed(AppRouter.addMedicationRoute),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview({
    required this.summary,
    required this.translate,
  });

  final DashboardSummary summary;
  final String Function(String key) translate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('todayMedicationSchedule'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Column(
              children: summary.todaysDoses
                  .map((dose) => _DoseTile(
                        dose: dose,
                        translate: translate,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              translate('upcomingAppointments'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...summary.upcomingAppointments
                .map((appointment) => ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(appointment),
                    )),
            const SizedBox(height: 16),
            Text(
              translate('careTeam'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...summary.caregivers.map(
              (caregiver) => ListTile(
                leading: const Icon(Icons.people_outline),
                title: Text(caregiver.name),
                subtitle: Text('${caregiver.role} • ${caregiver.status}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoseTile extends StatelessWidget {
  const _DoseTile({
    required this.dose,
    required this.translate,
  });

  final MedicationDose dose;
  final String Function(String key) translate;

  @override
  Widget build(BuildContext context) {
    final statusLabel = translate(dose.status.localizationKey);
    final timeLabel = TimeOfDay.fromDateTime(dose.scheduledAt).format(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.timer_outlined),
      title: Text(timeLabel),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dose.instructions),
          Text(
            statusLabel,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: _statusColor(context, dose.status)),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(translate('reminderChannelsLabel')),
          Text(dose.channels.join(', ')),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return Theme.of(context).colorScheme.primary;
      case DoseStatus.missed:
        return Theme.of(context).colorScheme.error;
      case DoseStatus.snoozed:
        return Theme.of(context).colorScheme.tertiary;
      case DoseStatus.upcoming:
      default:
        return Theme.of(context).hintColor;
    }
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).hintColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
