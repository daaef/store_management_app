import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_management_app/services/fainzy_api_client.dart';
import 'dart:developer' as dev;
import 'dart:convert';
import '../models/order_statistics.dart';
import '../models/store_data.dart';
import '../services/statistics_repository.dart';
import '../helpers/currency_formatter.dart';

/// Store status with numeric mapping
/// 1 = isOpened, 2 = isLoggedOut, 3 = isClosed
class StoreStatus {
  static const int opened = 1;
  static const int loggedOut = 2;
  static const int closed = 3;
  
  final int value;
  final String name;
  
  const StoreStatus._(this.value, this.name);
  
  static const StoreStatus open = StoreStatus._(opened, 'open');
  static const StoreStatus logout = StoreStatus._(loggedOut, 'loggedOut');
  static const StoreStatus close = StoreStatus._(closed, 'closed');
  
  /// Create StoreStatus from numeric value
  static StoreStatus fromValue(int value) {
    switch (value) {
      case opened:
        return open;
      case loggedOut:
        return logout;
      case closed:
        return close;
      default:
        return close; // Default to closed for unknown values
    }
  }
  
  /// Get all possible statuses
  static List<StoreStatus> get values => [open, logout, close];
  
  bool get isOpen => value == opened;
  bool get isLoggedOut => value == loggedOut;
  bool get isClosed => value == closed;
  
  @override
  String toString() => 'StoreStatus($value: $name)';
  
  @override
  bool operator ==(Object other) => 
      identical(this, other) || 
      (other is StoreStatus && other.value == value);
  
  @override
  int get hashCode => value.hashCode;
}

enum DataStatus { loading, loaded, error }

class StoreProvider with ChangeNotifier {
  // Core store data
  StoreData? _storeData;
  OrderStatistics? _orderStatistics;
  StoreStatus _status = StoreStatus.close;
  DataStatus _dataStatus = DataStatus.loading;
  String? _error;

  // Repositories
  final StatisticsRepository _statisticsRepository = StatisticsRepository();

  // Getters
  StoreData? get storeData => _storeData;
  OrderStatistics? get orderStatistics => _orderStatistics;
  StoreStatus get status => _status;
  DataStatus get dataStatus => _dataStatus;
  String? get error => _error;

  // Store basic info
  String get storeName => _storeData?.name ?? 'My Store';
  String get storeAddress => _storeData?.location?.addressDetails ?? '123 Main St';
  String get currency => _storeData?.currency ?? 'USD';
  bool get isClosed => _status.isClosed;
  bool get isOpen => _status.isOpen;
  bool get isLoggedOut => _status.isLoggedOut;

  // Order statistics
  double get totalRevenue => _orderStatistics?.totalRevenue ?? 0.0;
  int get pendingOrders => _orderStatistics?.totalPendingOrders ?? 0;
  int get completedOrders => _orderStatistics?.totalCompletedOrders ?? 0;
  int get totalOrders => _orderStatistics?.totalOrders ?? 0;

  // Calculated metrics
  double get averageOrderValue {
    if (totalOrders > 0 && totalRevenue > 0) {
      return totalRevenue / totalOrders;
    }
    return 0.0;
  }

  double get completionRate {
    if (totalOrders > 0) {
      return (completedOrders / totalOrders) * 100;
    }
    return 0.0;
  }

  double get pendingRate {
    if (totalOrders > 0) {
      return (pendingOrders / totalOrders) * 100;
    }
    return 0.0;
  }

  // Formatted currency values
  String get formattedTotalRevenue {
    return CurrencyFormatter.format(totalRevenue, currencyCode: currency);
  }

  String get formattedAverageOrderValue {
    return CurrencyFormatter.format(averageOrderValue, currencyCode: currency);
  }

  String get formattedTotalRevenueCompact {
    return CurrencyFormatter.formatCompact(totalRevenue, currencyCode: currency);
  }

  // Initialize provider
  StoreProvider() {
    _loadStoreData();
  }

  /// Load store data from SharedPreferences and fetch statistics
  Future<void> _loadStoreData() async {
    try {
      _dataStatus = DataStatus.loading;
      _error = null;
      notifyListeners();

      // Load store data from SharedPreferences
      await _loadBasicStoreData();
      
      // Fetch order statistics
      await _fetchOrderStatistics();

      _dataStatus = DataStatus.loaded;
      dev.log('✅ StoreProvider: Data loaded successfully');
    } catch (e) {
      _error = e.toString();
      _dataStatus = DataStatus.error;
      dev.log('❌ StoreProvider: Failed to load data: $e');
    }
    notifyListeners();
  }

