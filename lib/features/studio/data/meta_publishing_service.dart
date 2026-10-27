import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class MetaPublishingResult {
  final bool isSuccess;
  final String? postId;
  final String? errorMessage;

  const MetaPublishingResult({
    required this.isSuccess,
    this.postId,
    this.errorMessage,
  });
}

class MetaPublishingService {
  const MetaPublishingService();

  /// Publish a text or photo post to a Facebook Page via Meta Graph API
  Future<MetaPublishingResult> publishToFacebookPage({
    required String pageId,
    required String pageAccessToken,
    required String message,
    String? imageUrl,
  }) async {
    try {
      final Uri url;
      final Map<String, dynamic> body;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Photo post
        url = Uri.parse('https://graph.facebook.com/v20.0/$pageId/photos');
        body = {
          'url': imageUrl,
          'caption': message,
          'access_token': pageAccessToken,
        };
      } else {
        // Standard feed post
        url = Uri.parse('https://graph.facebook.com/v20.0/$pageId/feed');
        body = {
          'message': message,
          'access_token': pageAccessToken,
        };
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && (decoded.containsKey('id') || decoded.containsKey('post_id'))) {
        final id = (decoded['id'] ?? decoded['post_id']).toString();
        debugPrint('[MetaPublishingService] Published successfully! Post ID: $id');
        return MetaPublishingResult(isSuccess: true, postId: id);
      } else {
        final error = decoded['error'] as Map<String, dynamic>?;
        final errorMsg = error?['message'] ?? 'Meta API error: ${response.statusCode}';
        debugPrint('[MetaPublishingService] Publish failed: $errorMsg');
        return MetaPublishingResult(isSuccess: false, errorMessage: errorMsg);
      }
    } catch (e) {
      debugPrint('[MetaPublishingService] Exception during publishing: $e');
      return MetaPublishingResult(
        isSuccess: false,
        errorMessage: 'Connection error: $e',
      );
    }
  }
}

final metaPublishingServiceProvider = Provider<MetaPublishingService>((ref) {
  return const MetaPublishingService();
});
