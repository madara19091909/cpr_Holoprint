import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/export_entry.dart';

class HistoryStore {
  static const _key = 'cpr_holoprint_exports_v1';

  static Future<List<ExportEntry>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawEntries = preferences.getStringList(_key) ?? <String>[];
    final entries = <ExportEntry>[];
    for (final raw in rawEntries) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          entries.add(ExportEntry.fromJson(decoded));
        }
      } on FormatException {
        // Ignore a corrupted history row without discarding the other rows.
      } on TypeError {
        // Ignore rows that no longer match the current history schema.
      }
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  static Future<void> add(ExportEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await load();
    final updated = <ExportEntry>[entry, ...entries]
        .take(60)
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await preferences.setStringList(_key, updated);
  }

  static Future<void> remove(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await load();
    final updated = entries
        .where((entry) => entry.id != id)
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await preferences.setStringList(_key, updated);
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