  /// Load basic store information from SharedPreferences
  Future<void> _loadBasicStoreData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to load store data
      final storeDataJson = prefs.getString('storeData');
      if (storeDataJson != null) {
        final jsonMap = json.decode(storeDataJson) as Map<String, dynamic>;
        _storeData = StoreData.fromJson(jsonMap);
        dev.log('📱 Loaded store data: ${_storeData?.name}');
        
        // Set store status based on numeric status field from API
        if (_storeData?.status != null) {
          _status = StoreStatus.fromValue(_storeData!.status!);
        } else {
          // Fallback to isOpen field if status is not available
          _status = _storeData?.isOpen == true ? StoreStatus.open : StoreStatus.close;
        }
        dev.log('📱 Store status set to: ${_status.toString()}');
      }

      // If no store data found, try to get store ID at least
      final storeId = prefs.getString('storeId');
      if (storeId != null && _storeData == null) {
        // Create minimal store data
        _storeData = StoreData(
          id: int.tryParse(storeId),
          name: 'Store $storeId',
        );
        dev.log('📱 Created minimal store data for ID: $storeId');
      }
    } catch (e) {
      dev.log('⚠️ Error loading basic store data: $e');
    }
  }

  /// Fetch order statistics from API
  Future<void> _fetchOrderStatistics() async {
    try {
      if (_storeData?.id != null) {
        _orderStatistics = await _statisticsRepository.fetchOrderStatistics(
          subEntityId: _storeData!.id!,
        );
        dev.log('📊 Loaded order statistics: ${_orderStatistics?.totalOrders} total orders');
      } else {
        dev.log('⚠️ No store ID available for fetching statistics');
        // Use mock data for development
        _orderStatistics = const OrderStatistics(
          totalOrders: 42,
          totalPendingOrders: 5,
          totalCompletedOrders: 37,
          totalRevenue: 2450.75,
        );
      }
    } catch (e) {
      dev.log('⚠️ Error fetching order statistics: $e');
      // Use fallback mock data
      _orderStatistics = const OrderStatistics(
        totalOrders: 42,
        totalPendingOrders: 5,
        totalCompletedOrders: 37,
        totalRevenue: 2450.75,
      );
    }
  }

  /// Toggle store open/closed status
  Future<void> toggleStoreStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apiToken');
      final storeId = prefs.getString('storeID');

      // Determine new status
      final newStatus = _status.isOpen ? StoreStatus.close : StoreStatus.open;
      
      final apiClient = FainzyApiClient();
      await apiClient.openOrCloseStore(
        subEntityId: int.parse(storeId.toString()), 
        apiToken: token.toString(), 
        isOpen: !_status.isOpen,
      );
      
      _status = newStatus;
      
      // Update stored data with both status fields
      if (_storeData != null) {
        _storeData = _storeData!.copyWith(
          status: _status.value,
          isOpen: _status.isOpen,
        );
        await _saveStoreData();
      }

      dev.log('🔄 Store status toggled to: ${_status.toString()}');
    } catch (e) {
      _error = 'Failed to update store status: $e';
      dev.log('❌ Error toggling store status: $e');
    }
    notifyListeners();
  }

  /// Set store status to logged out
  Future<void> setStoreStatusLoggedOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('apiToken');
      final storeId = prefs.getString('storeID');

      if (token != null && storeId != null) {
        final apiClient = FainzyApiClient();
        await apiClient.logoutStore(
          subEntityId: int.parse(storeId), 
          apiToken: token, 
        );
      }
      
      _status = StoreStatus.logout;
      
      // Update stored data with logged out status
      if (_storeData != null) {
        _storeData = _storeData!.copyWith(
          status: _status.value,
          isOpen: false,
        );
        await _saveStoreData();
      }

      dev.log('🔄 Store status set to logged out');
    } catch (e) {
      dev.log('❌ Error setting store status to logged out: $e');
    }
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshData() async {
    dev.log('🔄 StoreProvider: Refreshing data...');
    await _loadStoreData();
  }

  /// Save store data to SharedPreferences
  Future<void> _saveStoreData() async {
    if (_storeData != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('storeData', json.encode(_storeData!.toJson()));
        dev.log('💾 Store data saved to SharedPreferences');
      } catch (e) {
        dev.log('❌ Error saving store data: $e');
      }
    }
  }

  /// Update store data
  void updateStoreData(StoreData newStoreData) {
    _storeData = newStoreData;
    
    // Update status based on the new store data
    if (newStoreData.status != null) {
      _status = StoreStatus.fromValue(newStoreData.status!);
    } else {
      // Fallback to isOpen field if status is not available
      _status = newStoreData.isOpen == true ? StoreStatus.open : StoreStatus.close;
    }
    
    _saveStoreData();
    notifyListeners();
  }
}
