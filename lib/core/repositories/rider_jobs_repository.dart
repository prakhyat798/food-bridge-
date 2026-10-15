import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../providers/app_providers.dart';

class RiderJobsRepository {
  static const String tableName = 'rider_jobs';

  static RiderJob fromMap(Map<String, dynamic> map) {
    return RiderJob(
      id: map['id']?.toString() ?? '',
      foodQuantity: map['food_quantity'] ?? '30 Meals',
      ngoName: map['ngo_name'] ?? 'Helping Hands Foundation',
      pickupDistance: map['pickup_distance'] ?? '1.5 km',
      dropDistance: map['drop_distance'] ?? '3.5 km',
      estTime: map['est_time'] ?? '20 min',
      isUrgent: map['is_urgent'] ?? false,
    );
  }

  static Map<String, dynamic> toMap(RiderJob job) {
    return {
      'id': job.id,
      'food_quantity': job.foodQuantity,
      'ngo_name': job.ngoName,
      'pickup_distance': job.pickupDistance,
      'drop_distance': job.dropDistance,
      'est_time': job.estTime,
      'is_urgent': job.isUrgent,
    };
  }

  /// Fetch all available rider jobs
  Future<List<RiderJob>?> fetchJobs() async {
    final client = SupabaseService.client;
    if (client == null) return null;

    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('status', 'available')
          .order('created_at', ascending: false);

      return (response as List).map((row) => fromMap(row)).toList();
    } catch (e) {
      debugPrint('[RiderJobsRepository] Error fetching rider jobs: $e');
      return null;
    }
  }

  /// Stream live rider jobs
  Stream<List<RiderJob>>? streamJobs() {
    final client = SupabaseService.client;
    if (client == null) return null;

    try {
      return client
          .from(tableName)
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((rows) => rows
              .where((r) => r['status'] == 'available')
              .map((r) => fromMap(r))
              .toList());
    } catch (e) {
      debugPrint('[RiderJobsRepository] Error streaming rider jobs: $e');
      return null;
    }
  }

  /// Update job status (e.g. accepted, in_transit, delivered)
  Future<bool> updateJobStatus(String jobId, String status, {String? riderId}) async {
    final client = SupabaseService.client;
    if (client == null) return false;

    try {
      final updates = <String, dynamic>{'status': status};
      if (riderId != null) updates['rider_id'] = riderId;

      await client.from(tableName).update(updates).eq('id', jobId);
      return true;
    } catch (e) {
      debugPrint('[RiderJobsRepository] Error updating rider job: $e');
      return false;
    }
  }
}
