import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../widgets/app_scaffold.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/studio/presentation/content_studio_screen.dart';
import '../../features/calendar/presentation/content_calendar_screen.dart';
import '../../features/inbox/presentation/engagement_inbox_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/autopilot/presentation/ai_autopilot_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state changes to trigger router re-evaluation
  ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isConfigured = SupabaseService.isInitialized;
      if (!isConfigured) {
        // If Supabase keys aren't configured yet, allow browsing in zero-state mode
        return null;
      }

      final isLoggedIn = SupabaseService.client?.auth.currentUser != null;
      final isGoingToAuth = state.matchedLocation == '/auth';

      if (!isLoggedIn && !isGoingToAuth) {
        return '/auth';
      }

      if (isLoggedIn && isGoingToAuth) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AuthScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffold(
            location: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/studio',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContentStudioScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContentCalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/inbox',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EngagementInboxScreen(),
            ),
          ),
          GoRoute(
            path: '/accounts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AccountsScreen(),
            ),
          ),
          GoRoute(
            path: '/autopilot',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiAutopilotScreen(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
