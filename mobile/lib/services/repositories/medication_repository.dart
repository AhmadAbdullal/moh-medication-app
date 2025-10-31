import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../database/database_service.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final apiClient = ApiClient();
  final databaseService = ref.watch(databaseServiceProvider);
  return MedicationRepository(apiClient: apiClient, databaseService: databaseService);
});

class MedicationRepository {
  MedicationRepository({
    required this.apiClient,
    required this.databaseService,
  });

  final ApiClient apiClient;
  final DatabaseService databaseService;

  Future<List<Map<String, dynamic>>> fetchMedications() async {
    try {
      final response = await apiClient.get(ApiEndpoints.medications);
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      await _cacheMedications(data.cast<Map<String, dynamic>>());
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      final db = await databaseService.database;
      return db.query('medications');
    }
  }

  Future<void> _cacheMedications(List<Map<String, dynamic>> medications) async {
    final db = await databaseService.database;
    final batch = db.batch();
    for (final medication in medications) {
      batch.insert(
        'medications',
        medication,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
