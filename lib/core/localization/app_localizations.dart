import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Application-wide internationalization & localization class.
///
/// Supports English (`en`), Amharic (`am`), and Afaan Oromo (`om`).
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('am'),
    Locale('om'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'EthioLiner',
      'appTagline': 'Ethiopian Intercity Bus Booking',
      'home': 'Home',
      'search': 'Search',
      'myTrips': 'My Trips',
      'profile': 'Profile',
      'searchTrips': 'Search Trips',
      'fromCity': 'From',
      'toCity': 'To',
      'selectOrigin': 'Select departure city',
      'selectDestination': 'Select destination city',
      'departureDate': 'Departure Date',
      'passengers': 'Passengers',
      'selectSeats': 'Select Seats',
      'passengerDetails': 'Passenger Details',
      'bookingSummary': 'Booking Summary',
      'proceedToPayment': 'Proceed to Payment',
      'boardPass': 'Digital Boarding Pass',
      'operatorPortal': 'Operator Portal',
      'scanQr': 'Scan Boarding QR',
      'manifest': 'Passenger Manifest',
      'language': 'Language (ቋንቋ)',
      'offlineMode': 'Offline Mode',
      'seatsAvailable': 'seats available',
      'etb': 'ETB',
      'telebirr': 'Telebirr',
      'cbeBirr': 'CBE Birr',
      'awashBirr': 'Awash Birr',
      'cashOnBoard': 'Cash on Boarding',
    },
    'am': {
      'appName': 'ኢትዮላይነር',
      'appTagline': 'የኢትዮጵያ የከተሞች አውቶቡስ ትኬት መቁረጫ',
      'home': 'ዋና ገጽ',
      'search': 'ፈልግ',
      'myTrips': 'ጉዞዎቼ',
      'profile': 'መለያዬ',
      'searchTrips': 'አውቶቡስ ፈልግ',
      'fromCity': 'መነሻ',
      'toCity': 'መድረሻ',
      'selectOrigin': 'የመነሻ ከተማ ይምረጡ',
      'selectDestination': 'የመድረሻ ከተማ ይምረጡ',
      'departureDate': 'የጉዞ ቀን',
      'passengers': 'ተሳፋሪዎች',
      'selectSeats': 'ወንበር ይምረጡ',
      'passengerDetails': 'የተሳፋሪ መረጃ',
      'bookingSummary': 'የቦታ ማስያዣ ማጠቃለያ',
      'proceedToPayment': 'ወደ ክፍያ ይቀጥሉ',
      'boardPass': 'ዲጂታል የጉዞ ትኬት',
      'operatorPortal': 'የኦፕሬተር መድረክ',
      'scanQr': 'ትኬት በQR ይቃኙ',
      'manifest': 'የተሳፋሪዎች ዝርዝር',
      'language': 'ቋንቋ (Language)',
      'offlineMode': 'ከመስመር ውጭ (ኦፍላይን)',
      'seatsAvailable': 'ክፍት ወንበሮች',
      'etb': 'ብር',
      'telebirr': 'ቴሌብር',
      'cbeBirr': 'ሲቢኢ ብር',
      'awashBirr': 'አዋሽ ብር',
      'cashOnBoard': 'በአውቶቡስ ላይ በጥሬ ገንዘብ',
    },
    'om': {
      'appName': 'ItoophiyoLaayiner',
      'appTagline': 'Tikaata Baasii Magaalota Gidduu Itoophiyaa',
      'home': 'Fuula Duraa',
      'search': 'Barbaadi',
      'myTrips': 'Imala Koo',
      'profile': 'Eenyummaa',
      'searchTrips': 'Baasii Barbaadi',
      'fromCity': 'Ka\'umsa',
      'toCity': 'Geessisa',
      'selectOrigin': 'Magaalaa ka\'umsaa filadhu',
      'selectDestination': 'Magaalaa geessisaa filadhu',
      'departureDate': 'Guyyaa Imalaa',
      'passengers': 'Imaltoota',
      'selectSeats': 'Teessoo Filadhu',
      'passengerDetails': 'Oodeeffannoo Imaltuu',
      'bookingSummary': 'Cuunfaa Bakka Qabachuu',
      'proceedToPayment': 'Gara Kaffaltiitti Darbi',
      'boardPass': 'Tikaata Dijitaalaa',
      'operatorPortal': 'Kutaa Hojjataa',
      'scanQr': 'QR Tikaataa Iskaan Godhi',
      'manifest': 'Tarree Imaltootaa',
      'language': 'Afaan (Language)',
      'offlineMode': 'Sararaarraan Alatti (Offline)',
      'seatsAvailable': 'teessoo banaa',
      'etb': 'Qarshii',
      'telebirr': 'Telebirr',
      'cbeBirr': 'CBE Birr',
      'awashBirr': 'Awaash Birr',
      'cashOnBoard': 'Qarshii Baasicha Keessatti',
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String get appName => translate('appName');
  String get appTagline => translate('appTagline');
  String get home => translate('home');
  String get search => translate('search');
  String get myTrips => translate('myTrips');
  String get profile => translate('profile');
  String get searchTrips => translate('searchTrips');
  String get fromCity => translate('fromCity');
  String get toCity => translate('toCity');
  String get selectOrigin => translate('selectOrigin');
  String get selectDestination => translate('selectDestination');
  String get departureDate => translate('departureDate');
  String get passengers => translate('passengers');
  String get selectSeats => translate('selectSeats');
  String get passengerDetails => translate('passengerDetails');
  String get bookingSummary => translate('bookingSummary');
  String get proceedToPayment => translate('proceedToPayment');
  String get boardPass => translate('boardPass');
  String get operatorPortal => translate('operatorPortal');
  String get scanQr => translate('scanQr');
  String get manifest => translate('manifest');
  String get language => translate('language');
  String get offlineMode => translate('offlineMode');
  String get seatsAvailable => translate('seatsAvailable');
  String get etb => translate('etb');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am', 'om'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
