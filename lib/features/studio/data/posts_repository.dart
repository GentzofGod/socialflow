import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/post_model.dart';

class PostsRepository {
  final SupabaseClient? _client;

  PostsRepository(this._client);

  bool get isReady => _client != null && _client.auth.currentUser != null;

  String? get currentUserId => _client?.auth.currentUser?.id;

  Future<List<PostModel>> fetchPosts() async {
    if (_client == null || currentUserId == null) return [];

    try {
      final response = await _client
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => PostModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[PostsRepository] Error fetching posts: $e');
      return [];
    }
  }

  Future<List<PostModel>> fetchScheduledPosts() async {
    if (_client == null || currentUserId == null) return [];

    try {
      final response = await _client
          .from('posts')
          .select()
          .eq('status', 'scheduled')
          .order('scheduled_for', ascending: true);

      return (response as List)
          .map((data) => PostModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[PostsRepository] Error fetching scheduled posts: $e');
      return [];
    }
  }

  Future<PostModel?> createPost({
    required String caption,
    required String platform,
    DateTime? scheduledFor,
    String status = 'draft',
    List<String> mediaUrls = const [],
  }) async {
    if (_client == null || currentUserId == null) {
      throw Exception('Must be logged in with Cloud Supabase to save posts.');
    }

    final postData = {
      'user_id': currentUserId,
      'platform': platform.toLowerCase(),
      'caption': caption,
      'media_urls': mediaUrls,
      'status': status,
      'scheduled_for': scheduledFor?.toUtc().toIso8601String(),
    };

    final response = await _client
        .from('posts')
        .insert(postData)
        .select()
        .single();

    return PostModel.fromJson(response);
  }

  Future<PostModel?> updatePost({
    required String id,
    String? caption,
    String? platform,
    String? status,
    DateTime? scheduledFor,
  }) async {
    if (_client == null || currentUserId == null) {
      throw Exception('Must be logged in to update post.');
    }

    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (caption != null) updateData['caption'] = caption;
    if (platform != null) updateData['platform'] = platform.toLowerCase();
    if (status != null) updateData['status'] = status;
    if (scheduledFor != null) {
      updateData['scheduled_for'] = scheduledFor.toUtc().toIso8601String();
    }

    final response = await _client
        .from('posts')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    return PostModel.fromJson(response);
  }

  Future<void> deletePost(String id) async {
    if (_client == null || currentUserId == null) {
      throw Exception('Must be logged in to delete post.');
    }

    await _client.from('posts').delete().eq('id', id);
  }
}

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PostsRepository(client);
});

class PostsNotifier extends AsyncNotifier<List<PostModel>> {
  @override
  Future<List<PostModel>> build() async {
    final repo = ref.watch(postsRepositoryProvider);
    return repo.fetchPosts();
  }

  Future<PostModel?> createPost({
    required String caption,
    required String platform,
    DateTime? scheduledFor,
    String status = 'draft',
  }) async {
    final repo = ref.read(postsRepositoryProvider);
    final newPost = await repo.createPost(
      caption: caption,
      platform: platform,
      scheduledFor: scheduledFor,
      status: status,
    );
    // Refresh post list
    ref.invalidateSelf();
    return newPost;
  }

  Future<void> updatePost({
    required String id,
    String? caption,
    String? platform,
    String? status,
    DateTime? scheduledFor,
  }) async {
    final repo = ref.read(postsRepositoryProvider);
    await repo.updatePost(
      id: id,
      caption: caption,
      platform: platform,
      status: status,
      scheduledFor: scheduledFor,
    );
    ref.invalidateSelf();
  }

  Future<void> deletePost(String id) async {
    final repo = ref.read(postsRepositoryProvider);
    await repo.deletePost(id);
    ref.invalidateSelf();
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<PostModel>>(() {
  return PostsNotifier();
});
