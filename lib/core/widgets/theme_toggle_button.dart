import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/app_colors.dart';

class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tooltip = isDark ? 'Switch to light mode' : 'Switch to dark mode';

    if (showLabel) {
      return InkWell(
        onTap: () => ref.read(themeProvider.notifier).toggleTheme(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                  size: 20,
                  color: isDark ? const Color(0xFFFBBF24) : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isDark ? 'Light Mode' : 'Dark Mode',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: () => ref.read(themeProvider.notifier).toggleTheme(context),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            size: 22,
            color: isDark ? const Color(0xFFFBBF24) : AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}
