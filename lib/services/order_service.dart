import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fainzy_user_order.dart';
import '../models/order_statistics.dart';
import '../services/fainzy_api_client.dart';
import '../services/lastmile_api_client.dart';

class OrderService {
  final LastMileApiClient _lastMileApiClient;

  const OrderService(FainzyApiClient fainzyApiClient, this._lastMileApiClient);

  /// Debug method to check what tokens are stored
  Future<void> debugStoredTokens() async {
    final prefs = await SharedPreferences.getInstance();
    log('OrderService Debug: Checking stored tokens...');
    log('  - LastMileApiToken: ${prefs.getString('LastMileApiToken')}');
    log('  - api_token: ${prefs.getString('api_token')}');
    log('  - apiToken: ${prefs.getString('apiToken')}');
    log('  - FainzyApiToken: ${prefs.getString('FainzyApiToken')}');
    log('  - subentityId: ${prefs.getInt('subentityId')}');
    log('  - storeID: ${prefs.getString('storeID')}');
    log('  - isLoggedIn: ${prefs.getBool('isLoggedIn')}');
    
    // List all keys for debugging
    final keys = prefs.getKeys();
    log('  - All stored keys: $keys');
  }

  /// Get the LastMile API token from shared preferences
  Future<String?> _getLastMileApiToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('LastMileApiToken');
  }

  /// Get the subentity ID from shared preferences
  Future<int?> getSubentityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('subentityId');
  }

  /// Get the subentity ID from shared preferences (private method for internal use)
  Future<int?> _getSubentityId() async {
    return getSubentityId();
  }

  /// Fetch all orders for a store (subentity) - matches OrderRepository.fetchOrders
  Future<List<FainzyUserOrder>> fetchOrders(
    int subentityId, [
    String? filter,
  ]) async {
    final apiToken = await _getLastMileApiToken();
    if (apiToken == null) {
      // Debug what tokens are actually stored
      await debugStoredTokens();
      throw 'You are not authorised - LastMileApiToken not found in storage';
    }

    final result = await _lastMileApiClient.fetchOrders(
      subentityId: subentityId,
      apiToken: apiToken,
      filter: filter,
    );

    // Handle different response structures based on what the API returns
    List<dynamic> ordersList;
    
    // First, log the actual API response structure for debugging
    log('OrderService: API response type: ${result.data.runtimeType}');
    log('OrderService: API response data: ${result.data}');
    
    if (result.data is List) {
      // Direct list of orders
      ordersList = result.data as List;
      log('OrderService: Using direct list structure');
    } else if (result.data is Map<String, dynamic>) {
      // Nested structure - check common patterns
      final dataMap = result.data as Map<String, dynamic>;
      log('OrderService: Map structure with keys: ${dataMap.keys.toList()}');
      
      if (dataMap.containsKey('orders') && dataMap['orders'] is List) {
        ordersList = dataMap['orders'] as List;
        log('OrderService: Using nested "orders" key');
      } else if (dataMap.containsKey('results') && dataMap['results'] is List) {
        ordersList = dataMap['results'] as List;
        log('OrderService: Using nested "results" key');
      } else if (dataMap.containsKey('data') && dataMap['data'] is List) {
        ordersList = dataMap['data'] as List;
        log('OrderService: Using nested "data" key');
      } else {
        // Check if the entire map itself represents a single order in a wrapped response
        // Some APIs return: { "count": 1, "next": null, "previous": null, "results": [...] }
        // Or: { "status": "success", "data": [...] }
        // Let's check for any key that contains a List
        String? listKey;
        for (String key in dataMap.keys) {
          if (dataMap[key] is List) {
            listKey = key;
            break;
          }
        }
        
        if (listKey != null) {
          ordersList = dataMap[listKey] as List;
          log('OrderService: Using discovered list key: "$listKey"');
        } else {
          // If we can't find orders in expected keys, return empty list and log structure
          log('OrderService: Unexpected API response structure: ${result.data}');
          return <FainzyUserOrder>[];
        }
      }
    } else {
      log('OrderService: API returned unexpected data type: ${result.data.runtimeType}');
      return <FainzyUserOrder>[];
    }

    return ordersList.map((dynamic e) {
      log('OrderService: Processing order item type: ${e.runtimeType}');
      try {
        if (e is Map<String, dynamic>) {
          log('OrderService: Converting order item to FainzyUserOrder...');
          final order = FainzyUserOrder.fromJson(e);
          log('OrderService: Successfully converted order ${order.id}');
          return order;
        } else {
          log('OrderService: ERROR - Order item is not a Map: ${e.runtimeType}');
          throw Exception('Expected Map<String, dynamic> but got ${e.runtimeType}');
        }
      } catch (error, stackTrace) {
        log('OrderService: Error in FainzyUserOrder.fromJson: $error');
        log('OrderService: Stack trace: $stackTrace');
        log('OrderService: Problematic order data: $e');
        rethrow;
      }
    }).toList();
  }

  /// Fetch a specific order by ID - matches OrderRepository.fetchOrder
  Future<FainzyUserOrder> fetchOrderById({
    required int orderId,
  }) async {
    final apiToken = await _getLastMileApiToken();

    if (apiToken == null) {
      await debugStoredTokens();
      throw 'You are not authorised - LastMileApiToken not found in storage';
    }

    print(apiToken + "  ROOKR");

    final result = await _lastMileApiClient.fetchOrderById(
      orderId: orderId,
      apiToken: apiToken,
    );

    return FainzyUserOrder.fromJson(result.data as Map<String, dynamic>);
  }

  /// Update order status - matches OrderRepository.updateOrder
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final apiToken = await _getLastMileApiToken();

    if (apiToken == null) {
      await debugStoredTokens();
      throw 'You are not authorised - LastMileApiToken not found in storage';
    }

    await _lastMileApiClient.updateOrder(
      orderId: orderId,
      status: status,
      apiToken: apiToken,
    );
  }

  /// Fetch order statistics for the dashboard
  Future<OrderStatistics> fetchOrderStatistics([int? subentityId]) async {
    try {
      log('OrderService: Fetching order statistics for subentity $subentityId');
      
      // Get subentity ID from preferences if not provided
      int? effectiveSubentityId = subentityId;
      if (effectiveSubentityId == null || effectiveSubentityId == 0) {
        effectiveSubentityId = await _getSubentityId();
        if (effectiveSubentityId == null) {
          throw Exception('No subentity ID found');
        }
      }
      
      final apiToken = await _getLastMileApiToken();
      if (apiToken == null) throw Exception('No API token found');
      
      final response = await _lastMileApiClient.fetchOrderStatistics(
        subEntityId: effectiveSubentityId,
        apiToken: apiToken,
      );

      if (response.data != null) {
        final statistics = OrderStatistics.fromJson(response.data as Map<String, dynamic>);
        log('OrderService: Successfully fetched order statistics');
        return statistics;
      } else {
        throw Exception('Failed to fetch order statistics: ${response.message}');
      }
    } catch (e) {
      log('OrderService: Error fetching order statistics - $e');
      throw Exception('Failed to fetch order statistics: $e');
    }
  }
}
