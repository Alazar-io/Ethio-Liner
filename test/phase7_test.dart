import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ethio_liner/core/localization/app_localizations.dart';
import 'package:ethio_liner/core/localization/locale_provider.dart';
import 'package:ethio_liner/core/storage/local_storage.dart';
import 'package:ethio_liner/core/utils/ethiopian_calendar.dart';
import 'package:ethio_liner/features/profile/presentation/profile_screen.dart';

void main() {
  group('Phase 7 - Ethiopian Calendar Conversion & Formatting', () {
    test('Converts Gregorian date to Ethiopian date correctly', () {
      // 2026-09-11 is Ethiopian New Year (Meskerem 1, 2019 E.C.)
      final gregorianEnkutatash = DateTime(2026, 9, 11);
      final ethDate = EthiopianDate.fromGregorian(gregorianEnkutatash);

      expect(ethDate.month, equals(1));
      expect(ethDate.day, equals(1));
      expect(ethDate.year, equals(2019));
      expect(ethDate.monthNameAmharic, equals('መስከረም'));
      expect(ethDate.monthNameOromo, equals('Fulbaana'));
      expect(ethDate.monthNameEnglish, equals('Meskerem'));
    });

    test('Formats Ethiopian date across locales', () {
      final ethDate = EthiopianDate.fromGregorian(DateTime(2026, 9, 11));

      expect(ethDate.format('am'), contains('መስከረም 1, 2019 ዓ.ም'));
      expect(ethDate.format('om'), contains('Fulbaana 1, 2019 A.L.I'));
      expect(ethDate.format('en'), contains('Meskerem 1, 2019 E.C.'));
    });

    test('Contains all 13 Ethiopian months in Amharic, Oromo, and English', () {
      expect(EthiopianDate.amharicMonths.length, equals(13));
      expect(EthiopianDate.oromoMonths.length, equals(13));
      expect(EthiopianDate.englishTransliteratedMonths.length, equals(13));

      expect(EthiopianDate.amharicMonths.last, equals('ጳጉሜ'));
      expect(EthiopianDate.oromoMonths.last, equals('Qaammee'));
      expect(EthiopianDate.englishTransliteratedMonths.last, equals('Pagume'));
    });
  });

  group('Phase 7 - Tri-Lingual Localization System', () {
    test('AppLocalizations supports en, am, and om', () {
      expect(AppLocalizations.supportedLocales.map((l) => l.languageCode), containsAll(['en', 'am', 'om']));
    });

    test('Translates core terms in English, Amharic, and Afaan Oromo', () {
      final l10nEn = AppLocalizations(const Locale('en'));
      final l10nAm = AppLocalizations(const Locale('am'));
      final l10nOm = AppLocalizations(const Locale('om'));

      expect(l10nEn.appName, equals('EthioLiner'));
      expect(l10nAm.appName, equals('ኢትዮላይነር'));
      expect(l10nOm.appName, equals('ItoophiyoLaayiner'));

      expect(l10nEn.searchTrips, equals('Search Trips'));
      expect(l10nAm.searchTrips, equals('አውቶቡስ ፈልግ'));
      expect(l10nOm.searchTrips, equals('Baasii Barbaadi'));

      expect(l10nEn.myTrips, equals('My Trips'));
      expect(l10nAm.myTrips, equals('ጉዞዎቼ'));
      expect(l10nOm.myTrips, equals('Imala Koo'));
    });
  });

  group('Phase 7 - LocalStorage & Offline Cache Persistence', () {
    test('LocalStorage stores and retrieves strings, booleans, and lists', () async {
      final storage = LocalStorage.instance;
      await storage.clear();

      // String storage
      await storage.saveString(LocalStorage.keyLocale, 'am');
      expect(await storage.getString(LocalStorage.keyLocale), equals('am'));

      // Boolean storage
      await storage.saveBool(LocalStorage.keyDarkMode, true);
      expect(await storage.getBool(LocalStorage.keyDarkMode), isTrue);

      // Recent searches
      final sampleSearches = ['Addis Ababa to Hawassa', 'Addis Ababa to Bahir Dar'];
      await storage.saveRecentSearches(sampleSearches);
      final retrieved = await storage.getRecentSearches();
      expect(retrieved, equals(sampleSearches));

      // Offline tickets
      const mockTicketsJson = '{"tickets": [{"id": "TCK-1", "seat": "3A"}]}';
      await storage.saveOfflineTickets(mockTicketsJson);
      expect(await storage.getOfflineTickets(), equals(mockTicketsJson));
    });
  });

  group('Phase 7 - Dynamic Locale Switching & UI', () {
    test('LocaleNotifier switches and persists language', () async {
      final storage = LocalStorage.instance;
      await storage.clear();

      final notifier = LocaleNotifier(storage);
      expect(notifier.state.languageCode, equals('en'));
      expect(notifier.languageDisplayName, equals('English'));

      await notifier.setLocale(const Locale('am'));
      expect(notifier.state.languageCode, equals('am'));
      expect(notifier.languageDisplayName, equals('አማርኛ (Amharic)'));

      await notifier.setLocale(const Locale('om'));
      expect(notifier.state.languageCode, equals('om'));
      expect(notifier.languageDisplayName, equals('Afaan Oromoo'));
    });

    testWidgets('ProfileScreen displays language selector and switches locale', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language (ቋንቋ)'), findsOneWidget);
      expect(find.text('About EthioLiner'), findsOneWidget);

      // Scroll to language tile and tap
      await tester.ensureVisible(find.text('Language (ቋንቋ)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Language (ቋንቋ)'));
      await tester.pumpAndSettle();

      // Verify modal sheet appears with 3 languages
      expect(find.text('Select Language / ቋንቋ ይምረጡ'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'English'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'አማርኛ (Amharic)'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Afaan Oromoo'), findsOneWidget);

      // Select Amharic
      await tester.tap(find.widgetWithText(ListTile, 'አማርኛ (Amharic)'));
      await tester.pumpAndSettle();

      // Modal closed and language updated
      expect(find.text('Select Language / ቋንቋ ይምረጡ'), findsNothing);
      expect(find.text('አማርኛ (Amharic)'), findsOneWidget);
    });
  });
}
