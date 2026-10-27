import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient? _client;

  AuthRepository(this._client);

  bool get isConfigured => _client != null;

  User? get currentUser => _client?.auth.currentUser;

  Session? get currentSession => _client?.auth.currentSession;

  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  Future<AuthResponse?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      throw Exception('Supabase is not configured. Check your .env file.');
    }
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (_client == null) {
      throw Exception('Supabase is not configured. Check your .env file.');
    }
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  Future<void> signInWithOtp({required String email}) async {
    if (_client == null) {
      throw Exception('Supabase is not configured. Check your .env file.');
    }
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'socialflow://auth-callback',
    );
  }

  Future<bool> signInWithFacebook() async {
    if (_client == null) {
      throw Exception('Supabase is not configured. Check your .env file.');
    }
    return await _client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      scopes: 'email,public_profile,pages_show_list,pages_manage_posts,pages_read_engagement',
      redirectTo: kIsWeb ? null : 'socialflow://auth-callback',
    );
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

final authStateProvider = StreamProvider<AuthState?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges ?? const Stream.empty();
});

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  final repo = ref.watch(authRepositoryProvider);
  return repo.currentUser;
});
