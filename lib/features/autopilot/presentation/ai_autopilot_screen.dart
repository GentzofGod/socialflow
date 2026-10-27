import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_toggle_button.dart';

class AiAutopilotScreen extends StatefulWidget {
  const AiAutopilotScreen({super.key});

  @override
  State<AiAutopilotScreen> createState() => _AiAutopilotScreenState();
}

class _AiAutopilotScreenState extends State<AiAutopilotScreen> {
  bool _requireHumanApproval = true;
  bool _autoGenerateReplyDrafts = true;
  bool _safetyFilterProfanity = true;
  bool _killSwitchEmergencyPause = false;
  double _maxDailyReplies = 15;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Autopilot & Safety'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Kill Switch Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _killSwitchEmergencyPause
                  ? AppColors.error.withValues(alpha: 0.12)
                  : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _killSwitchEmergencyPause
                    ? AppColors.error
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _killSwitchEmergencyPause ? Icons.pause_circle_filled_rounded : Icons.shield_rounded,
                  color: _killSwitchEmergencyPause
                      ? AppColors.error
                      : (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue),
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _killSwitchEmergencyPause ? 'All Automation Paused' : 'Safety Autopilot Active',
                        style: textTheme.titleMedium?.copyWith(
                          color: _killSwitchEmergencyPause ? AppColors.error : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _killSwitchEmergencyPause
                            ? 'All outbound AI actions, scheduled posts, and auto-replies are paused.'
                            : 'Human-in-the-loop protection ensures safe automation.',
                        style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: !_killSwitchEmergencyPause,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (val) {
                    setState(() => _killSwitchEmergencyPause = !val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_killSwitchEmergencyPause
                            ? 'Emergency kill switch enabled: automation paused.'
                            : 'Automation safety system resumed.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Policy Controls
          Text('Automation Safety Policies', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildSwitchTile(
            context,
            title: 'Human-in-the-loop Post Approval',
            subtitle: 'AI-generated posts require explicit manual confirmation before publishing.',
            value: _requireHumanApproval,
            onChanged: (val) => setState(() => _requireHumanApproval = val),
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            context,
            title: 'Generate Reply Drafts in Inbox',
            subtitle: 'Pre-draft polite contextual replies for comments and mentions automatically.',
            value: _autoGenerateReplyDrafts,
            onChanged: (val) => setState(() => _autoGenerateReplyDrafts = val),
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            context,
            title: 'Content Moderation & Spam Filter',
            subtitle: 'Instantly flag offensive, hateful, or repetitive spam comments.',
            value: _safetyFilterProfanity,
            onChanged: (val) => setState(() => _safetyFilterProfanity = val),
          ),
          const SizedBox(height: 24),

          // Rate Limiting
          Text('Rate Limiting & Thresholds', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Max Daily AI Actions', style: textTheme.titleSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_maxDailyReplies.toInt()} actions/day',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.primaryBlueDark : AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _maxDailyReplies,
                    min: 5,
                    max: 50,
                    divisions: 9,
                    onChanged: (val) => setState(() => _maxDailyReplies = val),
                  ),
                  Text(
                    'Enforces strict Meta Graph API rate limit safety to safeguard your connected accounts against throttling.',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Interactive Safety Audit & Reset
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _requireHumanApproval = true;
                      _autoGenerateReplyDrafts = true;
                      _safetyFilterProfanity = true;
                      _killSwitchEmergencyPause = false;
                      _maxDailyReplies = 15;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Safety settings reset to recommended defaults.')),
                    );
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Reset Defaults'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _runSafetyAudit(context),
                  icon: const Icon(Icons.verified_user_rounded, size: 18),
                  label: const Text('Run Safety Audit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _runSafetyAudit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_rounded, color: AppColors.success, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'AI Safety Audit Report',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAuditItem(
                  'Human-in-the-Loop',
                  _requireHumanApproval ? 'Active • Posts require manual confirmation' : 'Disabled • Warning',
                  _requireHumanApproval,
                ),
                _buildAuditItem(
                  'Emergency Kill-Switch',
                  !_killSwitchEmergencyPause ? 'Standby • Ready for emergency pause' : 'TRIGGERED • Automation paused',
                  !_killSwitchEmergencyPause,
                ),
                _buildAuditItem(
                  'Content Moderation',
                  _safetyFilterProfanity ? 'Active • Profanity & spam filters engaged' : 'Off',
                  _safetyFilterProfanity,
                ),
                _buildAuditItem(
                  'Daily Rate Limit',
                  'Set to ${_maxDailyReplies.toInt()} actions/day (Meta compliant)',
                  true,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close Audit'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuditItem(String title, String status, bool isHealthy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: isHealthy ? AppColors.success : AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(status, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: SwitchListTile(
        title: Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
