import '../helpers/currency_formatter.dart';

/// Extension methods for formatting double values as currency
extension DoubleFormattingExtension on double {
  /// Format amount with currency symbol using proper locale formatting
  String formatAmount([String currency = '¥']) {
    final currencyCode = _getCurrencyCodeFromSymbol(currency);
    return CurrencyFormatter.format(this, currencyCode: currencyCode);
  }
}

/// Extension methods for formatting nullable double values as currency  
extension NullableDoubleFormattingExtension on double? {
  /// Format amount with currency symbol for nullable double using proper locale formatting
  String formatAmount([String currency = '¥']) {
    if (this == null) {
      final currencyCode = _getCurrencyCodeFromSymbol(currency);
      return CurrencyFormatter.format(0.0, currencyCode: currencyCode);
    }
    final currencyCode = _getCurrencyCodeFromSymbol(currency);
    return CurrencyFormatter.format(this!, currencyCode: currencyCode);
  }
}

/// Helper function to get currency code from symbol
String _getCurrencyCodeFromSymbol(String symbol) {
  switch (symbol) {
    case '¥':
      return 'JPY';
    case '\$':
      return 'USD';
    case '€':
      return 'EUR';
    case '£':
      return 'GBP';
    case '₦':
      return 'NGN';
    case '₵':
      return 'GHS';
    case '₹':
      return 'INR';
    case '₩':
      return 'KRW';
    default:
      return 'JPY'; // Default to JPY
  }
}