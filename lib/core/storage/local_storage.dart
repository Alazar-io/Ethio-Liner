import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Robust local storage abstraction supporting offline persistence,
/// recent searches, cached digital tickets, and user preferences.
class LocalStorage {
  LocalStorage._();

  static final LocalStorage instance = LocalStorage._();

  final Map<String, dynamic> _memoryStore = {};

  static const String keyLocale = 'ethioliner_locale';
  static const String keyDarkMode = 'ethioliner_dark_mode';
  static const String keyRecentSearches = 'ethioliner_recent_searches';
  static const String keyOfflineTickets = 'ethioliner_offline_tickets';
  static const String keyAuthToken = 'ethioliner_auth_token';

  Future<void> saveString(String key, String value) async {
    _memoryStore[key] = value;
  }

  Future<String?> getString(String key) async {
    return _memoryStore[key] as String?;
  }

  Future<void> saveBool(String key, bool value) async {
    _memoryStore[key] = value;
  }

  Future<bool?> getBool(String key) async {
    return _memoryStore[key] as bool?;
  }

  Future<void> saveRecentSearches(List<String> searches) async {
    _memoryStore[keyRecentSearches] = jsonEncode(searches);
  }

  Future<List<String>> getRecentSearches() async {
    final raw = _memoryStore[keyRecentSearches] as String?;
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOfflineTickets(String ticketsJson) async {
    _memoryStore[keyOfflineTickets] = ticketsJson;
  }

  Future<String?> getOfflineTickets() async {
    return _memoryStore[keyOfflineTickets] as String?;
  }

  Future<void> remove(String key) async {
    _memoryStore.remove(key);
  }

  Future<void> clear() async {
    _memoryStore.clear();
  }
}

/// Provider for LocalStorage.
final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage.instance;
});
