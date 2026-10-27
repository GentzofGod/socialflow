import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/platform_output.dart';
import '../../../../core/theme/app_colors.dart';

class NewsletterPreviewWidget extends StatefulWidget {
  final NewsletterBlast blast;

  const NewsletterPreviewWidget({super.key, required this.blast});

  @override
  State<NewsletterPreviewWidget> createState() => _NewsletterPreviewWidgetState();
}

class _NewsletterPreviewWidgetState extends State<NewsletterPreviewWidget> {
  int _selectedSubjectIndex = 0;
  bool _copied = false;

  void _copyAll() async {
    await Clipboard.setData(ClipboardData(text: widget.blast.fullFormattedNewsletter));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Newsletter draft & subject lines copied!'),
          backgroundColor: AppColors.newsletter,
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
                    color: AppColors.newsletter.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mail_outline_rounded, size: 14, color: AppColors.newsletter),
                      SizedBox(width: 6),
                      Text(
                        'Email Newsletter & Blast',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.newsletter,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _copyAll,
              icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: 16),
              label: Text(_copied ? 'Copied!' : 'Copy Newsletter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _copied ? AppColors.success : AppColors.newsletter,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Email Client Mockup
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
              // A/B Subject Lines Switcher
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : AppColors.lightSurfaceSecondary).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.newsletter.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'A/B TEST SUBJECT LINES:',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.newsletter,
                          ),
                        ),
                        Text(
                          'Select to preview',
                          style: textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...widget.blast.subjectLineOptions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final subj = entry.value;
                      final isSelected = _selectedSubjectIndex == idx;

                      return InkWell(
                        onTap: () => setState(() => _selectedSubjectIndex = idx),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                size: 14,
                                color: isSelected ? AppColors.newsletter : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  subj,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? (isDark ? Colors.white : AppColors.lightText)
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Preview Text Bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview text: ',
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Expanded(
                    child: Text(
                      widget.blast.previewText,
                      style: textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Email Body
              Text(
                widget.blast.bodyMarkdown,
                style: textTheme.bodyMedium?.copyWith(height: 1.6, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Primary CTA Button
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newsletter,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    widget.blast.callToAction,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // P.S. Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('P.S. ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        widget.blast.postScript,
                        style: textTheme.bodyMedium?.copyWith(height: 1.4, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
