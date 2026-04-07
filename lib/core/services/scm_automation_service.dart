import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:reclaim/core/services/erp_crm_intelligence_service.dart';
import 'package:reclaim/core/services/inventory_service.dart';

class ScmAutomationService {
  static const _tasksKey = 'scm_automation_tasks_json';

  static final ScmAutomationService instance = ScmAutomationService._();

  ScmAutomationService._();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<ScmAutomationTask>> scanAndGetTasks({int threshold = 5}) async {
    final supabase = Supabase.instance.client;
    final inventory = InventoryService(supabase);
    final existing = await getTasks();
    final activeById = {
      for (final t in existing.where((t) => t.status == 'open')) t.materialId: t,
    };

    final lowStock = await inventory.getLowStockItems(threshold: threshold);
    final outOfStock = await inventory.getOutOfStockItems();

    final merged = <Map<String, dynamic>>[];
    merged.addAll(lowStock);
    merged.addAll(outOfStock);

    var changed = false;
    final tasks = [...existing];

    for (final material in merged) {
      final materialId = (material['id'] ?? '').toString();
      if (materialId.isEmpty || activeById.containsKey(materialId)) {
        continue;
      }

      final stock = (material['stock_quantity'] as num?)?.toInt() ?? 0;
      final title = (material['name'] ?? 'Unknown Material').toString();
      final recommendedQty = stock <= 0 ? 12 : (8 - stock).clamp(4, 12);
      final severity = stock <= 0 ? 'critical' : 'high';

      final task = ScmAutomationTask(
        materialId: materialId,
        materialName: title,
        currentStock: stock,
        recommendedRestockQty: recommendedQty,
        severity: severity,
        status: 'open',
        createdAtIso: DateTime.now().toIso8601String(),
      );

      tasks.add(task);
      changed = true;

      await ErpCrmIntelligenceService.instance.recordAdminScmAction(
        action: 'auto_low_stock_trigger',
      );
      await ErpCrmIntelligenceService.instance.updateScmSignal(
        demandPattern: 'spike',
        stockHealth: stock <= 0 ? 35 : 48,
        leadTimeDays: 7,
      );
    }

    if (changed) {
      await _saveTasks(tasks);
    }

    return tasks
        .where((t) => t.status == 'open')
        .toList()
      ..sort((a, b) => b.severityWeight.compareTo(a.severityWeight));
  }

  Future<List<ScmAutomationTask>> getTasks() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((e) => ScmAutomationTask.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> executeTask(ScmAutomationTask task) async {
    final supabase = Supabase.instance.client;
    final inventory = InventoryService(supabase);

    await inventory.restockMaterial(task.materialId, task.recommendedRestockQty);

    final existing = await getTasks();
    final updated = existing.map((t) {
      if (t.materialId != task.materialId || t.status != 'open') {
        return t;
      }
      return t.copyWith(
        status: 'executed',
        executedAtIso: DateTime.now().toIso8601String(),
      );
    }).toList();

    await _saveTasks(updated);

    await ErpCrmIntelligenceService.instance.recordAdminScmAction(
      action: 'auto_restock_executed',
    );
    await ErpCrmIntelligenceService.instance.recordAdminErpAction(
      action: 'inventory_restock_posted',
    );
  }

  Future<void> runPushPlan() async {
    await ErpCrmIntelligenceService.instance.updateScmSignal(
      demandPattern: 'predictable',
      stockHealth: 78,
      leadTimeDays: 4,
    );
    await ErpCrmIntelligenceService.instance.recordAdminScmAction(
      action: 'push_plan_executed',
    );
  }

  Future<void> runPullReplenishment() async {
    await ErpCrmIntelligenceService.instance.updateScmSignal(
      demandPattern: 'spike',
      stockHealth: 46,
      leadTimeDays: 7,
    );
    await ErpCrmIntelligenceService.instance.recordAdminScmAction(
      action: 'pull_replenishment_executed',
    );
  }

  Future<void> _saveTasks(List<ScmAutomationTask> tasks) async {
    final prefs = await _prefs;
    await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }
}

class ScmAutomationTask {
  final String materialId;
  final String materialName;
  final int currentStock;
  final int recommendedRestockQty;
  final String severity;
  final String status;
  final String createdAtIso;
  final String? executedAtIso;

  const ScmAutomationTask({
    required this.materialId,
    required this.materialName,
    required this.currentStock,
    required this.recommendedRestockQty,
    required this.severity,
    required this.status,
    required this.createdAtIso,
    this.executedAtIso,
  });

  int get severityWeight {
    switch (severity) {
      case 'critical':
        return 3;
      case 'high':
        return 2;
      default:
        return 1;
    }
  }

  ScmAutomationTask copyWith({
    String? status,
    String? executedAtIso,
  }) {
    return ScmAutomationTask(
      materialId: materialId,
      materialName: materialName,
      currentStock: currentStock,
      recommendedRestockQty: recommendedRestockQty,
      severity: severity,
      status: status ?? this.status,
      createdAtIso: createdAtIso,
      executedAtIso: executedAtIso ?? this.executedAtIso,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'currentStock': currentStock,
      'recommendedRestockQty': recommendedRestockQty,
      'severity': severity,
      'status': status,
      'createdAtIso': createdAtIso,
      'executedAtIso': executedAtIso,
    };
  }

  factory ScmAutomationTask.fromJson(Map<String, dynamic> json) {
    return ScmAutomationTask(
      materialId: (json['materialId'] ?? '').toString(),
      materialName: (json['materialName'] ?? '').toString(),
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      recommendedRestockQty: (json['recommendedRestockQty'] as num?)?.toInt() ?? 0,
      severity: (json['severity'] ?? 'medium').toString(),
      status: (json['status'] ?? 'open').toString(),
      createdAtIso: (json['createdAtIso'] ?? DateTime.now().toIso8601String()).toString(),
      executedAtIso: json['executedAtIso']?.toString(),
    );
  }
}
