import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/platform_output.dart';
import '../../../../core/theme/app_colors.dart';

class LinkedInPreviewWidget extends StatefulWidget {
  final LinkedInPost post;

  const LinkedInPreviewWidget({super.key, required this.post});

  @override
  State<LinkedInPreviewWidget> createState() => _LinkedInPreviewWidgetState();
}

class _LinkedInPreviewWidgetState extends State<LinkedInPreviewWidget> {
  bool _copied = false;

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.post.fullFormattedText));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('LinkedIn post copied to clipboard! Ready to paste.'),
          backgroundColor: AppColors.linkedin,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.linkedin.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.business_center_rounded, size: 14, color: AppColors.linkedin),
                      SizedBox(width: 6),
                      Text(
                        'LinkedIn Thought Leadership',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.linkedin,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _copyToClipboard,
              icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: 16),
              label: Text(_copied ? 'Copied!' : 'Copy Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _copied ? AppColors.success : AppColors.linkedin,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // LinkedIn Feed Card Mockup
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceSecondary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.linkedin.withValues(alpha: 0.2),
                    child: const Icon(Icons.person_rounded, color: AppColors.linkedin, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'You (Author)',
                              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '• 1st',
                              style: textTheme.bodySmall?.copyWith(color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                        Text(
                          'Founder & Creator • Sharing actionable systems',
                          style: textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '1h • ',
                              style: textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                            const Icon(Icons.public_rounded, size: 12, color: AppColors.lightTextSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Post Body Hook
              Text(
                widget.post.hook,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Story Context
              Text(
                widget.post.storyContext,
                style: textTheme.bodyMedium?.copyWith(height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 14),

              // Bullet Lessons
              Text(
                'Here is the exact breakdown:',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...widget.post.keyLessons.map(
                (lesson) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.linkedin, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          lesson,
                          style: textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Call to Action
              Text(
                widget.post.callToAction,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Hashtags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.post.hashtags.map((tag) {
                  return Text(
                    tag,
                    style: TextStyle(
                      color: AppColors.linkedin,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),

              const Divider(height: 28),

              // LinkedIn Engagement Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEngageAction(Icons.thumb_up_alt_outlined, 'Like'),
                  _buildEngageAction(Icons.chat_bubble_outline_rounded, 'Comment'),
                  _buildEngageAction(Icons.repeat_rounded, 'Repost'),
                  _buildEngageAction(Icons.send_outlined, 'Send'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEngageAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.lightTextSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }
}
