/// Robust Gregorian <-> Ethiopian (Ge'ez) Calendar conversion & formatting utility.
///
/// Ethiopian Calendar characteristics:
/// - 12 months of 30 days each.
/// - 13th intercalary month called Pagumē (5 days in common years, 6 days in leap years).
/// - Ethiopian New Year (Enkutatash) begins on September 11 (or Sept 12 before Gregorian leap year).
/// - 7-8 years behind the Gregorian calendar.
class EthiopianDate {
  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month; // 1-13
  final int day; // 1-30 (1-6 for Pagume)

  static const List<String> amharicMonths = [
    'መስከረም',
    'ጥቅምት',
    'ኅዳር',
    'ታኅሣሥ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዝያ',
    'ግንቦት',
    'ሰኔ',
    'ሐምሌ',
    'ነሐሴ',
    'ጳጉሜ',
  ];

  static const List<String> oromoMonths = [
    'Fulbaana',
    'Onkololeessa',
    'Sadaasa',
    'Muddee',
    'Amajjii',
    'Guraandhala',
    'Bitooteessa',
    'Ebla',
    'Caamsaa',
    'Waxabajjii',
    'Adooleessa',
    'Hagayya',
    'Qaammee',
  ];

  static const List<String> englishTransliteratedMonths = [
    'Meskerem',
    'Tikimt',
    'Hidar',
    'Tahsas',
    'Tir',
    'Yakatit',
    'Magabit',
    'Miyazya',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume',
  ];

  String get monthNameAmharic => amharicMonths[(month - 1).clamp(0, 12)];
  String get monthNameOromo => oromoMonths[(month - 1).clamp(0, 12)];
  String get monthNameEnglish => englishTransliteratedMonths[(month - 1).clamp(0, 12)];

  /// Converts a Gregorian [DateTime] into an [EthiopianDate].
  static EthiopianDate fromGregorian(DateTime date) {
    final gYear = date.year;
    final gMonth = date.month;
    final gDay = date.day;

    // Julian day count approximation for conversion
    final int a = (14 - gMonth) ~/ 12;
    final int y = gYear + 4800 - a;
    final int m = gMonth + 12 * a - 3;
    final int jdn = gDay + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;

    // Convert JDN to Ethiopian date
    const int ethEra = 1723856;
    final int r = (jdn - ethEra) % 1461;
    final int n = (r % 365) + 365 * (r ~/ 1460);

    final int ethYear = 4 * ((jdn - ethEra) ~/ 1461) + (r ~/ 365) - (r ~/ 1460);
    final int ethMonth = (n ~/ 30) + 1;
    final int ethDay = (n % 30) + 1;

    return EthiopianDate(
      year: ethYear,
      month: ethMonth,
      day: ethDay,
    );
  }

  /// Formats the date according to locale ('am', 'om', 'en').
  String format(String localeCode) {
    if (localeCode == 'am') {
      return '$monthNameAmharic $day, $year ዓ.ም';
    } else if (localeCode == 'om') {
      return '$monthNameOromo $day, $year A.L.I';
    } else {
      return '$monthNameEnglish $day, $year E.C.';
    }
  }

  @override
  String toString() => '$monthNameEnglish $day, $year E.C.';
}
