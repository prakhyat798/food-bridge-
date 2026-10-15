import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/donations_repository.dart';
import '../repositories/ngo_requests_repository.dart';
import '../repositories/rider_jobs_repository.dart';

// ─────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────

enum DonationStatus { pending, matched, inTransit, delivered }

class Donation {
  final String id;
  final String foodName;
  final String category;
  final String quantity;
  final String unit;
  final int servings;
  final String condition;
  final bool isUrgent;
  final DateTime postedAt;
  final DonationStatus status;
  final String? matchedNgo;
  final String? riderId;

  const Donation({
    required this.id,
    required this.foodName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.servings,
    required this.condition,
    required this.isUrgent,
    required this.postedAt,
    required this.status,
    this.matchedNgo,
    this.riderId,
  });

  Donation copyWith({
    String? id,
    String? foodName,
    String? category,
    String? quantity,
    String? unit,
    int? servings,
    String? condition,
    bool? isUrgent,
    DateTime? postedAt,
    DonationStatus? status,
    String? matchedNgo,
    String? riderId,
  }) {
    return Donation(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      servings: servings ?? this.servings,
      condition: condition ?? this.condition,
      isUrgent: isUrgent ?? this.isUrgent,
      postedAt: postedAt ?? this.postedAt,
      status: status ?? this.status,
      matchedNgo: matchedNgo ?? this.matchedNgo,
      riderId: riderId ?? this.riderId,
    );
  }
}

class NgoRequest {
  final String id;
  final String ngoName;
  final String category;
  final int peopleCount;
  final String requiredBy;
  final String urgency;
  final String? notes;
  final String status;
  final double distance;

  const NgoRequest({
    required this.id,
    required this.ngoName,
    required this.category,
    required this.peopleCount,
    required this.requiredBy,
    required this.urgency,
    this.notes,
    required this.status,
    required this.distance,
  });
}

class RiderJob {
  final String id;
  final String foodQuantity;
  final String ngoName;
  final String pickupDistance;
  final String dropDistance;
  final String estTime;
  final bool isUrgent;

  const RiderJob({
    required this.id,
    required this.foodQuantity,
    required this.ngoName,
    required this.pickupDistance,
    required this.dropDistance,
    required this.estTime,
    required this.isUrgent,
  });
}

// ─────────────────────────────────────────────────────────
// User Session & Role Persistence
// ─────────────────────────────────────────────────────────

class UserProfile {
  final String name;
  final String phone;
  final String role; // 'donor', 'ngo', 'rider'
  final bool isLoggedIn;

  const UserProfile({
    this.name = '',
    this.phone = '',
    this.role = '',
    this.isLoggedIn = false,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? role,
    bool? isLoggedIn,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class UserSessionNotifier extends StateNotifier<UserProfile> {
  UserSessionNotifier() : super(const UserProfile()) {
    loadSession();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('user_logged_in') ?? false;
    final role = prefs.getString('user_role') ?? '';
    final name = prefs.getString('user_name') ?? '';
    final phone = prefs.getString('user_phone') ?? '';

    state = UserProfile(
      name: name,
      phone: phone,
      role: role,
      isLoggedIn: isLoggedIn,
    );
  }

  Future<void> login({
    required String name,
    required String phone,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_logged_in', true);
    await prefs.setString('user_name', name);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_role', role);

    state = UserProfile(
      name: name,
      phone: phone,
      role: role,
      isLoggedIn: true,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_logged_in');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_role');

    state = const UserProfile();
  }
}

final userSessionProvider =
    StateNotifierProvider<UserSessionNotifier, UserProfile>(
        (ref) => UserSessionNotifier());

final savedRoleProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_role');
});

final currentRoleProvider = StateProvider<String?>((ref) => null);

Future<void> saveUserSession({
  required String name,
  required String phone,
  required String role,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('user_logged_in', true);
  await prefs.setString('user_name', name);
  await prefs.setString('user_phone', phone);
  await prefs.setString('user_role', role);
}

Future<void> saveRole(String role) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_role', role);
}

Future<void> clearRole() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_logged_in');
  await prefs.remove('user_name');
  await prefs.remove('user_phone');
  await prefs.remove('user_role');
}

// ─────────────────────────────────────────────────────────
// Donor Donations (Hybrid: Local In-Memory + Supabase Sync)
// ─────────────────────────────────────────────────────────

class DonationsNotifier extends StateNotifier<List<Donation>> {
  final DonationsRepository _repository = DonationsRepository();
  StreamSubscription<List<Donation>>? _realtimeSubscription;

  DonationsNotifier() : super(_mockDonations) {
    _initSupabaseSync();
  }

  static final _mockDonations = <Donation>[];

  Future<void> _initSupabaseSync() async {
    // 1. Initial fetch from Supabase if connected
    final remoteDonations = await _repository.fetchDonations();
    if (remoteDonations != null) {
      state = remoteDonations;
    }

    // 2. Realtime subscription
    final stream = _repository.streamDonations();
    if (stream != null) {
      _realtimeSubscription = stream.listen((updatedList) {
        state = updatedList;
      });
    }
  }

  void addDonation(Donation donation) {
    // Optimistically update local state
    state = [donation, ...state];
    // Sync to Supabase
    _repository.createDonation(donation);
  }

