import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_storage.dart';

/// State notifier managing active application locale (en, am, om).
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._storage) : super(const Locale('en')) {
    _loadSavedLocale();
  }

  final LocalStorage _storage;

  Future<void> _loadSavedLocale() async {
    final savedCode = await _storage.getString(LocalStorage.keyLocale);
    if (savedCode != null && ['en', 'am', 'om'].contains(savedCode)) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (['en', 'am', 'om'].contains(newLocale.languageCode)) {
      state = newLocale;
      await _storage.saveString(LocalStorage.keyLocale, newLocale.languageCode);
    }
  }

  String get languageDisplayName {
    switch (state.languageCode) {
      case 'am':
        return 'አማርኛ (Amharic)';
      case 'om':
        return 'Afaan Oromoo';
      default:
        return 'English';
    }
  }
}

/// Provider for app locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(localStorageProvider);
  return LocaleNotifier(storage);
});
