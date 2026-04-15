/// Application-wide constants.
class AppConstants {
  AppConstants._();

  /// App name.
  static const String appName = 'EthioLiner';

  /// App tagline.
  static const String appTagline = 'Ethiopian Intercity Bus Booking';

  /// Default page size for paginated lists.
  static const int defaultPageSize = 20;

  /// Minimum password length.
  static const int minPasswordLength = 8;

  /// Ethiopian phone number prefix.
  static const String ethiopianPhonePrefix = '+251';

  /// Seat reservation timeout in minutes.
  static const int seatReservationTimeoutMinutes = 10;

  /// Supported locales.
  static const List<String> supportedLocales = ['en', 'am', 'om'];

  /// Default locale.
  static const String defaultLocale = 'en';

  /// Ethiopian cities for demo data.
  static const List<String> ethiopianCities = [
    'Addis Ababa',
    'Adama',
    'Hawassa',
    'Bahir Dar',
    'Gondar',
    'Mekelle',
    'Dire Dawa',
    'Jimma',
    'Dessie',
    'Bishoftu',
  ];
}
