import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/repurposed_campaign.dart';

class CampaignStorageService {
  static const String _storageKey = 'omniflow_saved_campaigns';

  const CampaignStorageService();

  Future<List<RepurposedCampaign>> loadCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey);
      if (rawList == null || rawList.isEmpty) return [];

      return rawList
          .map((item) => RepurposedCampaign.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCampaign(RepurposedCampaign campaign) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await loadCampaigns();
      // Prepend to top
      final updated = [campaign, ...existing.where((c) => c.id != campaign.id)];
      final encoded = updated.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList(_storageKey, encoded);
    } catch (_) {}
  }

  Future<void> deleteCampaign(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await loadCampaigns();
      final updated = existing.where((c) => c.id != id).toList();
      final encoded = updated.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList(_storageKey, encoded);
    } catch (_) {}
  }
}
