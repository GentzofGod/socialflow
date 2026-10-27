import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../data/posts_repository.dart';
import '../domain/post_model.dart';

class ContentStudioScreen extends ConsumerStatefulWidget {
  final PostModel? initialPost;

  const ContentStudioScreen({
    super.key,
    this.initialPost,
  });

  @override
  ConsumerState<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends ConsumerState<ContentStudioScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();

  bool _isGenerating = false;
  bool _isSaving = false;
  bool _showLivePreview = false;
  String _selectedPlatform = 'Instagram';
  String _selectedTone = 'Professional';
  String? _editingPostId;

  final List<String> _quickHashtags = [
    '#SocialFlow',
    '#MetaAI',
    '#Marketing',
    '#ContentStrategy',
    '#Growth',
    '#Tech',
    '#CreatorEconomy',
    '#SmallBusiness',
  ];

  final List<String> _tones = [
    'Professional',
    'Friendly',
    'Bold & Urgent',
    'Promotional',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPost != null) {
      _editingPostId = widget.initialPost!.id;
      _captionController.text = widget.initialPost!.caption;
      _selectedPlatform = widget.initialPost!.platform.toLowerCase() == 'facebook'
          ? 'Facebook'
          : 'Instagram';
    }
    _captionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _promptController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _handleGenerateAiDraft() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic or key points first.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    String prefix = 'Announcement:';
    if (_selectedTone == 'Friendly') prefix = 'Hey everyone! Exciting news:';
    if (_selectedTone == 'Bold & Urgent') prefix = 'Don\'t miss this:';
    if (_selectedTone == 'Promotional') prefix = 'Limited offer:';

