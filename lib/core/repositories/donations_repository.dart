import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../providers/app_providers.dart';

class DonationsRepository {
  static const String tableName = 'donations';

  /// Converts a database row Map to a Donation domain model
  static Donation fromMap(Map<String, dynamic> map) {
    DonationStatus status;
    switch (map['status']) {
      case 'matched':
        status = DonationStatus.matched;
        break;
      case 'inTransit':
        status = DonationStatus.inTransit;
        break;
      case 'delivered':
        status = DonationStatus.delivered;
        break;
      case 'pending':
      default:
        status = DonationStatus.pending;
    }

    return Donation(
      id: map['id']?.toString() ?? '',
      foodName: map['food_name'] ?? 'Surplus Meal',
      category: map['category'] ?? 'Cooked Meals',
      quantity: map['quantity']?.toString() ?? '1',
      unit: map['unit'] ?? 'kg',
      servings: (map['servings'] as num?)?.toInt() ?? 1,
      condition: map['condition'] ?? 'Freshly Prepared',
      isUrgent: map['is_urgent'] ?? false,
      postedAt: map['posted_at'] != null
          ? DateTime.tryParse(map['posted_at']) ?? DateTime.now()
          : DateTime.now(),
      status: status,
      matchedNgo: map['matched_ngo'],
      riderId: map['rider_id'],
    );
  }

  /// Converts a Donation model to a database row Map
  static Map<String, dynamic> toMap(Donation donation) {
    String statusStr;
    switch (donation.status) {
      case DonationStatus.matched:
        statusStr = 'matched';
        break;
      case DonationStatus.inTransit:
        statusStr = 'inTransit';
        break;
      case DonationStatus.delivered:
        statusStr = 'delivered';
        break;
      case DonationStatus.pending:
        statusStr = 'pending';
        break;
    }

    return {
      'id': donation.id,
      'food_name': donation.foodName,
      'category': donation.category,
      'quantity': donation.quantity,
      'unit': donation.unit,
      'servings': donation.servings,
      'condition': donation.condition,
      'is_urgent': donation.isUrgent,
      'status': statusStr,
      'matched_ngo': donation.matchedNgo,
      'rider_id': donation.riderId,
      'posted_at': donation.postedAt.toIso8601String(),
    };
  }

  /// Fetch all donations from Supabase
  Future<List<Donation>?> fetchDonations() async {
    final client = SupabaseService.client;
    if (client == null) return null;

    try {
      final response = await client
          .from(tableName)
          .select()
          .neq('condition', 'ARCHIVED_TEST')
          .order('posted_at', ascending: false);

      return (response as List).map((row) => fromMap(row)).toList();
    } catch (e) {
      debugPrint('[DonationsRepository] Error fetching donations: $e');
      return null;
    }
  }

  /// Stream live real-time donations
  Stream<List<Donation>>? streamDonations() {
    final client = SupabaseService.client;
    if (client == null) return null;

    try {
      return client
          .from(tableName)
          .stream(primaryKey: ['id'])
          .order('posted_at', ascending: false)
          .map((rows) => rows
              .where((r) => r['condition'] != 'ARCHIVED_TEST')
              .map((r) => fromMap(r))
              .toList());
    } catch (e) {
      debugPrint('[DonationsRepository] Error streaming donations: $e');
      return null;
    }
  }

  /// Insert a new donation into Supabase
  Future<bool> createDonation(Donation donation) async {
    final client = SupabaseService.client;
    if (client == null) return false;

    try {
      await client.from(tableName).insert(toMap(donation));
      return true;
    } catch (e) {
      debugPrint('[DonationsRepository] Error inserting donation: $e');
      return false;
    }
  }

  /// Update donation status and optionally assign NGO / rider
  Future<bool> updateStatus(
    String donationId,
    DonationStatus newStatus, {
    String? matchedNgo,
    String? riderId,
  }) async {
    final client = SupabaseService.client;
    if (client == null) return false;

    String statusStr = 'pending';
    if (newStatus == DonationStatus.matched) statusStr = 'matched';
    if (newStatus == DonationStatus.inTransit) statusStr = 'inTransit';
    if (newStatus == DonationStatus.delivered) statusStr = 'delivered';

    try {
      final payload = <String, dynamic>{'status': statusStr};
      if (matchedNgo != null) payload['matched_ngo'] = matchedNgo;
      if (riderId != null) payload['rider_id'] = riderId;

      await client
          .from(tableName)
          .update(payload)
          .eq('id', donationId);
      return true;
    } catch (e) {
      debugPrint('[DonationsRepository] Error updating status: $e');
      return false;
    }
  }
}
