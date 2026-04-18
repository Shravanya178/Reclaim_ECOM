import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum VoiceType { feedback, complaint }

class VoiceEntry {
  final String id;
  final VoiceType type;
  final String customer;
  final String material;
  final String message;
  final String severity;
  final int rating;
  final bool resolved;
  final DateTime createdAt;

  const VoiceEntry({
    required this.id,
    required this.type,
    required this.customer,
    required this.material,
    required this.message,
    required this.severity,
    required this.rating,
    required this.resolved,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'customer': customer,
      'material': material,
      'message': message,
      'severity': severity,
      'rating': rating,
      'resolved': resolved,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VoiceEntry.fromJson(Map<String, dynamic> json) {
    final parsedType = (json['type'] ?? 'feedback').toString() == 'complaint'
        ? VoiceType.complaint
        : VoiceType.feedback;
    return VoiceEntry(
      id: (json['id'] ?? '').toString(),
      type: parsedType,
      customer: (json['customer'] ?? 'Unknown User').toString(),
      material: (json['material'] ?? 'General Material').toString(),
      message: (json['message'] ?? '').toString(),
      severity: (json['severity'] ?? 'Medium').toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      resolved: (json['resolved'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  VoiceEntry copyWith({bool? resolved}) {
    return VoiceEntry(
      id: id,
      type: type,
      customer: customer,
      material: material,
      message: message,
      severity: severity,
      rating: rating,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt,
    );
  }
}

class CustomerVoiceService {
  static final CustomerVoiceService instance = CustomerVoiceService._();

  static const _seededKey = 'voice_seeded_v2';
  static const _entriesKey = 'voice_entries_json_v2';
  static const _discountKey = 'voice_material_discounts_json_v2';

  CustomerVoiceService._();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  static const List<String> _seedMaterials = [
    'Copper Wire Batch CW-14',
    'PCB Salvage Kit PK-22',
    'Glassware Bundle GB-09',
    'Arduino Uno Rev3',
    'Copper Wire Spool 1kg',
    'Borosilicate Flask 500ml',
    'LED Strip 5m RGB',
  ];

  static const List<String> _feedbackTemplates = [
    'Material quality is reliable for this project.',
    'Delivery was smooth and updates were clear.',
    'Packaging was safe and easy to handle.',
    'Request-to-checkout flow felt fast.',
    'Supplier communication helped close the order quickly.',
  ];

  static const List<String> _complaintTemplates = [
    'Quantity mismatch found during intake.',
    'Supplier response was delayed beyond expected SLA.',
    'Documentation upload failed during transfer.',
    'Quality check notes were not visible on order timeline.',
    'Discount promise was missing at checkout.',
  ];

  Future<void> ensureSeeded() async {
    final prefs = await _prefs;
    if (prefs.getBool(_seededKey) == true) {
      return;
    }

    final now = DateTime.now();
    final entries = <VoiceEntry>[];

    for (int i = 0; i < 72; i++) {
      entries.add(
        VoiceEntry(
          id: 'seed-feedback-$i',
          type: VoiceType.feedback,
          customer: 'User ${i + 1}',
          material: _seedMaterials[i % _seedMaterials.length],
          message: _feedbackTemplates[i % _feedbackTemplates.length],
          severity: 'Low',
          rating: (i % 4) + 2,
          resolved: true,
          createdAt: now.subtract(Duration(hours: i * 5)),
        ),
      );
    }

    for (int i = 0; i < 52; i++) {
      const severities = ['Critical', 'High', 'Moderate'];
      entries.add(
        VoiceEntry(
          id: 'seed-complaint-$i',
          type: VoiceType.complaint,
          customer: 'Customer ${i + 1}',
          material: _seedMaterials[i % _seedMaterials.length],
          message: _complaintTemplates[i % _complaintTemplates.length],
          severity: severities[i % severities.length],
          rating: 0,
          resolved: i % 5 == 0,
          createdAt: now.subtract(Duration(hours: i * 4 + 2)),
        ),
      );
    }

    await _saveEntries(entries);
    await prefs.setString(_discountKey, jsonEncode(<String, double>{}));
    await prefs.setBool(_seededKey, true);
  }

  Future<List<VoiceEntry>> getEntries() async {
    await ensureSeeded();
    final prefs = await _prefs;
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) {
      return const <VoiceEntry>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <VoiceEntry>[];
    }

    final list = decoded
        .whereType<Map>()
        .map((e) => VoiceEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<VoiceEntry>> getEntriesByType(VoiceType type) async {
    final all = await getEntries();
    return all.where((e) => e.type == type).toList();
  }

  Future<void> submitFeedback({
    required String customer,
    required String material,
    required String message,
    required int rating,
  }) async {
    final all = await getEntries();
    all.add(
      VoiceEntry(
        id: 'feedback-${DateTime.now().microsecondsSinceEpoch}',
        type: VoiceType.feedback,
        customer: customer,
        material: material,
        message: message,
        severity: 'Low',
        rating: rating.clamp(1, 5),
        resolved: true,
        createdAt: DateTime.now(),
      ),
    );
    await _saveEntries(all);
  }

  Future<void> submitComplaint({
    required String customer,
    required String material,
    required String message,
    required String severity,
  }) async {
    final normalizedSeverity = switch (severity.toLowerCase()) {
      'critical' => 'Critical',
      'high' => 'High',
      _ => 'Moderate',
    };

    final all = await getEntries();
    all.add(
      VoiceEntry(
        id: 'complaint-${DateTime.now().microsecondsSinceEpoch}',
        type: VoiceType.complaint,
        customer: customer,
        material: material,
        message: message,
        severity: normalizedSeverity,
        rating: 0,
        resolved: false,
        createdAt: DateTime.now(),
      ),
    );
    await _saveEntries(all);
  }

  Future<void> resolveComplaintById(String id) async {
    final all = await getEntries();
    final index = all.indexWhere((e) => e.id == id);
    if (index == -1) return;
    all[index] = all[index].copyWith(resolved: true);
    await _saveEntries(all);
  }

  Future<void> resolveOldestComplaintForMaterial(String material) async {
    final all = await getEntries();
    final unresolved = all
        .where(
          (e) =>
              e.type == VoiceType.complaint &&
              !e.resolved &&
              _materialMatches(e.material, material),
        )
        .toList();
    if (unresolved.isEmpty) return;

    unresolved.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final targetId = unresolved.first.id;
    final index = all.indexWhere((e) => e.id == targetId);
    if (index == -1) return;
    all[index] = all[index].copyWith(resolved: true);
    await _saveEntries(all);
  }

  Future<Map<String, int>> getThreeSectionCounts(VoiceType type) async {
    final list = await getEntriesByType(type);
    final buckets = {
      'Priority Escalations': 0,
      'Process Improvements': 0,
      'Positive Signals': 0,
    };

    for (final entry in list) {
      final bucket = _bucketForEntry(entry);
      buckets[bucket] = (buckets[bucket] ?? 0) + 1;
    }
    return buckets;
  }

  Future<bool> hasPositiveFeedbackForMaterial(String material) async {
    final feedback = await getEntriesByType(VoiceType.feedback);
    return feedback.any(
      (e) => _materialMatches(e.material, material) && e.rating >= 4,
    );
  }

  Future<void> setMaterialDiscount({
    required String material,
    required bool active,
    double percent = 12,
  }) async {
    await ensureSeeded();
    final prefs = await _prefs;
    final map = await getMaterialDiscountMap();
    final key = _normalizeMaterial(material);

    if (active) {
      map[key] = percent;
    } else {
      map.remove(key);
    }

    await prefs.setString(_discountKey, jsonEncode(map));
  }

  Future<Map<String, double>> getMaterialDiscountMap() async {
    await ensureSeeded();
    final prefs = await _prefs;
    final raw = prefs.getString(_discountKey);
    if (raw == null || raw.isEmpty) {
      return <String, double>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return <String, double>{};
    }

    final out = <String, double>{};
    decoded.forEach((key, value) {
      final v = (value as num?)?.toDouble();
      if (v != null) {
        out[key.toString()] = v;
      }
    });
    return out;
  }

  Future<double> discountPercentForProduct(String productName) async {
    final map = await getMaterialDiscountMap();
    final normalizedProduct = _normalizeMaterial(productName);
    final productTokens = normalizedProduct.split(' ').where((e) => e.isNotEmpty).toSet();

    double best = 0;
    for (final entry in map.entries) {
      final keyTokens = entry.key.split(' ').where((e) => e.isNotEmpty).toSet();
      final overlap = productTokens.intersection(keyTokens).length;
      if (overlap >= 2 || entry.key.contains(normalizedProduct) || normalizedProduct.contains(entry.key)) {
        if (entry.value > best) {
          best = entry.value;
        }
      }
    }
    return best;
  }

  Future<void> _saveEntries(List<VoiceEntry> entries) async {
    final prefs = await _prefs;
    final encoded = entries.map((e) => e.toJson()).toList(growable: false);
    await prefs.setString(_entriesKey, jsonEncode(encoded));
  }

  String _bucketForEntry(VoiceEntry entry) {
    if (entry.type == VoiceType.complaint) {
      final sev = entry.severity.toLowerCase();
      if (sev == 'critical' || sev == 'high') {
        return 'Priority Escalations';
      }
      return 'Process Improvements';
    }

    if (entry.rating >= 4) {
      return 'Positive Signals';
    }
    if (entry.rating <= 2) {
      return 'Priority Escalations';
    }
    return 'Process Improvements';
  }

  bool _materialMatches(String a, String b) {
    final na = _normalizeMaterial(a);
    final nb = _normalizeMaterial(b);
    if (na == nb) return true;
    if (na.contains(nb) || nb.contains(na)) return true;

    final ta = na.split(' ').where((e) => e.isNotEmpty).toSet();
    final tb = nb.split(' ').where((e) => e.isNotEmpty).toSet();
    return ta.intersection(tb).length >= 2;
  }

  String _normalizeMaterial(String value) {
    final cleaned = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned;
  }
}
