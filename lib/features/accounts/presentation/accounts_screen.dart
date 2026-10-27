import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../studio/data/meta_publishing_service.dart';
import '../data/accounts_repository.dart';
import '../domain/connected_account_model.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _isLoading = false;

  void _showConnectDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1877F2).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.facebook_rounded,
                    color: Color(0xFF1877F2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Connect Facebook Page',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose how you would like to connect your Facebook Page:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Option 1: Automatic OAuth Flow
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await _handleOAuthFlow();
              },
              icon: const Icon(Icons.open_in_browser_rounded),
              label: const Text('Connect via Meta OAuth Flow'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Direct Token Connect (Development & Testing)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showManualTokenDialog();
              },
              icon: const Icon(Icons.key_rounded),
              label: const Text('Developer: Connect with Page Token'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOAuthFlow() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(accountsRepositoryProvider);
      await repo.initiateFacebookOAuth();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OAuth Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showManualTokenDialog() {
    final pageIdController = TextEditingController();
    final pageNameController = TextEditingController();
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connect Page (Manual Token)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste your Facebook Page ID and Page Access Token (from Meta Graph API Explorer or your Page settings):',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pageNameController,
                decoration: const InputDecoration(
                  labelText: 'Page Name',
                  hintText: 'e.g. My Awesome Page',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pageIdController,
                decoration: const InputDecoration(
                  labelText: 'Facebook Page ID',
                  hintText: 'e.g. 104829104859123',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tokenController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Page Access Token (EAAG...)',
                  hintText: 'Paste token here',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = pageNameController.text.trim();
              final id = pageIdController.text.trim();
              final token = tokenController.text.trim();

              if (name.isEmpty || id.isEmpty || token.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              Navigator.pop(ctx);
              setState(() => _isLoading = true);

              try {
                await ref.read(accountsProvider.notifier).saveFacebookPage(
                      pageId: id,
                      pageName: name,
                      pageAccessToken: token,
                    );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connected $name successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving account: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Save & Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _testPublishPost(ConnectedAccountModel account) async {
    final messageController = TextEditingController(
      text: '🚀 Hello from SocialFlow AI! Test post at ${DateTime.now().toLocal()}',
    );

    final shouldPublish = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Test Post to ${account.accountName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will publish a real test post to your Facebook Page right now using Meta Graph API:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Post Message',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Publish Now'),
          ),
        ],
      ),
    );

    if (shouldPublish != true) return;

    setState(() => _isLoading = true);
    final publishingService = ref.read(metaPublishingServiceProvider);

    final result = await publishingService.publishToFacebookPage(
      pageId: account.accountId,
      pageAccessToken: account.accessToken,
      message: messageController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success),
              SizedBox(width: 8),
              Text('Post Published!'),
            ],
          ),
          content: Text(
            'Successfully published to ${account.accountName}!\n\nMeta Post ID:\n${result.postId}',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Great!'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text('Publishing Failed'),
            ],
          ),
          content: Text(
            'Meta returned an error:\n\n${result.errorMessage}\n\nPlease verify that your token has pages_manage_posts permission.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Accounts',
            onPressed: () => ref.read(accountsProvider.notifier).refresh(),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text('Error loading accounts: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(accountsProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (accounts) {
          final facebookAccounts = accounts.where((a) => a.platform == 'facebook').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              Text('Social Channels', style: textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Connect official Meta accounts to publish posts, schedule content, and manage engagement.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // Facebook Page Section
              if (facebookAccounts.isEmpty) ...[
                // Not connected card
                Card(
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
                                color: const Color(0xFF1877F2).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.facebook_rounded,
                                color: Color(0xFF1877F2),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Facebook Pages', style: textTheme.titleMedium),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.lightTextMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text('Not Connected'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _showConnectDialog,
                              child: const Text('Connect'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Publish page updates, schedule posts, and reply to comments on your Facebook Pages.',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Connected Facebook Pages list
                ...facebookAccounts.map(
                  (acc) => Card(
                    margin: const EdgeInsets.only(bottom: 14),
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
                                  color: const Color(0xFF1877F2).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.facebook_rounded,
                                  color: Color(0xFF1877F2),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(acc.accountName, style: textTheme.titleMedium),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.success,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Connected & Active (ID: ${acc.accountId})',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.link_off_rounded, color: AppColors.error),
                                tooltip: 'Disconnect Page',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Disconnect Page?'),
                                      content: Text('Are you sure you want to disconnect ${acc.accountName}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.error,
                                          ),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Disconnect'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await ref.read(accountsProvider.notifier).disconnectAccount(acc.id);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : () => _testPublishPost(acc),
                                icon: const Icon(Icons.send_rounded, size: 16),
                                label: const Text('Test Publish Post'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1877F2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _showConnectDialog,
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Add Another Page'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Instagram Card (Placeholder for now)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1306C).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFFE1306C),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Instagram Professional', style: textTheme.titleMedium),
                            const SizedBox(height: 2),
                            const Text('Connect your linked Instagram Professional account.'),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Instagram Professional accounts link via your Facebook Page.'),
                            ),
                          );
                        },
                        child: const Text('Connect'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Security & Privacy Info Card
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
                          Icons.shield_outlined,
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
                      'Page access tokens are stored in your private Supabase database with Row Level Security. Only you can access or publish through your connected accounts.',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
