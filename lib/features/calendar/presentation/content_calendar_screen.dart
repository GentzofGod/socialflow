import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../studio/data/posts_repository.dart';
import '../../studio/domain/post_model.dart';

class ContentCalendarScreen extends ConsumerStatefulWidget {
  const ContentCalendarScreen({super.key});

  @override
  ConsumerState<ContentCalendarScreen> createState() => _ContentCalendarScreenState();
}

class _ContentCalendarScreenState extends ConsumerState<ContentCalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month, 1);
      _selectedDate = now;
    });
  }

  List<DateTime> _buildMonthDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // In Dart weekday: Mon=1, Sun=7.
    // Let's use Mon as first column (offset = weekday - 1)
    final startingWeekdayOffset = firstDayOfMonth.weekday - 1;

    final days = <DateTime>[];

    // Previous month padding days
    for (int i = startingWeekdayOffset; i > 0; i--) {
      days.add(firstDayOfMonth.subtract(Duration(days: i)));
    }

    // Current month days
    for (int i = 0; i < daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    // Next month padding days to complete 7-day grid rows
    final remainingDays = (7 - (days.length % 7)) % 7;
    final lastDayOfMonth = DateTime(month.year, month.month, daysInMonth);
    for (int i = 1; i <= remainingDays; i++) {
      days.add(lastDayOfMonth.add(Duration(days: i)));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final postsAsync = ref.watch(postsProvider);
    final posts = postsAsync.value ?? [];

    final monthDays = _buildMonthDays(_currentMonth);

    // Filter posts for currently selected day
    final matchingPosts = posts.where((p) {
      final targetDate = p.scheduledFor ?? p.createdAt;
      return _isSameDay(targetDate.toLocal(), _selectedDate);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, size: 20),
            tooltip: 'Jump to Today',
            onPressed: _jumpToToday,
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Monthly Navigation & Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    tooltip: 'Previous Month',
                    onPressed: _previousMonth,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMMM yyyy').format(_currentMonth),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 24),
                    tooltip: 'Next Month',
                    onPressed: _nextMonth,
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _currentMonth = DateTime(picked.year, picked.month, 1);
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_month_outlined, size: 16),
                    label: const Text('Jump to Date'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Monthly Grid Card Container
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Weekday Labels Row
                    Row(
                      children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'].map((day) {
                        return Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 12),

                    // Monthly 7-Column Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: monthDays.length,
                      itemBuilder: (context, index) {
                        final date = monthDays[index];
                        final isCurrentMonth = date.month == _currentMonth.month;
                        final isSelected = _isSameDay(date, _selectedDate);
                        final isToday = _isSameDay(date, DateTime.now());

                        // Count posts for this day
                        final postsOnDay = posts.where((p) {
                          final target = p.scheduledFor ?? p.createdAt;
                          return _isSameDay(target.toLocal(), date);
                        }).length;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                              if (date.month != _currentMonth.month) {
                                _currentMonth = DateTime(date.year, date.month, 1);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                                  : (isToday
                                      ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                                          .withValues(alpha: 0.12)
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                                    : (isToday
                                        ? AppColors.accentPurple
                                        : Colors.transparent),
                                width: isSelected || isToday ? 1.5 : 0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected || isToday
                                        ? FontWeight.w700
                                        : (isCurrentMonth ? FontWeight.w500 : FontWeight.w300),
                                    color: isSelected
                                        ? Colors.white
                                        : (!isCurrentMonth
                                            ? (isDark
                                                ? AppColors.darkTextMuted.withValues(alpha: 0.4)
                                                : AppColors.lightTextMuted)
                                            : (isToday
                                                ? (isDark
                                                    ? AppColors.primaryBlueDark
                                                    : AppColors.primaryBlue)
                                                : null)),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                if (postsOnDay > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : AppColors.warning,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$postsOnDay',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? AppColors.primaryBlue : Colors.white,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selected Day Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.event_note_rounded,
                          size: 18,
                          color: isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('EEEE, MMMM d').format(_selectedDate),
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${matchingPosts.length} scheduled',
                      style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Posts Feed or Authentic Empty State
          if (matchingPosts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 40),
                child: EmptyStateView(
                  icon: Icons.event_busy_outlined,
                  title: 'No Releases on ${DateFormat('MMM d').format(_selectedDate)}',
                  description:
                      'Tap any date with an indicator on the monthly calendar above or schedule a new post for this date.',
                  actionLabel: 'Schedule Post for ${DateFormat('MMM d').format(_selectedDate)}',
                  onAction: () => context.go('/studio'),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = matchingPosts[index];
                    return _buildPostCard(context, post: post);
                  },
                  childCount: matchingPosts.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/studio'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Post'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, {required PostModel post}) {
    final textTheme = Theme.of(context).textTheme;
    final isScheduled = post.status == 'scheduled';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isScheduled ? AppColors.warning : AppColors.primaryBlue)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    post.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isScheduled ? AppColors.warning : AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  post.platform.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: post.platform.toLowerCase() == 'facebook'
                        ? const Color(0xFF1877F2)
                        : const Color(0xFFE1306C),
                  ),
                ),
                const Spacer(),
                if (post.scheduledFor != null)
                  Text(
                    DateFormat('h:mm a').format(post.scheduledFor!.toLocal()),
                    style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.caption,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => context.go('/studio'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Open in Studio'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                  tooltip: 'Delete Post',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Post?'),
                        content: const Text('Are you sure you want to delete this scheduled post?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(postsProvider.notifier).deletePost(post.id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
