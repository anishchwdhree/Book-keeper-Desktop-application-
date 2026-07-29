/// Bikram Sambat (BS) / Nepali Date Converter
/// Converts Gregorian (AD) dates to Nepali BS dates.
///
/// Coverage: BS 2070 – 2090  (AD 2013 – 2034)
class NepaliDate {
  final int year;
  final int month;
  final int day;

  NepaliDate(this.year, this.month, this.day);

  /// Returns formatted string like "2083/04/06"
  String format() {
    return '${year.toString().padLeft(4, '0')}/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => format();

  // ── Static conversion ─────────────────────────────────────────────

  /// Convert a Gregorian [DateTime] to Nepali BS date.
  static NepaliDate fromDateTime(DateTime ad) {
    // Reference point: BS 2070/01/01 = AD 2013/04/14
    const int refBsYear = 2070;
    const int refBsMonth = 1;
    const int refBsDay = 1;
    final DateTime refAd = DateTime(2013, 4, 14);

    int totalDays = ad.difference(refAd).inDays;

    if (totalDays < 0) {
      // Date is before our reference, return fallback
      return NepaliDate(refBsYear, refBsMonth, refBsDay);
    }

    int bsYear = refBsYear;
    int bsMonth = refBsMonth;
    int bsDay = refBsDay;

    // Walk through years and months
    while (totalDays > 0) {
      final daysInMonth = bsDaysInMonth(bsYear, bsMonth);
      final daysLeftInMonth = daysInMonth - bsDay;

      if (totalDays <= daysLeftInMonth) {
        bsDay += totalDays;
        totalDays = 0;
      } else {
        totalDays -= (daysLeftInMonth + 1);
        bsMonth++;
        if (bsMonth > 12) {
          bsMonth = 1;
          bsYear++;
        }
        bsDay = 1;
      }
    }

    return NepaliDate(bsYear, bsMonth, bsDay);
  }

  /// Get today's Nepali date.
  static NepaliDate today() => fromDateTime(DateTime.now());

  /// Get today's Nepali date as a formatted string.
  static String todayFormatted() => today().format();

  /// Convert this Nepali BS date back to a Gregorian AD DateTime.
  DateTime toDateTime() {
    const int refBsYear = 2070;
    const int refBsMonth = 1;
    const int refBsDay = 1;
    final DateTime refAd = DateTime(2013, 4, 14);

    int totalDays = 0;

    // Count days from ref BS year/month/day to target BS year/month/day
    for (int y = refBsYear; y < year; y++) {
      for (int m = 1; m <= 12; m++) {
        totalDays += bsDaysInMonth(y, m);
      }
    }
    for (int m = refBsMonth; m < 12; m++) {
      totalDays += bsDaysInMonth(year, m);
    }
    totalDays += (day - refBsDay);

    return refAd.add(Duration(days: totalDays));
  }

  /// Nepali month names
  static const List<String> monthNames = [
    'Baisakh', 'Jestha', 'Ashadh', 'Shrawan', 'Bhadra', 'Ashwin',
    'Kartik', 'Mangsir', 'Poush', 'Magh', 'Falgun', 'Chaitra',
  ];

  // ── BS calendar data ──────────────────────────────────────────────

  /// Days in each month for BS years 2070 – 2090.
  /// Each entry is a list of 12 values (Baisakh to Chaitra).
  static const Map<int, List<int>> _bsMonthDays = {
    2070: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2071: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2072: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2073: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2074: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2075: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2076: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2077: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2078: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2079: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2080: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2081: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2082: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2083: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2084: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2085: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2086: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2087: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2088: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2089: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2090: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  };

  /// Returns the number of days in a given BS [year] and [month] (1-indexed).
  static int bsDaysInMonth(int year, int month) {
    if (_bsMonthDays.containsKey(year)) {
      return _bsMonthDays[year]![month - 1];
    }
    // Fallback for years outside our table
    return 30;
  }
}
