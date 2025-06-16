import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Format a number as currency with proper locale formatting
  /// 
  /// [amount] - The amount to format
  /// [currencyCode] - Currency code (e.g., 'USD', 'EUR', 'GBP', 'JPY')
  /// [locale] - Locale for formatting (defaults to currency-specific locale)
  static String format(double amount, {String currencyCode = 'JPY', String? locale}) {
    try {
      // Get the appropriate locale for the currency if not specified
      final formatLocale = locale ?? getLocaleForCurrency(currencyCode);
      
      // For Japanese Yen, use 0 decimal places and round down
      final decimalDigits = _getDecimalDigitsForCurrency(currencyCode);
      final formattedAmount = _formatAmountForCurrency(amount, currencyCode);
      
      final formatter = NumberFormat.currency(
        locale: formatLocale,
        symbol: _getCurrencySymbol(currencyCode),
        decimalDigits: decimalDigits,
      );
      return formatter.format(formattedAmount);
    } catch (e) {
      // Fallback to manual formatting with proper number separators
      return _fallbackFormat(amount, currencyCode);
    }
  }

  /// Get appropriate decimal digits for a currency
  static int _getDecimalDigitsForCurrency(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'JPY': // Japanese Yen - no decimals
      case 'KRW': // Korean Won - no decimals
        return 0;
      default:
        return 2;
    }
  }

  /// Format amount according to currency rules
  static double _formatAmountForCurrency(double amount, String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'JPY': // Japanese Yen - round down
      case 'KRW': // Korean Won - round down
        return amount.truncate().toDouble();
      default:
        return amount;
    }
  }

  /// Fallback formatting with manual number separators
  static String _fallbackFormat(double amount, String currencyCode) {
    final symbol = _getCurrencySymbol(currencyCode);
    final decimalDigits = _getDecimalDigitsForCurrency(currencyCode);
    final formattedAmount = _formatAmountForCurrency(amount, currencyCode);
    
    // Format with comma separators
    final formatter = NumberFormat('#,##0${decimalDigits > 0 ? '.${'0' * decimalDigits}' : ''}');
    return '$symbol${formatter.format(formattedAmount)}';
  }

  /// Format currency with compact notation for large numbers
  /// (e.g., ¥1.5K, $2.3M)
  static String formatCompact(double amount, {String currencyCode = 'JPY', String? locale}) {
    try {
      // Get the appropriate locale for the currency if not specified
      final formatLocale = locale ?? getLocaleForCurrency(currencyCode);
      
      // For currencies without decimals, use 0 decimal places in compact notation
      final decimalDigits = _getDecimalDigitsForCurrency(currencyCode) == 0 ? 0 : 1;
      final formattedAmount = _formatAmountForCurrency(amount, currencyCode);
      
      final formatter = NumberFormat.compactCurrency(
        locale: formatLocale,
        symbol: _getCurrencySymbol(currencyCode),
        decimalDigits: decimalDigits,
      );
      return formatter.format(formattedAmount);
    } catch (e) {
      // Fallback to manual compact formatting
      return _fallbackCompactFormat(amount, currencyCode);
    }
  }

  /// Fallback compact formatting
  static String _fallbackCompactFormat(double amount, String currencyCode) {
    final symbol = _getCurrencySymbol(currencyCode);
    final hasDecimals = _getDecimalDigitsForCurrency(currencyCode) > 0;
    final formattedAmount = _formatAmountForCurrency(amount, currencyCode);
    
    if (formattedAmount >= 1000000) {
      final value = formattedAmount / 1000000;
      return hasDecimals ? '$symbol${value.toStringAsFixed(1)}M' : '$symbol${value.truncate()}M';
    } else if (formattedAmount >= 1000) {
      final value = formattedAmount / 1000;
      return hasDecimals ? '$symbol${value.toStringAsFixed(1)}K' : '$symbol${value.truncate()}K';
    } else {
      final formatter = NumberFormat('#,##0${hasDecimals ? '.00' : ''}');
      return '$symbol${formatter.format(formattedAmount)}';
    }
  }

  /// Get currency symbol for a given currency code
  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'NGN':
        return '₦';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'KRW':
        return '₩';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'BRL':
        return 'R\$';
      case 'ZAR':
        return 'R';
      case 'GHS':
        return '₵';
      case 'KES':
        return 'KSh';
      case 'UGX':
        return 'USh';
      case 'TZS':
        return 'TSh';
      default:
        return currencyCode; // Use currency code as fallback
    }
  }

  /// Get locale string for a currency code (helps with proper number formatting)
  static String getLocaleForCurrency(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
      case 'CAD':
        return 'en_US';
      case 'EUR':
        return 'en_EU';
      case 'GBP':
        return 'en_GB';
      case 'NGN':
        return 'en_NG';
      case 'JPY':
        return 'ja_JP';
      case 'CNY':
        return 'zh_CN';
      case 'INR':
        return 'en_IN';
      case 'KRW':
        return 'ko_KR';
      case 'AUD':
        return 'en_AU';
      case 'BRL':
        return 'pt_BR';
      case 'ZAR':
        return 'en_ZA';
      case 'GHS':
        return 'en_GH';
      case 'KES':
        return 'en_KE';
      default:
        return 'en_US';
    }
  }
}
