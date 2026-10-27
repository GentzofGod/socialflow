import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/connected_account_model.dart';

class AccountsRepository {
  final SupabaseClient? _client;

  AccountsRepository(this._client);

  bool get isReady => _client != null && _client.auth.currentUser != null;
  String? get currentUserId => _client?.auth.currentUser?.id;

  /// Fetch all connected accounts for the current user from Supabase
  Future<List<ConnectedAccountModel>> fetchAccounts() async {
    if (_client == null || currentUserId == null) return [];

    try {
      final response = await _client
          .from('connected_accounts')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => ConnectedAccountModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[AccountsRepository] Error fetching accounts: $e');
      return [];
    }
  }

  /// Launch Facebook OAuth flow requesting page management permissions
  Future<bool> initiateFacebookOAuth() async {
    if (_client == null) {
      throw Exception('Supabase is not configured yet. Check your .env credentials.');
    }

    return await _client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      scopes: 'email,public_profile,pages_show_list,pages_manage_posts,pages_read_engagement',
      redirectTo: kIsWeb ? null : 'socialflow://auth-callback',
    );
  }

  /// Fetch Facebook Pages administered by the user via Meta Graph API
  Future<List<Map<String, dynamic>>> fetchFacebookPages(String userAccessToken) async {
    final url = Uri.parse(
      'https://graph.facebook.com/v20.0/me/accounts?fields=id,name,category,access_token,picture&access_token=$userAccessToken',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error']?['message'] ?? 'Failed to fetch Facebook Pages.');
    }

    final decoded = jsonDecode(response.body);
    final data = decoded['data'] as List? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  /// Save a Facebook Page and its Page Access Token to Supabase
  Future<ConnectedAccountModel> saveFacebookPage({
    required String pageId,
    required String pageName,
    required String pageAccessToken,
    String? profilePictureUrl,
  }) async {
    if (_client == null || currentUserId == null) {
      throw Exception('You must be signed in to save connected accounts.');
    }

    final payload = {
      'user_id': currentUserId,
      'platform': 'facebook',
      'account_id': pageId,
      'account_name': pageName,
      'access_token': pageAccessToken,
      'profile_picture_url': profilePictureUrl,
      'capabilities': {
        'publish_post': true,
        'read_insights': true,
        'manage_comments': true,
      },
      'is_active': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _client
        .from('connected_accounts')
        .upsert(
          payload,
          onConflict: 'user_id,platform,account_id',
        )
        .select()
        .single();

    return ConnectedAccountModel.fromJson(response);
  }

  /// Disconnect / Delete an account
  Future<void> disconnectAccount(String id) async {
    if (_client == null || currentUserId == null) return;
    await _client.from('connected_accounts').delete().eq('id', id);
  }
}

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AccountsRepository(client);
});

class AccountsNotifier extends AsyncNotifier<List<ConnectedAccountModel>> {
  @override
  Future<List<ConnectedAccountModel>> build() async {
    final repo = ref.watch(accountsRepositoryProvider);
    return repo.fetchAccounts();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> saveFacebookPage({
    required String pageId,
    required String pageName,
    required String pageAccessToken,
    String? profilePictureUrl,
  }) async {
    final repo = ref.read(accountsRepositoryProvider);
    await repo.saveFacebookPage(
      pageId: pageId,
      pageName: pageName,
      pageAccessToken: pageAccessToken,
      profilePictureUrl: profilePictureUrl,
    );
    ref.invalidateSelf();
  }

  Future<void> disconnectAccount(String id) async {
    final repo = ref.read(accountsRepositoryProvider);
    await repo.disconnectAccount(id);
    ref.invalidateSelf();
  }
}

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<ConnectedAccountModel>>(() {
  return AccountsNotifier();
});
