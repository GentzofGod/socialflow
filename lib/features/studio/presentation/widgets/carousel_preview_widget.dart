import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/platform_output.dart';
import '../../../../core/theme/app_colors.dart';

class CarouselPreviewWidget extends StatefulWidget {
  final InstagramCarousel carousel;

  const CarouselPreviewWidget({super.key, required this.carousel});

  @override
  State<CarouselPreviewWidget> createState() => _CarouselPreviewWidgetState();
}

class _CarouselPreviewWidgetState extends State<CarouselPreviewWidget> {
  int _currentSlide = 0;
  bool _copiedPlan = false;
  bool _copiedPrompt = false;

  void _copyAll() async {
    await Clipboard.setData(ClipboardData(text: widget.carousel.fullFormattedPost));
    setState(() => _copiedPlan = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedPlan = false);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instagram Carousel & Caption copied! Ready to design and post.'),
          backgroundColor: AppColors.instagram,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyCurrentVisualPrompt() async {
    final prompt = widget.carousel.slides[_currentSlide].visualPrompt;
    await Clipboard.setData(ClipboardData(text: prompt));
    setState(() => _copiedPrompt = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedPrompt = false);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visual Prompt copied for AI image generation!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final activeSlide = widget.carousel.slides.isNotEmpty
        ? widget.carousel.slides[_currentSlide]
        : null;

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
                    color: AppColors.instagram.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.photo_library_rounded, size: 14, color: AppColors.instagram),
                      SizedBox(width: 6),
                      Text(
                        'Instagram Carousel • 5 Visual Slides',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.instagram,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _copyAll,
              icon: Icon(_copiedPlan ? Icons.check_rounded : Icons.copy_rounded, size: 16),
              label: Text(_copiedPlan ? 'Copied!' : 'Copy Carousel & Caption'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _copiedPlan ? AppColors.success : AppColors.instagram,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Carousel Visual Card Container
        if (activeSlide != null) ...[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF2E1065)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFFAF5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.instagram.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.instagram.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top slide indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SLIDE ${_currentSlide + 1} OF ${widget.carousel.slides.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        widget.carousel.slides.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentSlide == index
                                ? AppColors.instagram
                                : (isDark ? Colors.white24 : Colors.black12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Slide Content
                Text(
                  activeSlide.headline,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                if (activeSlide.subheadline.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    activeSlide.subheadline,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Bullets
                ...activeSlide.bulletPoints.map(
                  (bp) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded, color: AppColors.instagram, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bp,
                            style: textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // AI Visual Generation Prompt Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.palette_outlined, size: 18, color: AppColors.primaryLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visual Prompt (for AI Image Gen / Canva):',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                            ),
                            Text(
                              activeSlide.visualPrompt,
                              style: textTheme.bodySmall?.copyWith(fontSize: 11, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _copiedPrompt ? Icons.check_rounded : Icons.copy_rounded,
                          size: 16,
                          color: _copiedPrompt ? AppColors.success : AppColors.lightTextSecondary,
                        ),
                        tooltip: 'Copy Prompt',
                        onPressed: _copyCurrentVisualPrompt,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Next / Previous Navigation Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _currentSlide > 0
                          ? () => setState(() => _currentSlide--)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded, size: 18),
                      label: const Text('Previous'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentSlide < widget.carousel.slides.length - 1
                          ? () => setState(() => _currentSlide++)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded, size: 18),
                      label: const Text('Next Slide'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.instagram,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),

        // Caption Box
        Container(
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
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.instagram),
                  const SizedBox(width: 6),
                  Text(
                    'Instagram Caption & Hashtags',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.carousel.caption,
                style: textTheme.bodyMedium?.copyWith(height: 1.5, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.carousel.hashtags.map((tag) {
                  return Text(
                    tag,
                    style: const TextStyle(
                      color: AppColors.instagram,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
