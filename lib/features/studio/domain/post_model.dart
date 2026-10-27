class PostModel {
  final String id;
  final String userId;
  final String? accountId;
  final String platform; // 'facebook', 'instagram', 'all'
  final String caption;
  final List<String> mediaUrls;
  final String status; // 'draft', 'scheduled', 'publishing', 'published', 'failed'
  final DateTime? scheduledFor;
  final DateTime? publishedAt;
  final String? metaPostId;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.userId,
    this.accountId,
    required this.platform,
    required this.caption,
    this.mediaUrls = const [],
    this.status = 'draft',
    this.scheduledFor,
    this.publishedAt,
    this.metaPostId,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String?,
      platform: json['platform'] as String? ?? 'instagram',
      caption: json['caption'] as String? ?? '',
      mediaUrls: (json['media_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] as String? ?? 'draft',
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.tryParse(json['scheduled_for'] as String)
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      metaPostId: json['meta_post_id'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      'platform': platform,
      'caption': caption,
      'media_urls': mediaUrls,
      'status': status,
      'scheduled_for': scheduledFor?.toUtc().toIso8601String(),
      if (publishedAt != null) 'published_at': publishedAt!.toUtc().toIso8601String(),
      if (metaPostId != null) 'meta_post_id': metaPostId,
      if (errorMessage != null) 'error_message': errorMessage,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? platform,
    String? caption,
    List<String>? mediaUrls,
    String? status,
    DateTime? scheduledFor,
    DateTime? publishedAt,
    String? metaPostId,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      platform: platform ?? this.platform,
      caption: caption ?? this.caption,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      status: status ?? this.status,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      publishedAt: publishedAt ?? this.publishedAt,
      metaPostId: metaPostId ?? this.metaPostId,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
