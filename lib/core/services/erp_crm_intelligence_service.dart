import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ErpCrmIntelligenceService {
  static const _firstSeenKey = 'crm_first_seen_iso';
  static const _lastActiveKey = 'crm_last_active_iso';
  static const _interactionCountKey = 'crm_interaction_count';
  static const _orderCountKey = 'erp_order_count';
  static const _demandMapKey = 'erp_demand_map_json';
  static const _reservationMapKey = 'erp_reservation_map_json';
  static const _lastPreferenceKey = 'crm_last_preference';
  static const _projectPromptPendingKey = 'crm_project_prompt_pending';

  static final ErpCrmIntelligenceService instance =
      ErpCrmIntelligenceService._();

  ErpCrmIntelligenceService._();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> touchSession() async {
    final prefs = await _prefs;
    final now = DateTime.now().toIso8601String();
    prefs.setString(_lastActiveKey, now);
    if (!prefs.containsKey(_firstSeenKey)) {
      prefs.setString(_firstSeenKey, now);
    }
  }

  Future<void> trackInteraction({String? productId, int weight = 1}) async {
    final prefs = await _prefs;
    await touchSession();
    final current = prefs.getInt(_interactionCountKey) ?? 0;
    await prefs.setInt(_interactionCountKey, current + weight);

    if (productId != null && productId.isNotEmpty) {
      await _incrementDemand(productId, weight);
    }
  }

  Future<void> trackRecommendationSelection(String preference) async {
    final prefs = await _prefs;
    await touchSession();
    await prefs.setString(_lastPreferenceKey, preference);
    await prefs.setBool(_projectPromptPendingKey, true);
    await trackInteraction(weight: 2);

    // Recommendation signals demand for related material groups.
    final canonical = _canonicalProductFromPreference(preference);
    await _incrementDemand(canonical, 3);
  }

  Future<void> recordOrderCreated() async {
    final prefs = await _prefs;
    final current = prefs.getInt(_orderCountKey) ?? 0;
    await prefs.setInt(_orderCountKey, current + 1);
    await touchSession();
  }

  Future<bool> reserveItem(String productId, {int minutes = 2}) async {
    final prefs = await _prefs;
    final reservations = _readMap(prefs.getString(_reservationMapKey));
    final now = DateTime.now();

    final existing = reservations[productId];
    if (existing != null) {
      final expiry = DateTime.tryParse(existing);
      if (expiry != null && expiry.isAfter(now)) {
        return false;
      }
    }

    reservations[productId] = now.add(Duration(minutes: minutes)).toIso8601String();
    await prefs.setString(_reservationMapKey, jsonEncode(reservations));
    await trackInteraction(productId: productId, weight: 2);
    return true;
  }

  Future<int> reservationSecondsLeft(String productId) async {
    final prefs = await _prefs;
    final reservations = _readMap(prefs.getString(_reservationMapKey));
    final raw = reservations[productId];
    if (raw == null) return 0;

    final expiry = DateTime.tryParse(raw);
    if (expiry == null) return 0;

    final diff = expiry.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  Future<bool> isHighDemand(String productId) async {
    final prefs = await _prefs;
    final demandMap = _readIntMap(prefs.getString(_demandMapKey));
    final score = demandMap[productId] ?? 0;
    return score >= 8;
  }

  Future<String?> getPersonalizedRecommendationBanner() async {
    final prefs = await _prefs;
    final preference = prefs.getString(_lastPreferenceKey);
    if (preference == null || preference.isEmpty) return null;
    return 'Recommended for you: $preference Components';
  }

  Future<String?> getReEngagementMessage() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_lastActiveKey);
    if (raw == null) return null;

    final lastActive = DateTime.tryParse(raw);
    if (lastActive == null) return null;

    final inactiveHours = DateTime.now().difference(lastActive).inHours;
    if (inactiveHours >= 24) {
      return 'It\'s been a while! Continue your project?';
    }
    return null;
  }

  Future<String> getCustomerLifecycle() async {
    final prefs = await _prefs;
    final firstRaw = prefs.getString(_firstSeenKey);
    final lastRaw = prefs.getString(_lastActiveKey);
    final interactions = prefs.getInt(_interactionCountKey) ?? 0;
    final orders = prefs.getInt(_orderCountKey) ?? 0;

    if (firstRaw == null) return 'New User';

    final firstSeen = DateTime.tryParse(firstRaw) ?? DateTime.now();
    final lastActive = lastRaw != null ? DateTime.tryParse(lastRaw) : null;
    final accountAgeDays = DateTime.now().difference(firstSeen).inDays;
    final inactiveDays =
        lastActive == null ? 0 : DateTime.now().difference(lastActive).inDays;

    if (inactiveDays >= 2 && (orders > 0 || interactions > 0)) {
      return 'Returning User';
    }
    if (orders >= 1 || interactions >= 8 || accountAgeDays >= 7) {
      return 'Active User';
    }
    return 'New User';
  }

  Future<String> getCustomerValueIndicator() async {
    final prefs = await _prefs;
    final interactions = prefs.getInt(_interactionCountKey) ?? 0;
    final orders = prefs.getInt(_orderCountKey) ?? 0;

    if (orders >= 3 || interactions >= 20) return 'Frequent Buyer';
    if (orders >= 1 || interactions >= 10) return 'Active Builder';
    return 'Beginner User';
  }

  Future<Map<String, int>> getOperationalDashboardSnapshot({
    required int availableStock,
    required int lowStockItems,
  }) async {
    final prefs = await _prefs;
    final totalOrders = prefs.getInt(_orderCountKey) ?? 0;
    return {
      'totalOrders': totalOrders,
      'availableStock': availableStock,
      'lowStockItems': lowStockItems,
    };
  }

  Future<List<String>> getContextAwareMessages({
    required bool lowStock,
  }) async {
    final prefs = await _prefs;
    final messages = <String>[];

    if (lowStock) {
      messages.add('Hurry! Limited availability');
    }

    if (prefs.getBool(_projectPromptPendingKey) ?? false) {
      messages.add('Complete your project');
      await prefs.setBool(_projectPromptPendingKey, false);
    }

    return messages;
  }

  Future<void> _incrementDemand(String productId, int by) async {
    final prefs = await _prefs;
    final map = _readIntMap(prefs.getString(_demandMapKey));
    map[productId] = (map[productId] ?? 0) + by;
    await prefs.setString(_demandMapKey, jsonEncode(map));
  }

  String _canonicalProductFromPreference(String preference) {
    final lower = preference.toLowerCase();
    if (lower.contains('iot')) return 'Arduino Uno Rev3';
    if (lower.contains('hardware')) return 'Raspberry Pi 4 (2GB)';
    if (lower.contains('automation')) return 'ESP32 Dev Board';
    return 'Arduino Uno Rev3';
  }

  Map<String, String> _readMap(String? raw) {
    if (raw == null || raw.isEmpty) return <String, String>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, String>{};
    return decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  Map<String, int> _readIntMap(String? raw) {
    if (raw == null || raw.isEmpty) return <String, int>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, int>{};
    return decoded.map((key, value) => MapEntry(key.toString(), (value as num).toInt()));
  }
}
