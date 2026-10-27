import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/platform_output.dart';
import '../../../../core/theme/app_colors.dart';

class TwitterThreadWidget extends StatefulWidget {
  final TwitterThread thread;

  const TwitterThreadWidget({super.key, required this.thread});

  @override
  State<TwitterThreadWidget> createState() => _TwitterThreadWidgetState();
}

class _TwitterThreadWidgetState extends State<TwitterThreadWidget> {
  bool _copiedAll = false;
  int? _copiedIndex;

  void _copyAll() async {
    await Clipboard.setData(ClipboardData(text: widget.thread.fullFormattedThread));
    setState(() => _copiedAll = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedAll = false);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All 5 tweets copied to clipboard! Ready to schedule or post.'),
          backgroundColor: AppColors.twitter,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _copySingleTweet(int index) async {
    await Clipboard.setData(ClipboardData(text: widget.thread.tweets[index]));
    setState(() => _copiedIndex = index);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedIndex = null);
    });
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
                    color: AppColors.twitter.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.alternate_email_rounded, size: 14, color: AppColors.twitter),
                      SizedBox(width: 6),
                      Text(
                        'X (Twitter) Thread • 5 Tweets',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.twitter,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _copyAll,
              icon: Icon(_copiedAll ? Icons.check_rounded : Icons.copy_all_rounded, size: 16),
              label: Text(_copiedAll ? 'Thread Copied!' : 'Copy Entire Thread'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _copiedAll ? AppColors.success : AppColors.twitter,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Thread List with connecting thread line
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.thread.tweets.length,
          itemBuilder: (context, index) {
            final isLast = index == widget.thread.tweets.length - 1;
            final tweetText = widget.thread.tweets[index];
            final charCount = tweetText.length;
            final isCopied = _copiedIndex == index;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left avatar column with connecting vertical line
                  SizedBox(
                    width: 44,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.twitter.withValues(alpha: 0.15),
                          child: const Icon(Icons.person_rounded, size: 20, color: AppColors.twitter),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right Tweet Body Card
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSecondary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Author + Tweet number badge + Copy button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'You',
                                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 14, color: AppColors.twitter),
                                  const SizedBox(width: 6),
                                  Text(
                                    '@yourhandle',
                                    style: textTheme.bodySmall?.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: charCount > 280
                                          ? AppColors.error.withValues(alpha: 0.15)
                                          : AppColors.twitter.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$charCount/280',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: charCount > 280 ? AppColors.error : AppColors.twitter,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _copySingleTweet(index),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        isCopied ? Icons.check_rounded : Icons.copy_rounded,
                                        size: 16,
                                        color: isCopied ? AppColors.success : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Tweet Content
                          Text(
                            tweetText,
                            style: textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
