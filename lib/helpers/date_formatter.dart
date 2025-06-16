import 'package:intl/intl.dart';

/// Helper class for formatting dates in various formats including Kanji
class DateFormatter {
  /// Format date in normal format (YYYY/MM/DD HH:mm)
  static String formatNormal(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return formatter.format(date);
  }

  /// Format date in Kanji format (令和X年X月X日 X時X分)
  static String formatKanji(DateTime date) {
    // Convert to Japanese era (Reiwa era started May 1, 2019)
    final reiwaStartDate = DateTime(2019, 5, 1);
    String eraPrefix;
    int eraYear;
    
    if (date.isAfter(reiwaStartDate) || date.isAtSameMomentAs(reiwaStartDate)) {
      eraYear = date.year - 2018; // Reiwa 1 = 2019
      eraPrefix = '令和';
    } else {
      // Heisei era (for dates before Reiwa)
      eraYear = date.year - 1988; // Heisei 1 = 1989
      eraPrefix = '平成';
    }
    
    return '$eraPrefix${_convertToKanjiNumber(eraYear)}年'
           '${_convertToKanjiNumber(date.month)}月'
           '${_convertToKanjiNumber(date.day)}日 '
           '${_convertToKanjiNumber(date.hour)}時'
           '${_convertToKanjiNumber(date.minute)}分';
  }

  /// Convert number to Kanji numerals
  static String _convertToKanjiNumber(int number) {
    if (number == 0) return '〇';
    
    const kanjiDigits = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
    
    if (number < 10) {
      return kanjiDigits[number];
    }
    
    if (number < 20) {
      if (number == 10) return '十';
      return '十${kanjiDigits[number % 10]}';
    }
    
    if (number < 100) {
      final tens = number ~/ 10;
      final ones = number % 10;
      return '${kanjiDigits[tens]}十${ones > 0 ? kanjiDigits[ones] : ''}';
    }
    
    // For larger numbers, use a simpler approach
    return number.toString();
  }

  /// Format date with both normal and Kanji formats
  static Map<String, String> formatBoth(DateTime date) {
    return {
      'normal': formatNormal(date),
      'kanji': formatKanji(date),
    };
  }
}