    setState(() {
      _isGenerating = false;
      _captionController.text =
          '🚀 $prefix $prompt\n\n'
          'Let us know your thoughts in the comments below! 👇\n\n'
          '#SocialFlow #MetaAI #ContentStrategy #Growth';
    });
  }

  void _addHashtag(String tag) {
    final currentText = _captionController.text;
    if (currentText.contains(tag)) return;

    if (currentText.isEmpty) {
      _captionController.text = tag;
    } else {
      _captionController.text = '$currentText $tag';
    }
    _captionController.selection = TextSelection.fromPosition(
      TextPosition(offset: _captionController.text.length),
    );
  }

  Future<void> _savePost({required String status, DateTime? scheduledFor}) async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please compose or generate a caption first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_editingPostId != null) {
        await ref.read(postsProvider.notifier).updatePost(
              id: _editingPostId!,
              caption: caption,
              platform: _selectedPlatform,
              status: status,
              scheduledFor: scheduledFor,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'scheduled'
                    ? 'Post scheduled in Cloud Supabase!'
                    : 'Draft updated in Cloud Supabase!',
              ),
            ),
          );
        }
      } else {
        await ref.read(postsProvider.notifier).createPost(
              caption: caption,
              platform: _selectedPlatform,
              status: status,
              scheduledFor: scheduledFor,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'scheduled'
                    ? 'Post scheduled in Cloud Supabase!'
                    : 'Draft saved in Cloud Supabase!',
              ),
            ),
          );
          _captionController.clear();
          _promptController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _promptScheduleDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (pickedTime == null || !mounted) return;

    final scheduledDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    await _savePost(status: 'scheduled', scheduledFor: scheduledDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final postsAsync = ref.watch(postsProvider);

    final charCount = _captionController.text.length;
    final maxChars = _selectedPlatform == 'Instagram' ? 2200 : 5000;
    final wordCount = _captionController.text.trim().isEmpty
        ? 0
        : _captionController.text.trim().split(RegExp(r'\s+')).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingPostId != null ? 'Edit Post' : 'Content Studio'),
        actions: [
          IconButton(
            icon: Icon(_showLivePreview ? Icons.edit_note_rounded : Icons.preview_rounded),
            tooltip: _showLivePreview ? 'Back to Editor' : 'Toggle Post Preview',
            onPressed: () => setState(() => _showLivePreview = !_showLivePreview),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Channel Selector Tabs
          Row(
            children: [
              Expanded(
                child: _buildPlatformTab(
                  platform: 'Instagram',
                  label: 'Instagram Professional',
                  icon: Icons.camera_alt_outlined,
                  color: const Color(0xFFE1306C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlatformTab(
                  platform: 'Facebook',
                  label: 'Facebook Page',
                  icon: Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Live Post Preview Mode or Editor Mode
          if (_showLivePreview) ...[
            _buildPostPreviewCard(context),
            const SizedBox(height: 20),
          ] else ...[
            // Tone Selector Chips
            Text('Brand Voice / Tone', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tones.map((tone) {
                  final isSelected = _selectedTone == tone;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tone),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedTone = tone);
                      },
                      selectedColor: (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                          .withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // AI Objective Input
            Text('Content Objective / Topic', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Announcing our summer feature update with 20% discount code...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => _promptController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _handleGenerateAiDraft,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(_isGenerating ? 'Generating...' : 'Generate AI Caption'),
              ),
            ),
            const SizedBox(height: 20),

            // Caption Editor with Live Stats & Copy
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Post Caption', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text(
                      '$wordCount words • $charCount/$maxChars',
                      style: textTheme.labelMedium?.copyWith(
                        fontSize: 11,
                        color: charCount > maxChars ? AppColors.error : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      tooltip: 'Copy caption',
                      onPressed: () {
                        if (_captionController.text.trim().isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: _captionController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Caption copied to clipboard!')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Your composed caption will appear here. Edit freely or write your own message directly.',
              ),
            ),
            const SizedBox(height: 12),

            // Interactive Quick Hashtags
            Text('Quick Hashtag Insertion', style: textTheme.labelMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickHashtags.map((tag) {
                return ActionChip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  onPressed: () => _addHashtag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Save & Schedule Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => _savePost(status: 'draft'),
                  icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                  label: Text(_isSaving ? 'Saving...' : 'Save as Draft'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _promptScheduleDateTime,
                  icon: const Icon(Icons.schedule_send_rounded, size: 18),
                  label: Text(_isSaving ? 'Scheduling...' : 'Schedule Post'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Saved Drafts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Cloud Drafts', style: textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: 'Refresh Drafts',
                onPressed: () => ref.invalidate(postsProvider),
              ),
            ],
          ),
          const SizedBox(height: 12),
          postsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Could not load posts: $err',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            data: (posts) {
              if (posts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No saved drafts yet. Write your first post above and click "Save as Draft"!',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Column(
                children: posts.map((post) {
                  final isScheduled = post.status == 'scheduled';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isScheduled ? AppColors.warning : AppColors.primaryBlue)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isScheduled ? Icons.schedule_rounded : Icons.article_outlined,
                          color: isScheduled ? AppColors.warning : AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        post.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text(
                              post.platform.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: post.platform.toLowerCase() == 'facebook'
                                    ? const Color(0xFF1877F2)
                                    : const Color(0xFFE1306C),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isScheduled && post.scheduledFor != null
                                  ? 'For: ${DateFormat('MMM d, h:mm a').format(post.scheduledFor!.toLocal())}'
                                  : 'Draft • ${DateFormat('MMM d').format(post.createdAt.toLocal())}',
                              style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Load into composer',
                            onPressed: () {
                              setState(() {
                                _editingPostId = post.id;
                                _captionController.text = post.caption;
                                _selectedPlatform = post.platform.toLowerCase() == 'facebook'
                                    ? 'Facebook'
                                    : 'Instagram';
                                _showLivePreview = false;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                            tooltip: 'Delete Draft',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Post?'),
                                  content: const Text('This will permanently delete this post from Cloud Supabase.'),
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
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformTab({
    required String platform,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedPlatform == platform;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedPlatform = platform),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.lightTextSecondary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostPreviewCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final isInstagram = _selectedPlatform == 'Instagram';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: (isInstagram ? const Color(0xFFE1306C) : const Color(0xFF1877F2))
                      .withValues(alpha: 0.15),
                  child: Icon(
                    isInstagram ? Icons.camera_alt_outlined : Icons.facebook_rounded,
                    color: isInstagram ? const Color(0xFFE1306C) : const Color(0xFF1877F2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isInstagram ? 'your_brand_handle' : 'Your Brand Page',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        isInstagram ? 'Instagram Professional' : 'Sponsored • Just now',
                        style: textTheme.labelMedium?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz_rounded, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _captionController.text.trim().isEmpty
                  ? 'Your post preview will render here as you type in the editor.'
                  : _captionController.text,
              style: textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.favorite_border_rounded, size: 22, color: isDark ? Colors.white70 : Colors.black87),
                const SizedBox(width: 14),
                Icon(Icons.chat_bubble_outline_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                const SizedBox(width: 14),
                Icon(Icons.send_outlined, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                const Spacer(),
                Icon(Icons.bookmark_border_rounded, size: 22, color: isDark ? Colors.white70 : Colors.black87),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
