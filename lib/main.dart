import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/scheduler/presentation/scheduler_screen.dart';
import 'features/studio/presentation/omniflow_studio_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OmniFlowApp());
}

class OmniFlowApp extends StatefulWidget {
  const OmniFlowApp({super.key});

  @override
  State<OmniFlowApp> createState() => _OmniFlowAppState();
}

class _OmniFlowAppState extends State<OmniFlowApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniFlow AI — Content Repurposing Studio',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MainShellScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const MainShellScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    OmniFlowStudioScreen(),
    SchedulerScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt_rounded),
            label: 'Studio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Library',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: widget.onToggleTheme,
        tooltip: 'Toggle Theme',
        child: Icon(
          widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        ),
      ),
    );
  }
}
