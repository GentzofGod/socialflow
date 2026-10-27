import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  SupabaseService._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[SupabaseService] Cloud Supabase keys not set. Running in zero-state mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.currentUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.currentAnonKey,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Successfully connected to Cloud Supabase: ${SupabaseConfig.currentUrl}');
    } catch (e) {
      debugPrint('[SupabaseService] Cloud Supabase init error: $e');
    }
  }

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }
}

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return SupabaseService.client;
});

final isSupabaseConfiguredProvider = Provider<bool>((ref) {
  return SupabaseService.isInitialized;
});
