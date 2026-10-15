import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Returns the active SupabaseClient if initialized, otherwise null.
  static SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase connection
  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[SupabaseService] Notice: Supabase URL and Key are not yet configured in lib/core/config/supabase_config.dart. Operating in local/hybrid mock mode.');
      _initialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('[SupabaseService] Successfully connected to Supabase Database!');
    } catch (e) {
      _initialized = false;
      debugPrint('[SupabaseService] Failed to initialize Supabase: $e');
    }
  }
}