  void updateDonationStatus(
    String id,
    DonationStatus status, {
    String? matchedNgo,
    String? riderId,
  }) {
    state = [
      for (final d in state)
        if (d.id == id)
          d.copyWith(
            status: status,
            matchedNgo: matchedNgo ?? d.matchedNgo,
            riderId: riderId ?? d.riderId,
          )
        else
          d,
    ];
    _repository.updateStatus(id, status, matchedNgo: matchedNgo, riderId: riderId);
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}

final donationsProvider =
    StateNotifierProvider<DonationsNotifier, List<Donation>>(
        (ref) => DonationsNotifier());

// ─────────────────────────────────────────────────────────
// NGO Requests (Hybrid: Local In-Memory + Supabase Sync)
// ─────────────────────────────────────────────────────────

class NgoRequestsNotifier extends StateNotifier<List<NgoRequest>> {
  final NgoRequestsRepository _repository = NgoRequestsRepository();
  StreamSubscription<List<NgoRequest>>? _realtimeSubscription;

  NgoRequestsNotifier() : super(_mockRequests) {
    _initSupabaseSync();
  }

  static final _mockRequests = <NgoRequest>[];

  Future<void> _initSupabaseSync() async {
    final remoteRequests = await _repository.fetchRequests();
    if (remoteRequests != null) {
      state = remoteRequests;
    }

    final stream = _repository.streamRequests();
    if (stream != null) {
      _realtimeSubscription = stream.listen((updatedList) {
        state = updatedList;
      });
    }
  }

  void addRequest(NgoRequest request) {
    // Optimistically update local state
    state = [request, ...state];
    // Sync to Supabase
    _repository.createRequest(request);
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}

final ngoRequestsProvider =
    StateNotifierProvider<NgoRequestsNotifier, List<NgoRequest>>(
        (ref) => NgoRequestsNotifier());

// ─────────────────────────────────────────────────────────
// Rider Jobs (Hybrid: Local In-Memory + Supabase Sync)
// ─────────────────────────────────────────────────────────

class RiderJobsNotifier extends StateNotifier<List<RiderJob>> {
  final RiderJobsRepository _repository = RiderJobsRepository();
  StreamSubscription<List<RiderJob>>? _realtimeSubscription;

  RiderJobsNotifier() : super(_mockJobs) {
    _initSupabaseSync();
  }

  static final _mockJobs = <RiderJob>[];

  Future<void> _initSupabaseSync() async {
    final remoteJobs = await _repository.fetchJobs();
    if (remoteJobs != null) {
      state = remoteJobs;
    }

    final stream = _repository.streamJobs();
    if (stream != null) {
      _realtimeSubscription = stream.listen((updatedList) {
        state = updatedList;
      });
    }
  }

  void updateJobStatus(String jobId, String status, {String? riderId}) {
    _repository.updateJobStatus(jobId, status, riderId: riderId);
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}

final riderJobsProvider =
    StateNotifierProvider<RiderJobsNotifier, List<RiderJob>>(
        (ref) => RiderJobsNotifier());

// ─────────────────────────────────────────────────────────
// Rider Stats
// ─────────────────────────────────────────────────────────

class RiderStats {
  final double todayEarnings;
  final int totalDeliveries;
  final double rating;
  final int mealsRescued;

  const RiderStats({
    required this.todayEarnings,
    required this.totalDeliveries,
    required this.rating,
    required this.mealsRescued,
  });
}

final riderStatsProvider = Provider<RiderStats>((ref) => const RiderStats(
      todayEarnings: 0.0,
      totalDeliveries: 0,
      rating: 5.0,
      mealsRescued: 0,
    ));

// ─────────────────────────────────────────────────────────
// Donor Create Donation Wizard Draft State
// ─────────────────────────────────────────────────────────

class DonationDraft {
  final String foodName;
  final String foodType; // Veg / Non-Veg
  final String category;
  final String quantity;
  final String unit;
  final int servings;
  final String condition;
  final double consumptionWindowHours;
  final String pickupPreference;
  final String? imagePath;

  const DonationDraft({
    this.foodName = '',
    this.foodType = 'Veg',
    this.category = 'Cooked Meals',
    this.quantity = '',
    this.unit = 'kg',
    this.servings = 0,
    this.condition = 'Freshly Prepared',
    this.consumptionWindowHours = 4.0,
    this.pickupPreference = 'FoodBridge Rider',
    this.imagePath,
  });

  DonationDraft copyWith({
    String? foodName,
    String? foodType,
    String? category,
    String? quantity,
    String? unit,
    int? servings,
    String? condition,
    double? consumptionWindowHours,
    String? pickupPreference,
    String? imagePath,
  }) {
    return DonationDraft(
      foodName: foodName ?? this.foodName,
      foodType: foodType ?? this.foodType,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      servings: servings ?? this.servings,
      condition: condition ?? this.condition,
      consumptionWindowHours: consumptionWindowHours ?? this.consumptionWindowHours,
      pickupPreference: pickupPreference ?? this.pickupPreference,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class DonationDraftNotifier extends StateNotifier<DonationDraft> {
  DonationDraftNotifier() : super(const DonationDraft());

  void update({
    String? foodName,
    String? foodType,
    String? category,
    String? quantity,
    String? unit,
    int? servings,
    String? condition,
    double? consumptionWindowHours,
    String? pickupPreference,
    String? imagePath,
  }) {
    state = state.copyWith(
      foodName: foodName,
      foodType: foodType,
      category: category,
      quantity: quantity,
      unit: unit,
      servings: servings,
      condition: condition,
      consumptionWindowHours: consumptionWindowHours,
      pickupPreference: pickupPreference,
      imagePath: imagePath,
    );
  }

  void reset() {
    state = const DonationDraft();
  }
}

final donationDraftProvider =
    StateNotifierProvider<DonationDraftNotifier, DonationDraft>(
        (ref) => DonationDraftNotifier());
