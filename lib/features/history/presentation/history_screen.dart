import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/repurposed_campaign.dart';
import '../../../core/services/campaign_storage_service.dart';
import '../../../core/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final CampaignStorageService _storageService = const CampaignStorageService();
  List<RepurposedCampaign> _campaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await _storageService.loadCampaigns();
    if (mounted) {
      setState(() {
        _campaigns = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCampaign(String id) async {
    await _storageService.deleteCampaign(id);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _campaigns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.folder_open_rounded, size: 40, color: AppColors.primary),
                      ),
                      const SizedBox(height: 14),
                      Text('No Saved Campaigns Yet', style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Generate your first campaign in the Studio tab to save it here.',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: _campaigns.length,
                  itemBuilder: (context, index) {
                    final item = _campaigns[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                  onPressed: () => _deleteCampaign(item.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.sourceText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.tone,
                                    style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('•', style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 8),
                                Text(
                                  '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                                  style: textTheme.bodySmall?.copyWith(fontSize: 11),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () async {
                                    final md = item.exportAllAsMarkdown();
                                    await Clipboard.setData(ClipboardData(text: md));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Copied full campaign to clipboard!')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.copy_rounded, size: 14),
                                  label: const Text('Copy Bundle', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
