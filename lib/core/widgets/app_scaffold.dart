import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'theme_toggle_button.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String location;

  const AppScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  int _calculateSelectedIndex() {
    if (location.startsWith('/studio')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/inbox')) return 3;
    if (location == '/' || location.isEmpty) return 0;
    return -1; // Secondary routes like /accounts, /analytics, /autopilot, /settings
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/studio');
        break;
      case 2:
        context.go('/calendar');
        break;
      case 3:
        context.go('/inbox');
        break;
      case 4:
        _showMoreMenu(context);
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'More Destinations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const ThemeToggleButton(showLabel: true),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMoreMenuItem(
                  ctx,
                  title: 'Connected Accounts',
                  subtitle: 'Manage Facebook Pages and Instagram accounts',
                  icon: Icons.link_rounded,
                  route: '/accounts',
                ),
                _buildMoreMenuItem(
                  ctx,
                  title: 'AI Autopilot & Safety',
                  subtitle: 'Human-in-the-loop policies and kill switch',
                  icon: Icons.auto_awesome_rounded,
                  route: '/autopilot',
                ),
                _buildMoreMenuItem(
                  ctx,
                  title: 'Analytics & Insights',
                  subtitle: 'Real Meta Graph API audience metrics',
                  icon: Icons.query_stats_rounded,
                  route: '/analytics',
                ),
                _buildMoreMenuItem(
                  ctx,
                  title: 'Settings & Appearance',
                  subtitle: 'Light / Dark theme switch and system settings',
                  icon: Icons.settings_outlined,
                  route: '/settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoreMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = location.startsWith(route);

    return ListTile(
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isSelected
                  ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                  : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary))
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue) : null,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex();
    final isMoreSelected = selectedIndex == -1;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
              onDestinationSelected: (idx) {
                switch (idx) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/studio');
                    break;
                  case 2:
                    context.go('/calendar');
                    break;
                  case 3:
                    context.go('/inbox');
                    break;
                  case 4:
                    context.go('/accounts');
                    break;
                  case 5:
                    context.go('/autopilot');
                    break;
                  case 6:
                    context.go('/analytics');
                    break;
                  case 7:
                    context.go('/settings');
                    break;
                }
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                ),
              ),
              trailing: const Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: ThemeToggleButton(),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.edit_note_outlined),
                  selectedIcon: Icon(Icons.edit_note_rounded),
                  label: Text('Studio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Calendar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum_rounded),
                  label: Text('Inbox'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.link_outlined),
                  selectedIcon: Icon(Icons.link_rounded),
                  label: Text('Accounts'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome_rounded),
                  label: Text('Autopilot'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.query_stats_outlined),
                  selectedIcon: Icon(Icons.query_stats_rounded),
                  label: Text('Analytics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile View
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: isMoreSelected ? 4 : selectedIndex,
        onDestinationSelected: (idx) => _onBottomNavTapped(context, idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note_rounded),
            label: 'Studio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum_rounded),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
