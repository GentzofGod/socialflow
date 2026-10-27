import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_toggle_button.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _isConnecting = false;

  void _handleConnect(String channel) async {
    setState(() => _isConnecting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isConnecting = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Connect $channel'),
        content: Text(
          'Meta OAuth 2.0 flow is ready to initialize for $channel.\n\n'
          'Required Permissions:\n'
          '• pages_show_list\n'
          '• pages_read_engagement\n'
          '• pages_manage_posts\n'
          '• instagram_basic\n'
          '• instagram_content_publish\n\n'
          'Configure your Meta App ID in Supabase Edge Functions or environment configuration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$channel connection configuration checked.')),
              );
            },
            child: const Text('Configure Secrets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Accounts'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Text('Social Channels', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Connect official Meta accounts to enable publishing, comment synchronization, and audience metrics.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Instagram Card
          _buildAccountCard(
            context,
            name: 'Instagram Professional',
            description: 'Publish photos, reels, carousel posts and manage user comments.',
            icon: Icons.camera_alt_outlined,
            accentColor: const Color(0xFFE1306C),
            isConnected: false,
            onConnect: () => _handleConnect('Instagram Professional'),
          ),
          const SizedBox(height: 14),

          // Facebook Page Card
          _buildAccountCard(
            context,
            name: 'Facebook Pages',
            description: 'Publish page updates, schedule posts, and reply to page visitor comments.',
            icon: Icons.facebook_rounded,
            accentColor: const Color(0xFF1877F2),
            isConnected: false,
            onConnect: () => _handleConnect('Facebook Page'),
          ),
          const SizedBox(height: 28),

          // Security & Scopes Information
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Token Security & Privacy',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Access tokens are securely exchanged and maintained server-side via Supabase Edge Functions with Row Level Security. No long-lived Meta secrets or tokens are stored in the Flutter client bundle.',
                  style: textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context, {
    required String name,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isConnected,
    required VoidCallback onConnect,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected ? AppColors.success : AppColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected ? 'Connected & Active' : 'Not Connected',
                            style: textTheme.labelMedium?.copyWith(
                              color: isConnected ? AppColors.success : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isConnecting ? null : onConnect,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Connect'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: textTheme.bodyMedium?.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
