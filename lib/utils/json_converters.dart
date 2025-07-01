/// Utility class for safe JSON type conversions
class JsonConverters {
  /// Safely converts a JSON value to int, handling both int and string inputs
  static int? safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// Safely converts a JSON value to double, handling various input types
  static double? safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely converts a JSON value to string
  static String? safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Safely converts a JSON value to bool
  static bool? safeBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is num) {
      return value != 0;
    }
    return null;
  }

  /// Safely converts a JSON value to DateTime
  static DateTime? safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Safely converts a JSON array to List<T>
  static List<T>? safeList<T>(dynamic value, T Function(dynamic) converter) {
    if (value == null) return null;
    if (value is! List) return null;
    
    try {
      return value.map((item) => converter(item)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Safely converts a JSON object to Map<String, dynamic>
  static Map<String, dynamic>? safeMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
