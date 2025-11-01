import 'package:collection/collection.dart';

enum DoseStatus { upcoming, taken, missed, snoozed }

extension DoseStatusX on DoseStatus {
  String get localizationKey {
    switch (this) {
      case DoseStatus.upcoming:
        return 'doseUpcoming';
      case DoseStatus.taken:
        return 'doseTaken';
      case DoseStatus.missed:
        return 'doseMissed';
      case DoseStatus.snoozed:
        return 'doseSnoozed';
    }
  }
}

class ReminderSetting {
  const ReminderSetting({
    required this.channels,
    required this.snoozeMinutes,
    required this.escalationMinutes,
    required this.escalationContact,
  });

  final List<String> channels;
  final int snoozeMinutes;
  final int escalationMinutes;
  final String escalationContact;

  ReminderSetting copyWith({
    List<String>? channels,
    int? snoozeMinutes,
    int? escalationMinutes,
    String? escalationContact,
  }) {
    return ReminderSetting(
      channels: channels ?? List<String>.from(this.channels),
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      escalationMinutes: escalationMinutes ?? this.escalationMinutes,
      escalationContact: escalationContact ?? this.escalationContact,
    );
  }
}

class MedicationDose {
  const MedicationDose({
    required this.id,
    required this.scheduledAt,
    required this.instructions,
    required this.requiresMeal,
    required this.channels,
    this.status = DoseStatus.upcoming,
    this.notes,
  });

  final String id;
  final DateTime scheduledAt;
  final String instructions;
  final bool requiresMeal;
  final List<String> channels;
  final DoseStatus status;
  final String? notes;

  MedicationDose copyWith({
    DateTime? scheduledAt,
    String? instructions,
    bool? requiresMeal,
    List<String>? channels,
    DoseStatus? status,
    String? notes,
  }) {
    return MedicationDose(
      id: id,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      instructions: instructions ?? this.instructions,
      requiresMeal: requiresMeal ?? this.requiresMeal,
      channels: channels ?? List<String>.from(this.channels),
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class MedicationPlan {
  const MedicationPlan({
    required this.id,
    required this.drugCode,
    required this.displayNameAr,
    required this.displayNameEn,
    required this.dosageForm,
    required this.strength,
    required this.prescriberName,
    required this.startDate,
    this.endDate,
    required this.doses,
    required this.reminderSetting,
    this.interactionAlerts = const <String>[],
    this.notes,
  });

  final String id;
  final String drugCode;
  final String displayNameAr;
  final String displayNameEn;
  final String dosageForm;
  final String strength;
  final String prescriberName;
  final DateTime startDate;
  final DateTime? endDate;
  final List<MedicationDose> doses;
  final ReminderSetting reminderSetting;
  final List<String> interactionAlerts;
  final String? notes;

  MedicationPlan copyWith({
    List<MedicationDose>? doses,
    ReminderSetting? reminderSetting,
    List<String>? interactionAlerts,
    String? notes,
  }) {
    return MedicationPlan(
      id: id,
      drugCode: drugCode,
      displayNameAr: displayNameAr,
      displayNameEn: displayNameEn,
      dosageForm: dosageForm,
      strength: strength,
      prescriberName: prescriberName,
      startDate: startDate,
      endDate: endDate,
      doses: doses ?? this.doses,
      reminderSetting:
          reminderSetting ?? this.reminderSetting.copyWith(),
      interactionAlerts:
          interactionAlerts ?? List<String>.from(this.interactionAlerts),
      notes: notes ?? this.notes,
    );
  }

  MedicationDose? nextUpcomingDose(DateTime now) {
    return doses
        .where((dose) => dose.status != DoseStatus.taken)
        .sorted((a, b) => a.scheduledAt.compareTo(b.scheduledAt))
        .firstWhereOrNull((dose) => !dose.scheduledAt.isBefore(now));
  }
}

class CaregiverLink {
  const CaregiverLink({
    required this.name,
    required this.role,
    required this.status,
  });

  final String name;
  final String role;
  final String status;
}

class DashboardSummary {
  const DashboardSummary({
    required this.todaysDoses,
    required this.upcomingAppointments,
    required this.caregivers,
  });

  final List<MedicationDose> todaysDoses;
  final List<String> upcomingAppointments;
  final List<CaregiverLink> caregivers;
}
