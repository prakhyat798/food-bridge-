import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../providers/app_providers.dart';

class NgoRequestsRepository {
  static const String tableName = 'ngo_requests';

  static NgoRequest fromMap(Map<String, dynamic> map) {
    return NgoRequest(
      id: map['id']?.toString() ?? '',
      ngoName: map['ngo_name'] ?? 'Helping Hands Foundation',
      category: map['category'] ?? 'Cooked Meals',
      peopleCount: (map['people_count'] as num?)?.toInt() ?? 50,
      requiredBy: map['required_by'] ?? 'Today',
      urgency: map['urgency'] ?? 'Normal',
      notes: map['notes'],
      status: map['status'] ?? 'open',
      distance: (map['distance'] as num?)?.toDouble() ?? 1.5,
    );
  }

  static Map<String, dynamic> toMap(NgoRequest request) {
    return {
      'id': request.id,
      'ngo_name': request.ngoName,
      'category': request.category,
      'people_count': request.peopleCount,
      'required_by': request.requiredBy,
      'urgency': request.urgency,
      'notes': request.notes,
      'status': request.status,
      'distance': request.distance,
    };
  }

  /// Fetch all requests from Supabase
  Future<List<NgoRequest>?> fetchRequests() async {
    final client = SupabaseService.client;
    if (client == null) return null;

    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('status', 'open')
          .order('created_at', ascending: false);

      return (response as List).map((row) => fromMap(row)).toList();
    } catch (e) {
      debugPrint('[NgoRequestsRepository] Error fetching requests: $e');
      return null;
    }
  }

  /// Stream real-time requests from Supabase
  Stream<List<NgoRequest>>? streamRequests() {
    final client = SupabaseService.client;
    if (client == null) return null;

    try {
      return client
          .from(tableName)
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((rows) => rows
              .where((r) => r['status'] == 'open')
              .map((r) => fromMap(r))
              .toList());
    } catch (e) {
      debugPrint('[NgoRequestsRepository] Error streaming requests: $e');
      return null;
    }
  }

  /// Insert a new food request into Supabase
  Future<bool> createRequest(NgoRequest request) async {
    final client = SupabaseService.client;
    if (client == null) return false;

    try {
      await client.from(tableName).insert(toMap(request));
      return true;
    } catch (e) {
      debugPrint('[NgoRequestsRepository] Error inserting request: $e');
      return false;
    }
  }
}
