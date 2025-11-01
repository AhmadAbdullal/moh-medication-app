import 'medication_models.dart';

class ReminderEntry {
  const ReminderEntry({
    required this.id,
    required this.planId,
    required this.medicationName,
    required this.dose,
    required this.patientChannel,
  });

  final String id;
  final String planId;
  final String medicationName;
  final MedicationDose dose;
  final String patientChannel;

  bool get isEscalated => dose.status == DoseStatus.missed;

  bool get isSnoozed => dose.status == DoseStatus.snoozed;
}
