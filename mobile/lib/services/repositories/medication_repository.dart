import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/medication_models.dart';
import '../../core/models/reminder_models.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository();
});

class MedicationRepository {
  MedicationRepository();

  final List<MedicationPlan> _plans = _seedPlans();

  Future<List<MedicationPlan>> fetchMedicationPlans() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _plans.map(_clonePlan).toList(growable: false);
  }

  Future<MedicationPlan?> findPlanById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    try {
      final plan = _plans.firstWhere((plan) => plan.id == id);
      return _clonePlan(plan);
    } catch (_) {
      return null;
    }
  }

  Future<DashboardSummary> buildDashboardSummary(DateTime reference) async {
    final todaysDoses = _plans
        .expand((plan) => plan.doses.map((dose) => (plan: plan, dose: dose)))
        .where((entry) =>
            entry.dose.scheduledAt.year == reference.year &&
            entry.dose.scheduledAt.month == reference.month &&
            entry.dose.scheduledAt.day == reference.day)
        .map((entry) => entry.dose.copyWith())
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
  }

  Future<List<ReminderEntry>> fetchReminderEntries() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final reminders = <ReminderEntry>[];
    for (final plan in _plans) {
      for (final dose in plan.doses) {
        reminders.add(ReminderEntry(
          id: '${plan.id}-${dose.id}',
          planId: plan.id,
          medicationName: plan.displayNameAr,
          dose: dose.copyWith(),
          patientChannel: plan.reminderSetting.channels.first,
        ));
      }
    }
    return reminders;
  }

  Future<void> updateDoseStatus({
    required String planId,
    required String doseId,
    required DoseStatus status,
  }) async {
    final planIndex = _plans.indexWhere((plan) => plan.id == planId);
    if (planIndex == -1) {
      return;
    }
    final plan = _plans[planIndex];
    final doses = plan.doses.map((dose) {
      if (dose.id == doseId) {
        return dose.copyWith(status: status);
      }
      return dose;
    }).toList(growable: false);
    _plans[planIndex] = plan.copyWith(doses: doses);
  }

  MedicationPlan _clonePlan(MedicationPlan plan) {
    final doses = plan.doses
        .map((dose) => dose.copyWith(channels: List<String>.from(dose.channels)))
        .toList(growable: false);
    return plan.copyWith(
      doses: doses,
      reminderSetting: plan.reminderSetting.copyWith(),
      interactionAlerts: List<String>.from(plan.interactionAlerts),
      notes: plan.notes,
    );
  }

  static List<MedicationPlan> _seedPlans() {
    final now = DateTime.now();
    return <MedicationPlan>[
      MedicationPlan(
        id: 'plan-metformin',
        drugCode: 'MET100',
        displayNameAr: 'ميتفورمين',
        displayNameEn: 'Metformin',
        dosageForm: 'أقراص',
        strength: '500mg',
        prescriberName: 'د. مريم الأنصاري',
        startDate: now.subtract(const Duration(days: 30)),
        doses: <MedicationDose>[
          MedicationDose(
            id: 'dose-morning',
            scheduledAt: DateTime(now.year, now.month, now.day, 8, 0),
            instructions: 'خذ حبة بعد الإفطار مع كوب ماء.',
            requiresMeal: true,
            channels: const <String>['push', 'sms'],
            status: DoseStatus.upcoming,
          ),
          MedicationDose(
            id: 'dose-evening',
            scheduledAt: DateTime(now.year, now.month, now.day, 20, 0),
            instructions: 'خذ حبة بعد العشاء.',
            requiresMeal: true,
            channels: const <String>['push', 'sms'],
            status: DoseStatus.upcoming,
          ),
        ],
        reminderSetting: const ReminderSetting(
          channels: <String>['push', 'sms', 'call'],
          snoozeMinutes: 10,
          escalationMinutes: 30,
          escalationContact: 'ابن المريض – عبدالله',
        ),
        interactionAlerts: const <String>[
          'تجنب الجمع مع أدوية اليود قبل استشارة الطبيب.',
          'راقب مستوى السكر بشكل مستمر.',
        ],
        notes:
            'تمت إضافة الوصفة ضمن خطة علاج السكري. المريض وافق على مشاركة البيانات مع الطبيب.',
      ),
      MedicationPlan(
        id: 'plan-losartan',
        drugCode: 'LOS050',
        displayNameAr: 'لوسارتان',
        displayNameEn: 'Losartan',
        dosageForm: 'أقراص',
        strength: '50mg',
        prescriberName: 'د. سالم السالم',
        startDate: now.subtract(const Duration(days: 15)),
        doses: <MedicationDose>[
          MedicationDose(
            id: 'dose-morning',
            scheduledAt: DateTime(now.year, now.month, now.day, 9, 0),
            instructions: 'حبة واحدة صباحاً، يمكن أخذها مع الطعام أو بدونه.',
            requiresMeal: false,
            channels: const <String>['push'],
            status: DoseStatus.taken,
          ),
        ],
        reminderSetting: const ReminderSetting(
          channels: <String>['push', 'email'],
          snoozeMinutes: 15,
          escalationMinutes: 45,
          escalationContact: 'الممرضة المشرفة – خلود',
        ),
        interactionAlerts: const <String>[
          'يرجى تجنب الأدوية المدرة للبول عالية الجرعة بدون استشارة.',
        ],
        notes: 'الطبيب طلب متابعة ضغط الدم يومياً عبر التطبيق.',
      ),
    ];
  }
}
