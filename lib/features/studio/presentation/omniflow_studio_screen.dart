import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/repurposed_campaign.dart';
import '../../../core/services/ai_repurposing_service.dart';
import '../../../core/services/campaign_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/carousel_preview_widget.dart';
import 'widgets/linkedin_preview_widget.dart';
import 'widgets/newsletter_preview_widget.dart';
import 'widgets/twitter_thread_widget.dart';

class OmniFlowStudioScreen extends StatefulWidget {
  final RepurposedCampaign? initialCampaign;

  const OmniFlowStudioScreen({super.key, this.initialCampaign});

  @override
  State<OmniFlowStudioScreen> createState() => _OmniFlowStudioScreenState();
}

class _OmniFlowStudioScreenState extends State<OmniFlowStudioScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _ctaController = TextEditingController();
  final AiRepurposingService _aiService = const AiRepurposingService();
  final CampaignStorageService _storageService = const CampaignStorageService();

  late TabController _tabController;

  bool _isGenerating = false;
  String _selectedTone = 'Thought Leadership';
  String _selectedAudience = 'Founders & Builders';
  RepurposedCampaign? _currentCampaign;

  final List<String> _tones = [
    'Thought Leadership',
    'Viral & Punchy',
    'Storytelling & Vulnerable',
    'Actionable Breakdown',
  ];

  final List<String> _audiences = [
    'Founders & Builders',
    'Content Creators',
    'Tech Professionals',
    'Marketing Teams',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.initialCampaign != null) {
      _currentCampaign = widget.initialCampaign;
      _sourceController.text = widget.initialCampaign!.sourceText;
      _selectedTone = widget.initialCampaign!.tone;
      _selectedAudience = widget.initialCampaign!.targetAudience;
      _ctaController.text = widget.initialCampaign!.callToAction;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sourceController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  void _loadPreset(String title, String text, String tone, String audience, String cta) {
    setState(() {
      _sourceController.text = text;
      _selectedTone = tone;
      _selectedAudience = audience;
      _ctaController.text = cta;
    });
  }

  Future<void> _handleTransform() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an idea or select a demo preset first.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final campaign = await _aiService.repurposeContent(
        sourceText: text,
        tone: _selectedTone,
        targetAudience: _selectedAudience,
        callToAction: _ctaController.text.trim(),
      );

      await _storageService.saveCampaign(campaign);

      setState(() {
        _currentCampaign = campaign;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Transformed into 4 platforms successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _exportFullPackage() async {
    if (_currentCampaign == null) return;
    final markdown = _currentCampaign!.exportAllAsMarkdown();
    await Clipboard.setData(ClipboardData(text: markdown));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full campaign package (all 4 platforms) copied to clipboard!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'OmniFlow Studio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (_currentCampaign != null)
            ElevatedButton.icon(
              onPressed: _exportFullPackage,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export All (.md)'),
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
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Source Input Hub Card
                _buildSourceInputCard(context, isDark, textTheme),

                const SizedBox(height: 24),

                // Generation Output Section
                if (_isGenerating) ...[
                  Container(
                    padding: const EdgeInsets.all(48),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 18),
                        Text(
                          'Transforming 1 idea into 4 optimized social formats...',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Synthesizing LinkedIn hooks, Twitter thread, Carousel slides, and Newsletter draft.',
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else if (_currentCampaign != null) ...[
                  _buildOutputTabs(isDark, textTheme),
                ] else ...[
                  _buildEmptyState(context, isDark, textTheme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceInputCard(BuildContext context, bool isDark, TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Source Anchor Content', style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Paste an article summary, product launch, or raw thought. We will format it 4 ways.',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Demo Presets Dropdown
                PopupMenuButton<String>(
                  icon: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flash_on_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Demo Presets', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  onSelected: (val) {
                    if (val == 'launch') {
                      _loadPreset(
                        'Product Launch',
                        'We are launching SocialFlow v2 today: an AI-driven social media operating system that turns 1 core idea into LinkedIn posts, Twitter threads, Instagram carousels, and newsletters automatically. Solves creator fatigue and saves 10 hours a week.',
                        'Viral & Punchy',
                        'Founders & Builders',
                        'Check the live link in the comments and let us know your feedback! 🚀',
                      );
                    } else if (val == 'lesson') {
                      _loadPreset(
                        'Founder Lesson',
                        'The biggest mistake early founders make is building in isolation for 6 months without distributing early. Content isn\'t marketing; it is market validation in public.',
                        'Thought Leadership',
                        'Founders & Builders',
                        'Drop a comment if you have learned this the hard way.',
                      );
                    } else if (val == 'framework') {
                      _loadPreset(
                        'Productivity Framework',
                        'The 80/20 Rule of Content Creation: Spend 20% of your time creating the anchor insight, and 80% of your time distributing it across multiple platforms with native formatting.',
                        'Actionable Breakdown',
                        'Content Creators',
                        'Save this framework for your next creation sprint! 📌',
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'launch',
                      child: Text('🚀 SaaS Product Launch Announcement'),
                    ),
                    const PopupMenuItem(
                      value: 'lesson',
                      child: Text('💡 Founder Lesson: Building in Public'),
                    ),
                    const PopupMenuItem(
                      value: 'framework',
                      child: Text('⚡ 80/20 Content Repurposing Framework'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Source Input Field
            TextField(
              controller: _sourceController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. Enter your core idea, raw bullet points, product launch, or paste an article...',
              ),
            ),
            const SizedBox(height: 16),

            // Tone & Audience Row
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                // Tone Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Content Tone', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: _tones.map((tone) {
                        final isSelected = _selectedTone == tone;
                        return ChoiceChip(
                          label: Text(tone, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          onSelected: (_) => setState(() => _selectedTone = tone),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Audience Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Audience', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: _audiences.map((aud) {
                        final isSelected = _selectedAudience == aud;
                        return ChoiceChip(
                          label: Text(aud, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                          selected: isSelected,
                          selectedColor: AppColors.secondary,
                          onSelected: (_) => setState(() => _selectedAudience = aud),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // CTA Field
            TextField(
              controller: _ctaController,
              decoration: const InputDecoration(
                labelText: 'Call to Action (Optional)',
                hintText: 'e.g. Join the waitlist, Save for later, Reply below...',
                prefixIcon: Icon(Icons.touch_app_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 20),

            // Transform Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _handleTransform,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _isGenerating ? 'Transforming...' : 'Transform into 4 Formats ⚡',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputTabs(bool isDark, TextTheme textTheme) {
    final campaign = _currentCampaign!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tab Navigation Header
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                icon: Icon(Icons.business_center_rounded, size: 18),
                text: 'LinkedIn',
              ),
              Tab(
                icon: Icon(Icons.alternate_email_rounded, size: 18),
                text: 'X (Thread)',
              ),
              Tab(
                icon: Icon(Icons.photo_library_rounded, size: 18),
                text: 'Instagram',
              ),
              Tab(
                icon: Icon(Icons.mail_outline_rounded, size: 18),
                text: 'Newsletter',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tab Views
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            switch (_tabController.index) {
              case 0:
                return LinkedInPreviewWidget(post: campaign.linkedIn);
              case 1:
                return TwitterThreadWidget(thread: campaign.twitter);
              case 2:
                return CarouselPreviewWidget(carousel: campaign.instagram);
              case 3:
                return NewsletterPreviewWidget(blast: campaign.newsletter);
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary.withValues(alpha: 0.5) : AppColors.lightSurfaceSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.layers_outlined, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Create Once, Distribute Everywhere',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              'Input a core idea above or pick a Demo Preset, then click "Transform into 4 Formats" to preview and copy your multi-channel campaign.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
