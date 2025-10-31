import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/repositories/medication_repository.dart';

final medicationListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(medicationRepositoryProvider);
  return repository.fetchMedications();
});
