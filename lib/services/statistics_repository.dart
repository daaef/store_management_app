import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_statistics.dart';
import '../models/fainzy_user.dart';
import '../models/api_response.dart';
import 'lastmile_api_client.dart';

class StatisticsRepository {
  final http.Client httpClient;
  final String baseUrl;
  final LastMileApiClient _apiClient;

  StatisticsRepository({
    this.baseUrl = 'lastmile.fainzy.tech',
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client(),
       _apiClient = LastMileApiClient();

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

  /// Fetch top customers for the store dashboard
  Future<List<FainzyUser>> fetchTopCustomers({
    required int subEntityId,
  }) async {
    try {
      // Get API token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final apiToken = prefs.getString('apiToken');
      
      if (apiToken == null) {
        throw Exception('No API token found. Please login again.');
      }

      log('🏆 Fetching top customers for subEntityId: $subEntityId');

      final apiResponse = await _apiClient.fetchTopCustomers(
        subEntityId: subEntityId,
        apiToken: apiToken,
      );
      
      if (apiResponse.status == 'success' && apiResponse.data != null) {
        final List<dynamic> customersData = apiResponse.data as List<dynamic>;
        final List<FainzyUser> topCustomers = customersData
            .map((dynamic customerData) => FainzyUser.fromJson(customerData as Map<String, dynamic>))
            .toList();
        
        log('🏆 Successfully fetched ${topCustomers.length} top customers');
        return topCustomers;
      } else {
        throw Exception('Failed to load top customers: ${apiResponse.message}');
      }
    } catch (e) {
      log('❌ Error fetching top customers: $e');
      
      // Return mock data for development/testing
      return _getMockTopCustomers();
    }
  }

  /// Get mock top customers for testing/offline use
  List<FainzyUser> _getMockTopCustomers() {
    log('🏆 Using mock top customers for development');
    
    return const [
      FainzyUser(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
      ),
      FainzyUser(
        id: 2,
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        phoneNumber: '+1234567891',
      ),
      FainzyUser(
        id: 3,
        firstName: 'Bob',
        lastName: 'Johnson',
        email: 'bob.johnson@example.com',
        phoneNumber: '+1234567892',
      ),
      FainzyUser(
        id: 4,
        firstName: 'Alice',
        lastName: 'Brown',
        email: 'alice.brown@example.com',
        phoneNumber: '+1234567893',
      ),
      FainzyUser(
        id: 5,
        firstName: 'Charlie',
        lastName: 'Wilson',
        email: 'charlie.wilson@example.com',
        phoneNumber: '+1234567894',
      ),
    ];
  }
}
