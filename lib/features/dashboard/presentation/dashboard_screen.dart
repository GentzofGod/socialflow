import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../studio/data/posts_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final postsAsync = ref.watch(postsProvider);

    final posts = postsAsync.value ?? [];
    final draftCount = posts.where((p) => p.status == 'draft').length;
    final scheduledCount = posts.where((p) => p.status == 'scheduled').length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('SocialFlow AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Sync Cloud Data',
            onPressed: () => ref.invalidate(postsProvider),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(postsProvider);
          await ref.read(postsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // Welcome Card with Quick Launch Actions
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isDark ? AppColors.subtleDarkGradient : AppColors.subtleLightGradient,
                border: Border.all(
                  color: (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                      .withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Cloud Supabase • Live',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Welcome to SocialFlow AI',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plan, compose AI-assisted captions, schedule releases, and monitor accounts with real Cloud Supabase persistence.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go('/studio'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Create New Post'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/calendar'),
                        icon: const Icon(Icons.calendar_month_outlined, size: 18),
                        label: const Text('View Calendar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Live Interactive Telemetry Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Live Pipeline Telemetry', style: textTheme.titleMedium),
                if (postsAsync.isLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusMetricCard(
                    context,
                    title: 'Saved Drafts',
                    value: '$draftCount',
                    subtitle: draftCount == 0 ? 'No drafts waiting' : '$draftCount drafts in cloud',
                    icon: Icons.article_outlined,
                    color: AppColors.primaryBlue,
                    onTap: () => context.go('/studio'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatusMetricCard(
                    context,
                    title: 'Scheduled Releases',
                    value: '$scheduledCount',
                    subtitle: scheduledCount == 0 ? 'No queued posts' : '$scheduledCount posts scheduled',
                    icon: Icons.schedule_rounded,
                    color: AppColors.warning,
                    onTap: () => context.go('/calendar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildStatusMetricCard(
                    context,
                    title: 'Connected Accounts',
                    value: '0',
                    subtitle: 'Meta channels ready',
                    icon: Icons.account_circle_outlined,
                    color: AppColors.info,
                    onTap: () => context.go('/accounts'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatusMetricCard(
                    context,
                    title: 'AI Autopilot',
                    value: 'Active',
                    subtitle: 'Safety filters engaged',
                    icon: Icons.auto_awesome_outlined,
                    color: AppColors.success,
                    onTap: () => context.go('/autopilot'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Interactive Recent Posts Carousel / Quick Access
            if (posts.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Cloud Posts', style: textTheme.titleMedium),
                  TextButton(
                    onPressed: () => context.go('/studio'),
                    child: const Text('View All in Studio'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: posts.take(5).length,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final post = posts[i];
                    final isScheduled = post.status == 'scheduled';
                    return SizedBox(
                      width: 250,
                      child: Card(
                        child: InkWell(
                          onTap: () => context.go('/studio'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isScheduled ? AppColors.warning : AppColors.primaryBlue)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        post.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isScheduled ? AppColors.warning : AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormat('MMM d').format(post.createdAt.toLocal()),
                                      style: textTheme.labelMedium?.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    post.caption,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Quick Workflow Destinations
            Text('Workspace Navigation', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildQuickActionTile(
              context,
              icon: Icons.calendar_month_outlined,
              title: 'Content Calendar',
              description: 'Manage scheduled releases across a date timeline',
              route: '/calendar',
            ),
            const SizedBox(height: 10),
            _buildQuickActionTile(
              context,
              icon: Icons.forum_outlined,
              title: 'Engagement Inbox',
              description: 'Review audience interactions with AI-suggested replies',
              route: '/inbox',
            ),
            const SizedBox(height: 10),
            _buildQuickActionTile(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings & Appearance',
              description: 'Customize Light / Dark theme and manage user session',
              route: '/settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String route,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: ListTile(
        onTap: () => context.go(route),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(title, style: textTheme.titleMedium),
        subtitle: Text(description, style: textTheme.bodyMedium?.copyWith(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      ),
    );
  }
}
