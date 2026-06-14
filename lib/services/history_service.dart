import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum HistoryType { tos, phishing }

class HistoryEntry {
  final String id;
  final HistoryType type;
  final String input;
  final String resultSummary;
  final String riskLevel; // danger / warning / safe
  final DateTime createdAt;

  const HistoryEntry({
    required this.id,
    required this.type,
    required this.input,
    required this.resultSummary,
    required this.riskLevel,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'input': input,
        'resultSummary': resultSummary,
        'riskLevel': riskLevel,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        type: HistoryType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => HistoryType.tos,
        ),
        input: json['input'] as String,
        resultSummary: json['resultSummary'] as String,
        riskLevel: json['riskLevel'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class HistoryService {
  static const _key = 'analysis_history';
  static const _maxEntries = 20;

  static Future<void> save(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadRaw(prefs);
    list.insert(0, jsonEncode(entry.toJson()));
    if (list.length > _maxEntries) list.removeLast();
    await prefs.setStringList(_key, list);
  }

  static Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = await _loadRaw(prefs);
    return raw
        .map((s) {
          try {
            return HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<HistoryEntry>()
        .toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<List<String>> _loadRaw(SharedPreferences prefs) async =>
      List<String>.from(prefs.getStringList(_key) ?? []);
}
