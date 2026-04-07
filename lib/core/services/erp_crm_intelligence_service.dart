import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErpCrmIntelligenceService {
  static const _firstSeenKey = 'crm_first_seen_iso';
  static const _lastActiveKey = 'crm_last_active_iso';
  static const _interactionCountKey = 'crm_interaction_count';
  static const _orderCountKey = 'erp_order_count';
  static const _demandMapKey = 'erp_demand_map_json';
  static const _reservationMapKey = 'erp_reservation_map_json';
  static const _lastPreferenceKey = 'crm_last_preference';
  static const _projectPromptPendingKey = 'crm_project_prompt_pending';
  static const _onboardingCompletedKey = 'crm_onboarding_completed';
  static const _requestCountKey = 'crm_request_count';
  static const _checkoutCountKey = 'crm_checkout_count';
  static const _deliveredCountKey = 'erp_delivered_count';
  static const _revenueBookedKey = 'revenue_booked_inr';
  static const _adminScmActionsKey = 'erp_admin_scm_actions';
  static const _adminErpActionsKey = 'erp_admin_erp_actions';
  static const _lastScmPatternKey = 'erp_last_scm_pattern';
  static const _lastStockHealthKey = 'erp_last_stock_health';
  static const _lastLeadTimeKey = 'erp_last_lead_time';
  static const _competitorEdgeMilestoneKey = 'competitor_edge_milestone';
  static const _acquisitionMapKey = 'crm_acquisition_map_json';
  static const _retentionMapKey = 'crm_retention_map_json';
  static const _platformEarningsKey = 'revenue_platform_earnings';
  static const _serviceEarningsKey = 'revenue_service_earnings';
  static const _fulfillmentEarningsKey = 'revenue_fulfillment_earnings';
  static const _reactivationCampaignQueueKey = 'crm_reactivation_campaign_queue_json';
  static const _campaignLastGeneratedKey = 'crm_campaign_last_generated_iso';
  static const _campaignOpenCountKey = 'crm_campaign_open_count';
  static const _campaignConversionCountKey = 'crm_campaign_conversion_count';

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

  Future<void> recordOnboardingCompleted() async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingCompletedKey, true);
    await trackInteraction(weight: 2);
    await _logFlowEvent(
      aspect: 'crm',
      stage: 'selection',
      action: 'onboarding_completed',
      actorRole: 'customer',
    );
    await recordAcquisitionChannel('onboarding_complete');
  }

  Future<void> recordRequestCreated() async {
    final prefs = await _prefs;
    final current = prefs.getInt(_requestCountKey) ?? 0;
    await prefs.setInt(_requestCountKey, current + 1);
    await trackInteraction(weight: 3);
    await _logFlowEvent(
      aspect: 'crm',
      stage: 'acquisition',
      action: 'request_created',
      actorRole: 'customer',
      metadata: {
        'request_count': current + 1,
      },
    );
    await recordAcquisitionChannel('request_creation');
  }

  Future<void> recordCheckoutStarted() async {
    final prefs = await _prefs;
    final current = prefs.getInt(_checkoutCountKey) ?? 0;
    await prefs.setInt(_checkoutCountKey, current + 1);
    await touchSession();
    await _logFlowEvent(
      aspect: 'crm',
      stage: 'conversion',
      action: 'checkout_started',
      actorRole: 'customer',
      metadata: {
        'checkout_count': current + 1,
      },
    );
  }

  Future<void> recordAcquisitionChannel(String channel) async {
    final prefs = await _prefs;
    final map = _readIntMap(prefs.getString(_acquisitionMapKey));
    map[channel] = (map[channel] ?? 0) + 1;
    await prefs.setString(_acquisitionMapKey, jsonEncode(map));
    await _logFlowEvent(
      aspect: 'crm',
      stage: 'acquisition',
      action: 'acquisition_channel_$channel',
      actorRole: 'customer',
      metadata: {'count': map[channel]},
    );
  }

  Future<void> recordRetentionAction(String action) async {
    final prefs = await _prefs;
    final map = _readIntMap(prefs.getString(_retentionMapKey));
    map[action] = (map[action] ?? 0) + 1;
    await prefs.setString(_retentionMapKey, jsonEncode(map));
    await _logFlowEvent(
      aspect: 'crm',
      stage: 'retention',
      action: action,
      actorRole: 'customer',
      metadata: {'count': map[action]},
    );
  }

  Future<void> recordOrderPlaced({
    required double amountInr,
    String paymentMethod = 'unknown',
  }) async {
    final prefs = await _prefs;
    final revenue = prefs.getDouble(_revenueBookedKey) ?? 0;
    await prefs.setDouble(_revenueBookedKey, revenue + amountInr);
    await prefs.setString(_lastPreferenceKey, paymentMethod);
    await recordOrderCreated();

    final baseAmount = amountInr > 49 ? amountInr - 49 : amountInr;
    final platform = baseAmount * 0.08;
    final service = baseAmount * 0.02;
    final fulfillment = amountInr > 49 ? 49 * 0.4 : 0;

    final platformCurrent = prefs.getDouble(_platformEarningsKey) ?? 0;
    final serviceCurrent = prefs.getDouble(_serviceEarningsKey) ?? 0;
    final fulfillmentCurrent = prefs.getDouble(_fulfillmentEarningsKey) ?? 0;
    await prefs.setDouble(_platformEarningsKey, platformCurrent + platform);
    await prefs.setDouble(_serviceEarningsKey, serviceCurrent + service);
    await prefs.setDouble(_fulfillmentEarningsKey, fulfillmentCurrent + fulfillment);
    await _logFlowEvent(
      aspect: 'revenue',
      stage: 'conversion',
      action: 'order_placed',
      actorRole: 'customer',
      metadata: {
        'amount_inr': amountInr,
        'payment_method': paymentMethod,
        'booked_revenue_total': revenue + amountInr,
        'platform_earning': platform,
        'service_earning': service,
        'fulfillment_earning': fulfillment,
      },
    );
    await _logFlowEvent(
      aspect: 'erp',
      stage: 'order_to_cash',
      action: 'o2c_progressed',
      actorRole: 'customer',
    );
    await _maybeLogCompetitorEdgeMilestone();
  }

  Future<Map<String, double>> getRevenueModelSnapshot() async {
    final prefs = await _prefs;
    final gross = prefs.getDouble(_revenueBookedKey) ?? 0;
    final platform = prefs.getDouble(_platformEarningsKey) ?? 0;
    final service = prefs.getDouble(_serviceEarningsKey) ?? 0;
    final fulfillment = prefs.getDouble(_fulfillmentEarningsKey) ?? 0;
    return {
      'gross_value': gross,
      'platform_earnings': platform,
      'service_earnings': service,
      'fulfillment_earnings': fulfillment,
      'net_earnings': platform + service + fulfillment,
    };
  }

  Future<void> recordOrderDelivered() async {
    final prefs = await _prefs;
    final current = prefs.getInt(_deliveredCountKey) ?? 0;
    await prefs.setInt(_deliveredCountKey, current + 1);
    await touchSession();
    await _logFlowEvent(
      aspect: 'crm',
      stage: 'retention',
      action: 'order_delivered',
      actorRole: 'customer',
      metadata: {
        'delivered_count': current + 1,
      },
    );
    await _maybeLogCompetitorEdgeMilestone();
  }

  Future<void> recordAdminScmAction({String action = 'scm_update'}) async {
    final prefs = await _prefs;
    final current = prefs.getInt(_adminScmActionsKey) ?? 0;
    await prefs.setInt(_adminScmActionsKey, current + 1);
    await prefs.setString(_lastPreferenceKey, action);
    await touchSession();
    await _logFlowEvent(
      aspect: 'scm',
      stage: 'execution',
      action: action,
      actorRole: 'admin',
      metadata: {
        'admin_scm_actions': current + 1,
      },
    );
    await _maybeLogCompetitorEdgeMilestone();
  }

  Future<void> recordAdminErpAction({String action = 'erp_update'}) async {
    final prefs = await _prefs;
    final current = prefs.getInt(_adminErpActionsKey) ?? 0;
    await prefs.setInt(_adminErpActionsKey, current + 1);
    await prefs.setString(_lastPreferenceKey, action);
    await touchSession();
    await _logFlowEvent(
      aspect: 'erp',
      stage: 'execution',
      action: action,
      actorRole: 'admin',
      metadata: {
        'admin_erp_actions': current + 1,
      },
    );
    await _maybeLogCompetitorEdgeMilestone();
  }

  Future<void> updateScmSignal({
    required String demandPattern,
    required double stockHealth,
    required double leadTimeDays,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_lastScmPatternKey, demandPattern);
    await prefs.setDouble(_lastStockHealthKey, stockHealth);
    await prefs.setDouble(_lastLeadTimeKey, leadTimeDays);
    await touchSession();
    await _logFlowEvent(
      aspect: 'scm',
      stage: _deriveScmMode(demandPattern, stockHealth, leadTimeDays).toLowerCase(),
      action: 'scm_signal_updated',
      actorRole: 'system',
      metadata: {
        'demand_pattern': demandPattern,
        'stock_health': stockHealth,
        'lead_time_days': leadTimeDays,
      },
    );
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

  Future<List<ReactivationCampaign>> getReactivationCampaigns({
    bool refresh = true,
  }) async {
    final prefs = await _prefs;
    var queue = _readCampaignQueue(prefs.getString(_reactivationCampaignQueueKey));

    if (refresh) {
      final generated = await _generateReactivationCampaignIfEligible();
      if (generated != null && queue.every((c) => c.id != generated.id)) {
        queue = [generated, ...queue];
        await _saveCampaignQueue(queue);
      }
    }

    return queue;
  }

  Future<void> recordCampaignOpened(String campaignId) async {
    final prefs = await _prefs;
    final current = prefs.getInt(_campaignOpenCountKey) ?? 0;
    await prefs.setInt(_campaignOpenCountKey, current + 1);
    await _logFlowEvent(
      aspect: 'crm',
      stage: 'retention',
      action: 'reactivation_campaign_opened',
      actorRole: 'customer',
      metadata: {
        'campaign_id': campaignId,
        'open_count': current + 1,
      },
    );
  }

  Future<void> recordCampaignConverted(String campaignId, String conversionAction) async {
    final prefs = await _prefs;
    final current = prefs.getInt(_campaignConversionCountKey) ?? 0;
    await prefs.setInt(_campaignConversionCountKey, current + 1);

    final queue = _readCampaignQueue(prefs.getString(_reactivationCampaignQueueKey));
    final updated = queue.where((c) => c.id != campaignId).toList();
    await _saveCampaignQueue(updated);

    await _logFlowEvent(
      aspect: 'crm',
      stage: 'retention',
      action: 'reactivation_campaign_converted',
      actorRole: 'customer',
      metadata: {
        'campaign_id': campaignId,
        'conversion_action': conversionAction,
        'conversion_count': current + 1,
      },
    );
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

  Future<String> getCrmLifecycleStage() async {
    final prefs = await _prefs;
    final onboardingDone = prefs.getBool(_onboardingCompletedKey) ?? false;
    final interactions = prefs.getInt(_interactionCountKey) ?? 0;
    final requests = prefs.getInt(_requestCountKey) ?? 0;
    final orders = prefs.getInt(_orderCountKey) ?? 0;
    final delivered = prefs.getInt(_deliveredCountKey) ?? 0;

    if (!onboardingDone) return 'selection';
    if (orders == 0 && (interactions > 0 || requests > 0)) return 'acquisition';
    if (orders > 0 && delivered == 0) return 'conversion';
    if (delivered > 0 && orders < 3) return 'retention';
    return 'loyalty';
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
    final stage = await getCrmLifecycleStage();
    final playbook = await getFlowPlaybook(role: 'customer');

    if (lowStock) {
      messages.add('Hurry! Limited availability');
    }

    if (stage == 'selection') {
      messages.add('Complete onboarding and set your project intent to start your CRM journey.');
    } else if (stage == 'acquisition') {
      messages.add('Create your first material request to move from acquisition to conversion.');
    } else if (stage == 'conversion') {
      messages.add('You are close to order completion. Finish checkout to unlock retention nudges.');
    } else if (stage == 'retention') {
      messages.add('Track lifecycle and order updates to maintain retention health.');
    } else {
      messages.add('You reached loyalty stage. Explore rewards and referrals.');
    }

    messages.add('SCM mode now: ${playbook.scmMode}. Next operation: ${playbook.scmNextAction}');
    messages.add('ERP focus: ${playbook.erpPriorityModule}');
    messages.add('Revenue signal: ${playbook.revenueInsight}');

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

  Future<ReactivationCampaign?> _generateReactivationCampaignIfEligible() async {
    final prefs = await _prefs;
    final lastActiveRaw = prefs.getString(_lastActiveKey);
    final lastActive = DateTime.tryParse(lastActiveRaw ?? '');
    if (lastActive == null) return null;

    final inactiveHours = DateTime.now().difference(lastActive).inHours;
    if (inactiveHours < 24) return null;

    final lastGeneratedRaw = prefs.getString(_campaignLastGeneratedKey);
    final lastGenerated = DateTime.tryParse(lastGeneratedRaw ?? '');
    if (lastGenerated != null && DateTime.now().difference(lastGenerated).inHours < 6) {
      return null;
    }

    final channel = await _getTopAcquisitionChannel();
    final severity = inactiveHours >= 168
        ? 'high'
        : inactiveHours >= 72
            ? 'medium'
            : 'low';

    final route = _routeForAcquisitionChannel(channel);
    final title = severity == 'high'
        ? 'We saved your project flow'
        : severity == 'medium'
            ? 'Your materials may run out soon'
            : 'Continue where you paused';
    final message = 'Come back via ${channel.replaceAll('_', ' ')} and complete your next step.';

    final campaign = ReactivationCampaign(
      id: 'cmp-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      channel: channel,
      route: route,
      severity: severity,
      createdAtIso: DateTime.now().toIso8601String(),
    );

    await prefs.setString(_campaignLastGeneratedKey, DateTime.now().toIso8601String());
    await _logFlowEvent(
      aspect: 'crm',
      stage: 'retention',
      action: 'reactivation_campaign_created',
      actorRole: 'system',
      metadata: {
        'campaign_id': campaign.id,
        'channel': channel,
        'severity': severity,
        'inactive_hours': inactiveHours,
      },
    );
    return campaign;
  }

  Future<String> _getTopAcquisitionChannel() async {
    final prefs = await _prefs;
    final map = _readIntMap(prefs.getString(_acquisitionMapKey));
    if (map.isEmpty) return 'shop_discovery';
    final top = map.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key;
  }

  String _routeForAcquisitionChannel(String channel) {
    switch (channel) {
      case 'request_creation':
      case 'request_intent':
        return '/requests';
      case 'donation_intent':
        return '/capture';
      case 'order_followup':
        return '/orders';
      case 'project_recommendation':
      case 'onboarding_complete':
      case 'shop_discovery':
      default:
        return '/shop';
    }
  }

  List<ReactivationCampaign> _readCampaignQueue(String? raw) {
    if (raw == null || raw.isEmpty) return <ReactivationCampaign>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <ReactivationCampaign>[];

    return decoded
        .whereType<Map>()
        .map((e) => ReactivationCampaign.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _saveCampaignQueue(List<ReactivationCampaign> campaigns) async {
    final prefs = await _prefs;
    await prefs.setString(
      _reactivationCampaignQueueKey,
      jsonEncode(campaigns.map((c) => c.toJson()).toList()),
    );
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

  Future<FlowPlaybook> getFlowPlaybook({required String role}) async {
    final prefs = await _prefs;
    final stage = await getCrmLifecycleStage();

    final orders = prefs.getInt(_orderCountKey) ?? 0;
    final requests = prefs.getInt(_requestCountKey) ?? 0;
    final delivered = prefs.getInt(_deliveredCountKey) ?? 0;
    final interactions = prefs.getInt(_interactionCountKey) ?? 0;
    final revenue = prefs.getDouble(_revenueBookedKey) ?? 0;
    final scmPattern = prefs.getString(_lastScmPatternKey) ?? 'mixed';
    final stockHealth = prefs.getDouble(_lastStockHealthKey) ?? 70;
    final leadTime = prefs.getDouble(_lastLeadTimeKey) ?? 4;
    final adminScmActions = prefs.getInt(_adminScmActionsKey) ?? 0;
    final adminErpActions = prefs.getInt(_adminErpActionsKey) ?? 0;

    final crmNextAction = switch (stage) {
      'selection' => 'Capture customer intent through onboarding and recommendations.',
      'acquisition' => 'Convert intent by creating request or adding cart items.',
      'conversion' => 'Complete checkout and payment verification.',
      'retention' => 'Run reminders, support SLA, and repeat-order nudges.',
      _ => 'Launch loyalty and advocacy loops.',
    };

    final scmMode = _deriveScmMode(scmPattern, stockHealth, leadTime);
    final scmNextAction = switch (scmMode) {
      'Pull' => 'Use demand-triggered replenishment for volatile demand.',
      'Push' => 'Lock forecast batches and planned replenishment windows.',
      _ => 'Run push baseline with pull buffer for spikes.',
    };

    final erpPriorityModule = role == 'admin'
        ? (adminScmActions <= adminErpActions ? 'Procurement and Inventory Control' : 'Order-to-Cash and Finance Control')
        : (requests > orders ? 'Request-to-Order Conversion' : 'Order Fulfillment Tracking');

    final revenueInsight = revenue <= 0
        ? 'No revenue booked yet. Drive first conversion.'
        : 'Booked revenue: INR ${revenue.toStringAsFixed(0)} from $orders orders.';

    final competitorEdge = _buildCompetitorEdge(
      interactions: interactions,
      requests: requests,
      orders: orders,
      delivered: delivered,
      adminScmActions: adminScmActions,
      adminErpActions: adminErpActions,
    );

    return FlowPlaybook(
      crmStage: stage,
      crmNextAction: crmNextAction,
      scmMode: scmMode,
      scmNextAction: scmNextAction,
      erpPriorityModule: erpPriorityModule,
      revenueInsight: revenueInsight,
      competitorEdge: competitorEdge,
    );
  }

  String _deriveScmMode(String pattern, double stockHealth, double leadTime) {
    if (pattern == 'spike' || stockHealth < 45 || leadTime > 8) return 'Pull';
    if (pattern == 'predictable' && stockHealth > 70 && leadTime <= 5) return 'Push';
    return 'Hybrid';
  }

  String _buildCompetitorEdge({
    required int interactions,
    required int requests,
    required int orders,
    required int delivered,
    required int adminScmActions,
    required int adminErpActions,
  }) {
    if (orders > 0 && requests > 0 && adminScmActions > 0 && adminErpActions > 0) {
      return 'End-to-end closed loop: CRM to SCM to ERP execution in one platform.';
    }
    if (interactions > 0 && requests > 0) {
      return 'Connected journey: user intent is linked to operational demand signals.';
    }
    if (delivered > 0) {
      return 'Lifecycle progression is measurable beyond simple listing flows.';
    }
    return 'Differentiator is building: connect onboarding, requests, checkout, and admin operations.';
  }

  Future<void> _logFlowEvent({
    required String aspect,
    required String action,
    required String actorRole,
    String? stage,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('business_flow_events').insert({
        'actor_user_id': user.id,
        'actor_role': actorRole,
        'aspect': aspect,
        'stage': stage,
        'action': action,
        'metadata': metadata ?? <String, dynamic>{},
      });
    } catch (_) {
      // Keep the flow resilient even if timeline logging fails.
    }
  }

  Future<void> _maybeLogCompetitorEdgeMilestone() async {
    final prefs = await _prefs;
    final interactions = prefs.getInt(_interactionCountKey) ?? 0;
    final requests = prefs.getInt(_requestCountKey) ?? 0;
    final orders = prefs.getInt(_orderCountKey) ?? 0;
    final adminScmActions = prefs.getInt(_adminScmActionsKey) ?? 0;
    final adminErpActions = prefs.getInt(_adminErpActionsKey) ?? 0;

    int milestone = 0;
    if (interactions > 0 && requests > 0) {
      milestone = 1;
    }
    if (milestone == 1 && orders > 0) {
      milestone = 2;
    }
    if (milestone == 2 && adminScmActions > 0 && adminErpActions > 0) {
      milestone = 3;
    }

    final previous = prefs.getInt(_competitorEdgeMilestoneKey) ?? 0;
    if (milestone > previous) {
      await prefs.setInt(_competitorEdgeMilestoneKey, milestone);
      await _logFlowEvent(
        aspect: 'competitor',
        stage: 'milestone_$milestone',
        action: 'competitor_edge_strengthened',
        actorRole: 'system',
        metadata: {
          'milestone': milestone,
        },
      );
    }
  }
}

class FlowPlaybook {
  final String crmStage;
  final String crmNextAction;
  final String scmMode;
  final String scmNextAction;
  final String erpPriorityModule;
  final String revenueInsight;
  final String competitorEdge;

  const FlowPlaybook({
    required this.crmStage,
    required this.crmNextAction,
    required this.scmMode,
    required this.scmNextAction,
    required this.erpPriorityModule,
    required this.revenueInsight,
    required this.competitorEdge,
  });
}

class ReactivationCampaign {
  final String id;
  final String title;
  final String message;
  final String channel;
  final String route;
  final String severity;
  final String createdAtIso;

  const ReactivationCampaign({
    required this.id,
    required this.title,
    required this.message,
    required this.channel,
    required this.route,
    required this.severity,
    required this.createdAtIso,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'channel': channel,
      'route': route,
      'severity': severity,
      'createdAtIso': createdAtIso,
    };
  }

  factory ReactivationCampaign.fromJson(Map<String, dynamic> json) {
    return ReactivationCampaign(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      channel: (json['channel'] ?? '').toString(),
      route: (json['route'] ?? '/shop').toString(),
      severity: (json['severity'] ?? 'low').toString(),
      createdAtIso: (json['createdAtIso'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }
}
