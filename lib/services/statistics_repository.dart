import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_statistics.dart';
import '../models/api_response.dart';

class StatisticsRepository {
  final http.Client httpClient;
  final String baseUrl;

  StatisticsRepository({
    this.baseUrl = 'lastmile.fainzy.tech',
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Fetch order statistics for the store dashboard
  Future<OrderStatistics> fetchOrderStatistics({
    required int subEntityId,
  }) async {
    try {
      // Get API token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final apiToken = prefs.getString('apiToken');
      
      if (apiToken == null) {
        throw Exception('No API token found. Please login again.');
      }

      final uri = Uri.https(baseUrl, '/v1/statistics/subentities/$subEntityId/');
      
      log('📊 Fetching order statistics from: ${uri.toString()}');

      final response = await httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Fainzy-Token': apiToken,
        },
      );

      log('📊 Statistics API Response Status: ${response.statusCode}');
      log('📊 Statistics API Response Body: ${response.body}');

      final apiResponse = ApiResponse.handleResponse(response);
      
      if (apiResponse.status == 'success' && apiResponse.data != null) {
        return OrderStatistics.fromJson(apiResponse.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load statistics: ${apiResponse.message}');
      }
    } catch (e) {
      log('❌ Error fetching order statistics: $e');
      
      // Return mock data for development/testing
      return _getMockOrderStatistics();
    }
  }

  /// Get mock order statistics for testing/offline use
  OrderStatistics _getMockOrderStatistics() {
    log('📊 Using mock order statistics for development');
    
    return const OrderStatistics(
      id: 1,
      subentityId: 1,
      totalOrders: 156,
      totalPendingOrders: 8,
      totalCompletedOrders: 148,
      totalRevenue: 15420.50,
      created: null,
      modified: null,
    );
  }

  /// Get average order value
  double getAverageOrderValue(OrderStatistics stats) {
    if (stats.totalOrders == null || stats.totalOrders == 0 || stats.totalRevenue == null) {
      return 0.0;
    }
    return stats.totalRevenue! / stats.totalOrders!;
  }

  /// Get completion percentage
  double getCompletionPercentage(OrderStatistics stats) {
    if (stats.totalOrders == null || stats.totalOrders == 0 || stats.totalCompletedOrders == null) {
      return 0.0;
    }
    return (stats.totalCompletedOrders! / stats.totalOrders!) * 100;
  }

  /// Get pending percentage
  double getPendingPercentage(OrderStatistics stats) {
    if (stats.totalOrders == null || stats.totalOrders == 0 || stats.totalPendingOrders == null) {
      return 0.0;
    }
    return (stats.totalPendingOrders! / stats.totalOrders!) * 100;
  }
}
