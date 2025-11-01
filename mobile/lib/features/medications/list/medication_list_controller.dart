import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/medication_models.dart';
import '../../../core/models/reminder_models.dart';
import '../../../services/repositories/medication_repository.dart';

final medicationPlansProvider = StateNotifierProvider<MedicationPlansNotifier,
    AsyncValue<List<MedicationPlan>>>((ref) {
  final repository = ref.read(medicationRepositoryProvider);
  return MedicationPlansNotifier(repository);
});

final medicationPlanProvider = Provider.family<AsyncValue<MedicationPlan?>, String?>(
  (ref, id) {
    final plansState = ref.watch(medicationPlansProvider);
    return plansState.whenData((plans) {
      if (id == null) {
        return null;
      }
      return plans.firstWhereOrNull((plan) => plan.id == id);
    });
  },
);

final reminderEntriesProvider = Provider<AsyncValue<List<ReminderEntry>>>((ref) {
  final plansState = ref.watch(medicationPlansProvider);
  return plansState.whenData((plans) {
    final reminders = <ReminderEntry>[];
    for (final plan in plans) {
      for (final dose in plan.doses) {
        reminders.add(ReminderEntry(
          id: '${plan.id}-${dose.id}',
          planId: plan.id,
          medicationName: plan.displayNameAr,
          dose: dose,
          patientChannel: plan.reminderSetting.channels.first,
        ));
      }
    }
    return reminders;
  });
});

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final plansState = ref.watch(medicationPlansProvider);
  return plansState.whenData((plans) {
    final now = DateTime.now();
    final todaysDoses = plans
        .expand((plan) => plan.doses.where((dose) =>
            dose.scheduledAt.year == now.year &&
            dose.scheduledAt.month == now.month &&
            dose.scheduledAt.day == now.day))
        .toList();
    return DashboardSummary(
      todaysDoses: todaysDoses,
      upcomingAppointments: const <String>[
        'عيادة السكري – 17:00',
        'مراجعة طبيب القلب – الثلاثاء القادم',
      ],
      caregivers: const <CaregiverLink>[
        CaregiverLink(name: 'أحمد العتيبي', role: 'مدير', status: 'نشط'),
        CaregiverLink(name: 'نورة المزيني', role: 'مشاهد', status: 'معلق'),
      ],
    );
  });
});

class MedicationPlansNotifier
    extends StateNotifier<AsyncValue<List<MedicationPlan>>> {
  MedicationPlansNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final MedicationRepository _repository;

  Future<void> _load() async {
    try {
      final plans = await _repository.fetchMedicationPlans();
      state = AsyncValue.data(plans);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }

  Future<void> updateDoseStatus({
    required String planId,
    required String doseId,
    required DoseStatus status,
  }) async {
    await _repository.updateDoseStatus(
      planId: planId,
      doseId: doseId,
      status: status,
    );
    await refresh();
  }
}
