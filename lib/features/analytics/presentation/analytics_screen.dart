import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/theme_toggle_button.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Banner explaining authentic metrics policy
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SocialFlow strictly displays verified live metrics from Meta Graph API. No fabricated or simulated numbers are generated.',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Zero-State Analytics View
          EmptyStateView(
            icon: Icons.query_stats_rounded,
            title: 'No Audience Metrics Yet',
            description:
                'Link your Facebook Page or Instagram Professional account to automatically aggregate reach, post engagement, follower growth, and impression graphs.',
            actionLabel: 'Connect Accounts',
            onAction: () => context.go('/accounts'),
            extraContent: Column(
              children: [
                _buildInsightPill(
                  context,
                  icon: Icons.auto_graph_rounded,
                  title: 'Page Impressions & Reach',
                ),
                const SizedBox(height: 8),
                _buildInsightPill(
                  context,
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Content Interaction Rates',
                ),
                const SizedBox(height: 8),
                _buildInsightPill(
                  context,
                  icon: Icons.people_outline_rounded,
                  title: 'Demographics & Active Hours',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightPill(BuildContext context, {required IconData icon, required String title}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
