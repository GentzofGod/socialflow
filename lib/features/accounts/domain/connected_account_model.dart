class ConnectedAccountModel {
  final String id;
  final String userId;
  final String platform; // 'facebook' or 'instagram'
  final String accountId; // Page ID or IG Business ID
  final String accountName;
  final String? username;
  final String? profilePictureUrl;
  final String accessToken;
  final DateTime? tokenExpiresAt;
  final Map<String, dynamic> capabilities;
  final bool isActive;
  final DateTime createdAt;

  const ConnectedAccountModel({
    required this.id,
    required this.userId,
    required this.platform,
    required this.accountId,
    required this.accountName,
    this.username,
    this.profilePictureUrl,
    required this.accessToken,
    this.tokenExpiresAt,
    this.capabilities = const {
      'publish_post': true,
      'read_insights': true,
      'manage_comments': true,
    },
    this.isActive = true,
    required this.createdAt,
  });

  factory ConnectedAccountModel.fromJson(Map<String, dynamic> json) {
    return ConnectedAccountModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      platform: json['platform'] as String? ?? 'facebook',
      accountId: json['account_id'] as String? ?? '',
      accountName: json['account_name'] as String? ?? 'Unknown Account',
      username: json['username'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      accessToken: json['access_token'] as String? ?? '',
      tokenExpiresAt: json['token_expires_at'] != null
          ? DateTime.tryParse(json['token_expires_at'] as String)
          : null,
      capabilities: (json['capabilities'] as Map<String, dynamic>?) ??
          const {
            'publish_post': true,
            'read_insights': true,
            'manage_comments': true,
          },
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'platform': platform,
      'account_id': accountId,
      'account_name': accountName,
      'username': username,
      'profile_picture_url': profilePictureUrl,
      'access_token': accessToken,
      'token_expires_at': tokenExpiresAt?.toIso8601String(),
      'capabilities': capabilities,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
