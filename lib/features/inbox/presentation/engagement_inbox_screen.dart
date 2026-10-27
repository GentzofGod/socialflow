import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/theme_toggle_button.dart';

class EngagementInboxScreen extends StatefulWidget {
  const EngagementInboxScreen({super.key});

  @override
  State<EngagementInboxScreen> createState() => _EngagementInboxScreenState();
}

class _EngagementInboxScreenState extends State<EngagementInboxScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All Interactions', 'Comments', 'Mentions', 'Requires Review'];

  // AI Sandbox Tester State
  bool _showSandbox = false;
  final TextEditingController _sampleMessageController = TextEditingController();
  String _simulatedReply = '';
  bool _isGeneratingReply = false;
  String _replyTone = 'Helpful & Friendly';

  final List<String> _samplePrompts = [
    'When does early access open for beta users?',
    'Does your tool support multi-account scheduling?',
    'Great release! Are you planning a tablet layout?',
  ];

  @override
  void dispose() {
    _sampleMessageController.dispose();
    super.dispose();
  }

  void _generateSimulatedReply() async {
    final msg = _sampleMessageController.text.trim();
    if (msg.isEmpty) return;

    setState(() => _isGeneratingReply = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    String replyText = '';
    if (_replyTone == 'Helpful & Friendly') {
      replyText = 'Thanks so much for reaching out! Regarding "$msg": We\'re actively supporting this feature with live sync. Let us know if you have any questions!';
    } else if (_replyTone == 'Direct & Professional') {
      replyText = 'Thank you for your inquiry. Our team has recorded this request regarding "$msg" and updates are scheduled for our next release cycle.';
    } else {
      replyText = 'Awesome question! 🚀 We love hearing from our community about "$msg". Check out our latest post for full details and discount codes!';
    }

    setState(() {
      _isGeneratingReply = false;
      _simulatedReply = replyText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engagement Inbox'),
        actions: [
          IconButton(
            icon: Icon(_showSandbox ? Icons.chat_bubble_outline_rounded : Icons.auto_awesome_rounded),
            tooltip: _showSandbox ? 'Back to Live Inbox' : 'Open AI Reply Simulator',
            onPressed: () => setState(() => _showSandbox = !_showSandbox),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilterIndex = index);
                    },
                    selectedColor: (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                        .withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(),

          // Interactive AI Sandbox or Authentic Clean Live State
          Expanded(
            child: _showSandbox
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isDark ? AppColors.subtleDarkGradient : AppColors.subtleLightGradient,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue)
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology_outlined, color: AppColors.primaryBlue, size: 22),
                                const SizedBox(width: 8),
                                Text('AI Reply Generator Sandbox', style: textTheme.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Test how the AI assistant composes human-in-the-loop replies before applying them to real Meta conversations.',
                              style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text('Sample Audience Inquiry', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _samplePrompts.map((prompt) {
                          return ActionChip(
                            label: Text(prompt, style: const TextStyle(fontSize: 11)),
                            onPressed: () {
                              _sampleMessageController.text = prompt;
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _sampleMessageController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Enter an audience comment or select one above...',
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _replyTone,
                              items: const [
                                DropdownMenuItem(value: 'Helpful & Friendly', child: Text('Helpful & Friendly')),
                                DropdownMenuItem(value: 'Direct & Professional', child: Text('Direct & Professional')),
                                DropdownMenuItem(value: 'Enthusiastic / Marketing', child: Text('Enthusiastic')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _replyTone = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isGeneratingReply ? null : _generateSimulatedReply,
                            icon: _isGeneratingReply
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.auto_awesome_rounded, size: 16),
                            label: const Text('Generate Reply'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (_simulatedReply.isNotEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Suggested AI Reply (Human Review Required)',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(_simulatedReply, style: textTheme.bodyLarge),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: _simulatedReply));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('AI reply copied to clipboard!')),
                                        );
                                      },
                                      icon: const Icon(Icons.copy_rounded, size: 16),
                                      label: const Text('Copy Reply'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                : EmptyStateView(
                    icon: Icons.mark_chat_read_outlined,
                    title: 'Your Inbox is Clean',
                    description:
                        'No unreviewed comments or audience interactions yet. Once Meta accounts are linked, incoming conversations will sync here for AI-suggested replies.',
                    actionLabel: 'Open AI Reply Simulator',
                    onAction: () => setState(() => _showSandbox = true),
                    extraContent: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.accentPurpleLight : AppColors.accentPurple)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.security_rounded,
                            size: 15,
                            color: isDark ? AppColors.accentPurpleLight : AppColors.accentPurple,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI human-in-the-loop review policy active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.accentPurpleLight : AppColors.accentPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
