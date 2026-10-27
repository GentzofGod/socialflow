import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/data/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Theme Section Header
          Text('Appearance & Theme', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Customize your visual experience. Choose between a crisp light surface or a sleek dark theme.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // 3-Way Clean Theme Switcher
          Row(
            children: [
              Expanded(
                child: _buildThemeOptionCard(
                  context,
                  ref: ref,
                  title: 'Light',
                  mode: ThemeMode.light,
                  isSelected: themeMode == ThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  iconColor: const Color(0xFFD97706),
                  previewBg: AppColors.lightBackground,
                  previewBorder: AppColors.lightBorder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOptionCard(
                  context,
                  ref: ref,
                  title: 'Dark',
                  mode: ThemeMode.dark,
                  isSelected: themeMode == ThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF818CF8),
                  previewBg: AppColors.darkBackground,
                  previewBorder: AppColors.darkBorder,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOptionCard(
                  context,
                  ref: ref,
                  title: 'System',
                  mode: ThemeMode.system,
                  isSelected: themeMode == ThemeMode.system,
                  icon: Icons.brightness_auto_rounded,
                  iconColor: AppColors.primaryBlue,
                  previewBg: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  previewBorder: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // General & Integration Settings
          Text('System Information', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Application Version'),
                  subtitle: const Text('SocialFlow AI v1.0.0 (Phase A)'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('Backend Architecture'),
                  subtitle: Text(
                    SupabaseConfig.isConfigured
                        ? 'Connected to Cloud Supabase: ${SupabaseConfig.supabaseUrl}'
                        : 'Cloud Supabase (Awaiting .env credentials)',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (SupabaseConfig.isConfigured ? AppColors.success : AppColors.warning)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      SupabaseConfig.isConfigured ? 'Active' : 'Zero State',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: SupabaseConfig.isConfigured ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.psychology_outlined),
                  title: const Text('AI Engine Provider'),
                  subtitle: const Text('Meta AI / Llama Server-Side API'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.data_usage_rounded),
                  title: const Text('Data Policy'),
                  subtitle: const Text('Strict Zero-Dummy-Data policy active'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security & Workspace Section
          Text('Workspace Isolation', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_outlined, color: AppColors.success, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client-Side Security', style: textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          'No Meta tokens or AI API keys are bundled or stored in local storage.',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // User Session & Sign Out
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProvider);
              if (user == null) return const SizedBox.shrink();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                            child: const Icon(Icons.person, color: AppColors.primaryBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.email ?? 'Authenticated User',
                                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'UID: ${user.id.substring(0, 8)}...',
                                  style: textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await ref.read(authRepositoryProvider).signOut();
                            },
                            icon: const Icon(Icons.logout_rounded, size: 16),
                            label: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionCard(
    BuildContext context, {
    required WidgetRef ref,
    required String title,
    required ThemeMode mode,
    required bool isSelected,
    required IconData icon,
    required Color iconColor,
    required Color previewBg,
    required Color previewBorder,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primaryBlue : previewBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => ref.read(themeProvider.notifier).setThemeMode(mode),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: previewBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: previewBorder),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryBlue : null,
                ),
              ),
              const SizedBox(height: 6),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
