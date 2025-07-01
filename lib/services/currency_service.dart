import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _currencyKey = 'selected_currency';
  static const String _defaultCurrency = 'JPY';
  
  // Supported currencies matching the onboarding list
  static const List<Map<String, dynamic>> supportedCurrencies = [
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'NGN', 'symbol': '₦', 'name': 'Nigerian Naira'},
    {'code': 'GHS', 'symbol': '₵', 'name': 'Ghanaian Cedi'},
  ];

  // Get the current selected currency from SharedPreferences
  static Future<String> getCurrentCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currencyKey) ?? _defaultCurrency;
    } catch (e) {
      return _defaultCurrency;
    }
  }

  // Set the current currency in SharedPreferences
  static Future<void> setCurrency(String currencyCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currencyCode);
    } catch (e) {
      // Handle error silently, fallback to default
    }
  }

  // Get currency symbol for a currency code
  static String getCurrencySymbol(String currencyCode) {
    final currency = supportedCurrencies.firstWhere(
      (currency) => currency['code'] == currencyCode,
      orElse: () => supportedCurrencies.first,
    );
    return currency['symbol'];
  }

  // Get currency name for a currency code
  static String getCurrencyName(String currencyCode) {
    final currency = supportedCurrencies.firstWhere(
      (currency) => currency['code'] == currencyCode,
      orElse: () => supportedCurrencies.first,
    );
    return currency['name'];
  }

  // Get currency icon widget (since ¥ and other currency symbols are text)
  static Widget getCurrencyIcon({
    String? currencyCode,
    double size = 24.0,
    Color? color,
  }) {
    final currency = currencyCode ?? _defaultCurrency;
    final symbol = getCurrencySymbol(currency);
    
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: size * 0.8, // Make symbol slightly smaller than container
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // Get currency icon for TextFormField prefix
  static Widget getFormFieldCurrencyIcon({
    String? currencyCode,
    Color? color,
  }) {
    final currency = currencyCode ?? _defaultCurrency;
    final symbol = getCurrencySymbol(currency);
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // Check if the current currency is Yen (for special formatting)
  static bool isYenCurrency(String currencyCode) {
    return currencyCode == 'JPY';
  }

  // Format price for display - JPY shows as integer, others with 1 decimal place
  static String formatPriceForDisplay(double price, String currencyCode) {
    if (isYenCurrency(currencyCode)) {
      // JPY: Display as integer (no decimal places)
      return price.toInt().toString();
    } else {
      // Other currencies: Display with 1 decimal place
      return price.toStringAsFixed(1);
    }
  }

  // Format price for API - JPY sends as .0, others with 1 decimal place
  static double formatPriceForApi(double price, String currencyCode) {
    if (isYenCurrency(currencyCode)) {
      // JPY: Send as integer with .0 (e.g., 2.0)
      return price.roundToDouble();
    } else {
      // Other currencies: Send with 1 decimal place (e.g., 2.2)
      return double.parse(price.toStringAsFixed(1));
    }
  }

  // Parse input string to double with currency-specific formatting
  static double? parsePrice(String input, String currencyCode) {
    if (input.isEmpty) return null;
    
    try {
      final parsed = double.parse(input);
      if (isYenCurrency(currencyCode)) {
        // JPY: Round to whole number
        return parsed.roundToDouble();
      } else {
        // Other currencies: Keep 1 decimal place
        return double.parse(parsed.toStringAsFixed(1));
      }
    } catch (e) {
      return null;
    }
  }

  // Format for display with currency symbol
  static String formatPriceWithSymbol(double price, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    final formattedPrice = formatPriceForDisplay(price, currencyCode);
    return '$symbol$formattedPrice';
  }

  // Initialize currency service (call this in main.dart or app startup)
  static Future<void> initialize() async {
    // Ensure default currency is set if none exists
    final currentCurrency = await getCurrentCurrency();
    if (currentCurrency == _defaultCurrency) {
      await setCurrency(_defaultCurrency);
    }
  }
}
