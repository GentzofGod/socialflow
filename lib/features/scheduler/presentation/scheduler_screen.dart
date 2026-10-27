import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class SchedulerScreen extends StatelessWidget {
  const SchedulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final schedule = [
      {
        'day': 'Monday • 8:00 AM',
        'platform': 'LinkedIn',
        'color': AppColors.linkedin,
        'icon': Icons.business_center_rounded,
        'title': 'Drop 1: Authority & Thought Leadership Post',
        'reason': 'Peak B2B professional activity time. Establishes the week’s core perspective and sparks industry discussion.',
      },
      {
        'day': 'Tuesday • 12:30 PM',
        'platform': 'X (Twitter)',
        'color': AppColors.twitter,
        'icon': Icons.alternate_email_rounded,
        'title': 'Drop 2: High-Velocity 5-Tweet Thread',
        'reason': 'Lunchtime spike in scroll speed. Breaks down the anchor idea into fast-reading bite-sized bullet points.',
      },
      {
        'day': 'Thursday • 6:00 PM',
        'platform': 'Instagram',
        'color': AppColors.instagram,
        'icon': Icons.photo_library_rounded,
        'title': 'Drop 3: Visual 5-Slide Carousel',
        'reason': 'Evening relaxed browsing. High bookmark and save rate for slide decks and visual frameworks.',
      },
      {
        'day': 'Saturday • 9:00 AM',
        'platform': 'Newsletter',
        'color': AppColors.newsletter,
        'icon': Icons.mail_outline_rounded,
        'title': 'Drop 4: Deep-Dive Email Blast & Direct CTA',
        'reason': 'Weekend reflective reading. Intimate audience relationship with highest conversion click-through rate.',
      },
    ];

    void copySchedule() async {
      const planText = '''
OMNIFLOW 1-TO-4 CONTENT DISTRIBUTION TIMELINE:

1. MONDAY 8:00 AM -> LinkedIn Authority Post
   Goal: Industry conversation & peer discussion.

2. TUESDAY 12:30 PM -> X (Twitter) 5-Tweet Thread
   Goal: High-speed viral engagement & retweets.

3. THURSDAY 6:00 PM -> Instagram Visual Carousel
   Goal: Long-term bookmarks & visual shares.

4. SATURDAY 9:00 AM -> Newsletter Deep-Dive Blast
   Goal: High-converting direct click-through & sales.
''';
      await Clipboard.setData(const ClipboardData(text: planText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Distribution schedule copied to clipboard!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution Schedule'),
        actions: [
          ElevatedButton.icon(
            onPressed: copySchedule,
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Schedule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Strategy Overview Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_graph_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'The Omnichannel Cascade Strategy',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Don\'t post everywhere simultaneously. Spacing your 4 formats across 7 days maximizes reach, prevents audience fatigue, and tests which hook converts best.',
                        style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Timeline List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schedule.length,
                  itemBuilder: (context, index) {
                    final item = schedule[index];
                    final color = item['color'] as Color;
                    final icon = item['icon'] as IconData;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['platform'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: color,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item['day'] as String,
                                          style: textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['title'] as String,
                                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['reason'] as String,
                                    style: textTheme.bodySmall?.copyWith(height: 1.4),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}
