import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/fainzy_user_order.dart';
import '../models/order_statistics.dart';
import '../services/order_service.dart';
import '../services/fainzy_api_client.dart';
import '../services/lastmile_api_client.dart';
import '../services/websocket_service.dart';
import '../services/audio_helper.dart';
import 'auth_provider.dart';

enum OrderStatus { initial, loading, success, error }
enum OrderActionStatus { idle, updating }

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService(FainzyApiClient(), LastMileApiClient());
  final WebSocketService _webSocketService = WebSocketService();
  
  // Status tracking
  OrderStatus _status = OrderStatus.initial;
  OrderActionStatus _actionStatus = OrderActionStatus.idle;
  String? _error;

  // Order data
  List<FainzyUserOrder> _allOrders = [];
  List<FainzyUserOrder> _pendingOrders = [];
  List<FainzyUserOrder> _activeOrders = [];
  List<FainzyUserOrder> _pastOrders = [];
  OrderStatistics? _orderStatistics;

  // Single order details
  FainzyUserOrder? _selectedOrder;

  // Individual order action tracking
  Map<int, OrderActionStatus> _orderActionStates = {};
  Map<int, String?> _orderActionErrors = {};

  // Websocket subscriptions
  StreamSubscription<Map<String, dynamic>>? _orderStreamSubscription;
  StreamSubscription<String>? _connectionStatusSubscription;
  bool _isWebsocketInitialized = false;

  // Sound notification settings
  bool _soundNotificationsEnabled = true;

  // WebSocket connection status
  String _connectionStatus = 'Disconnected';

  // Notification callback for showing dialogs
  Function(FainzyUserOrder)? _onNewOrderCallback;

  // Set of orders that have already been notified to prevent duplicate notifications
  final Set<int> _notifiedOrders = {};

  // Track existing orders for audio notifications (matches last_mile_store pattern)
  List<int> _existingOrders = [];
  String _lastStatus = '';

  // Batch operation support
  bool _isBatchOperation = false;
  List<int> _selectedOrderIds = [];

  // Getters
  OrderStatus get status => _status;
  OrderActionStatus get actionStatus => _actionStatus;
  String? get error => _error;
  
  List<FainzyUserOrder> get allOrders => _allOrders;
  List<FainzyUserOrder> get pendingOrders => _pendingOrders;
  List<FainzyUserOrder> get activeOrders => _activeOrders;
  List<FainzyUserOrder> get pastOrders => _pastOrders;
  OrderStatistics? get orderStatistics => _orderStatistics;
  FainzyUserOrder? get selectedOrder => _selectedOrder;
  
  // Additional getters for specific order statuses
  List<FainzyUserOrder> get completedOrders => _allOrders.where((order) => order.status == 'completed').toList();
  List<FainzyUserOrder> get cancelledOrders => _allOrders.where((order) => order.status == 'cancelled').toList();
  List<FainzyUserOrder> get rejectedOrders => _allOrders.where((order) => order.status == 'rejected').toList();
  
  bool get isLoading => _status == OrderStatus.loading;
  bool get isUpdating => _actionStatus == OrderActionStatus.updating;
  bool get hasError => _status == OrderStatus.error;
  bool get hasOrders => _allOrders.isNotEmpty;
  bool get isWebsocketConnected => _isWebsocketInitialized;
  bool get soundNotificationsEnabled => _soundNotificationsEnabled;
  String get connectionStatus => _connectionStatus;

  // Individual order action status getters
  bool isOrderUpdating(int orderId) => _orderActionStates[orderId] == OrderActionStatus.updating;
  String? getOrderActionError(int orderId) => _orderActionErrors[orderId];
  
  // Batch operation getters
  bool get isBatchOperation => _isBatchOperation;
  List<int> get selectedOrderIds => List.unmodifiable(_selectedOrderIds);
  bool get hasSelectedOrders => _selectedOrderIds.isNotEmpty;

  /// Enable or disable sound notifications for new orders
  void setSoundNotifications(bool enabled) {
    _soundNotificationsEnabled = enabled;
    notifyListeners();
  }

  /// Set callback for showing new order notifications
  void setNewOrderCallback(Function(FainzyUserOrder)? callback) {
    _onNewOrderCallback = callback;
  }

  /// Play notification sound for new orders (matches last_mile_store pattern)
  Future<void> _playNewOrderSound(int orderId) async {
    if (!_soundNotificationsEnabled) return;
    
    try {
      log('🔊 Triggering audio for new order $orderId');
      await AudioHelper.playNewOrderSound(orderId);
      log('OrderProvider: Played new order notification sound for order $orderId');
    } catch (e) {
      log('OrderProvider: Error playing new order sound for order $orderId - $e');
      try {
        // Fallback to system sound
        await SystemSound.play(SystemSoundType.alert);
        log('OrderProvider: Played fallback system notification sound');
      } catch (systemError) {
        log('OrderProvider: Error playing system notification sound - $systemError');
      }
    }
  }

  /// Play sound when payment is confirmed (matches last_mile_store pattern)
  Future<void> _playPaymentConfirmedSound(int orderId) async {
    if (!_soundNotificationsEnabled) return;
    
    try {
      log('💳 Playing payment confirmed sound for order $orderId');
      await AudioHelper.playPaymentConfirmedSound(orderId);
      log('OrderProvider: Played payment confirmed sound for order $orderId');
    } catch (e) {
      log('OrderProvider: Error playing payment confirmed sound for order $orderId - $e');
    }
  }

  /// Play sound when robot arrives for pickup (matches last_mile_store pattern)
  Future<void> _playRobotArrivedSound(int orderId) async {
    if (!_soundNotificationsEnabled) return;
    
    try {
      log('🤖 Playing robot arrived sound for order $orderId');
      await AudioHelper.playRobotArrivedSound(orderId);
      log('OrderProvider: Played robot arrived sound for order $orderId');
    } catch (e) {
      log('OrderProvider: Error playing robot arrived sound for order $orderId - $e');
    }
  }

  /// Stop sound for specific order (matches last_mile_store pattern)
  Future<void> _stopOrderSound(int orderId) async {
    try {
      await AudioHelper.stopSound(orderId);
      log('🛑 Stopped sound for order $orderId');
    } catch (e) {
      log('OrderProvider: Error stopping sound for order $orderId - $e');
    }
  }

  /// Show notification dialog for new orders
  void _showNewOrderNotification(FainzyUserOrder order) {
    if (order.id == null || _notifiedOrders.contains(order.id)) {
      return; // Already notified for this order
    }
    
    // Show notification and play sounds for different order statuses
    final status = order.status?.toLowerCase() ?? '';
    
    if (status == 'pending') {
      log('OrderProvider: Showing notification for new pending order ${order.id}');
      _notifiedOrders.add(order.id!);
      _onNewOrderCallback?.call(order);
    } else if (status == 'robot_arrived_for_pickup') {
      log('OrderProvider: Robot arrived for pickup order ${order.id}');
      _notifiedOrders.add(order.id!);
      _playRobotArrivedSound(order.id!);
      _onNewOrderCallback?.call(order);
    } else if (status == 'order_processing') {
      log('OrderProvider: Payment confirmed for order ${order.id}');
      _notifiedOrders.add(order.id!);
      _playPaymentConfirmedSound(order.id!);
      _onNewOrderCallback?.call(order);
    }
  }

  /// Initialize websocket connection for real-time order updates
  void initializeWebsocket(String storeID) {
    if (_isWebsocketInitialized || storeID.isEmpty) {
      log('OrderProvider: WebSocket already initialized or invalid store ID');
      return;
    }
    
    try {
      log('OrderProvider: Initializing websocket for store ID: $storeID...');
      
      // Clean up any existing connections first
      _cleanupWebsocketConnections();
      
      // Use WebSocketService to connect to the order updates endpoint
      final wsUrl = 'wss://lastmile.fainzy.tech/ws/soc/store_$storeID/';
      log('OrderProvider: Connecting to WebSocket URL: $wsUrl');
      
      _webSocketService.connect(wsUrl);
      _subscribeToOrderUpdates();
      _subscribeToConnectionStatus();
      _isWebsocketInitialized = true;
      
      log('OrderProvider: Websocket initialized successfully for store ID: $storeID');
    } catch (e) {
      log('OrderProvider: Error initializing websocket - $e');
      _isWebsocketInitialized = false;
    }
  }

  /// Clean up existing WebSocket connections
  void _cleanupWebsocketConnections() {
    log('OrderProvider: Cleaning up existing WebSocket connections');
    _orderStreamSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _orderStreamSubscription = null;
    _connectionStatusSubscription = null;
  }

  /// Initialize websocket using AuthProvider for store ID
  void initializeWebsocketWithAuth(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && authProvider.storeID.isNotEmpty) {
      initializeWebsocket(authProvider.storeID);
    }
  }

  /// Subscribe to real-time order updates from websocket
  void _subscribeToOrderUpdates() {
    _orderStreamSubscription?.cancel();
    _orderStreamSubscription = _webSocketService.orderUpdates.listen(
      (orderData) {
        try {
          log('OrderProvider: Received order update from websocket - ${orderData['id']}');
          _handleWebsocketOrderUpdate(orderData);
        } catch (e) {
          log('OrderProvider: Error handling websocket order update - $e');
        }
      },
      onError: (error) {
        log('OrderProvider: Websocket order stream error - $error');
      },
    );
  }

  /// Subscribe to connection status updates
  void _subscribeToConnectionStatus() {
    _connectionStatusSubscription?.cancel();
    _connectionStatusSubscription = _webSocketService.connectionStatus.listen(
      (status) {
        _connectionStatus = status;
        log('OrderProvider: WebSocket connection status: $status');
        notifyListeners();
      },
      onError: (error) {
        log('OrderProvider: Connection status stream error - $error');
      },
    );
  }

  /// Handle order updates received from websocket
  void _handleWebsocketOrderUpdate(Map<String, dynamic> orderData) {
    try {
      log('OrderProvider: Processing websocket order data: ${orderData['id']} with status: ${orderData['status']}');
      
      // Check if this is a valid order update
      if (!orderData.containsKey('id') && !orderData.containsKey('order_id')) {
        log('OrderProvider: Invalid order data from websocket - missing ID field');
        return;
      }

      // Try to parse as a complete order object first
      try {
        final updatedOrder = FainzyUserOrder.fromJson(orderData);
        
        if (updatedOrder.id == null) {
          log('OrderProvider: Invalid order data from websocket - missing ID after parsing');
          return;
        }

        // Handle order updates exactly like last_mile_store
        _handleOrderStatusChange(updatedOrder);

        // Check if this is a new order or an update
        final existingOrderIndex = _allOrders.indexWhere((order) => order.id == updatedOrder.id);
        if (existingOrderIndex >= 0) {
          // Update existing order
          log('OrderProvider: Updating existing order ${updatedOrder.id} from websocket');
          _allOrders[existingOrderIndex] = updatedOrder;
          
          // Update selected order if it matches
          if (_selectedOrder?.id == updatedOrder.id) {
            _selectedOrder = updatedOrder;
          }
        } else {
          // Add new order to the beginning of the list
          log('OrderProvider: Adding new order ${updatedOrder.id} from websocket');
          _allOrders.insert(0, updatedOrder);
        }
        
        // Re-categorize orders and notify listeners
        _categorizeOrders();
        notifyListeners();
        return;
        
      } catch (parseError) {
        log('OrderProvider: Could not parse as complete order object: $parseError');
      }

      // Fallback: Handle as event-based notification and refresh
      final eventType = orderData['type'] ?? orderData['event_type'] ?? 'order_notification';
      log('OrderProvider: Handling as event type: $eventType');
      
      // Play sound notification for new orders
      if (eventType == 'new_order' || eventType == 'order_notification') {
        _playNewOrderSound(0); // Use 0 for event-based notifications without specific order ID
        // Note: For event-based notifications, we'll handle the dialog in the refresh method
      }
      
      // Refresh orders instead of trying to parse individual order data
      _refreshOrdersFromWebsocket();
      
    } catch (e) {
      log('OrderProvider: Error processing websocket order update - $e, falling back to refresh');
      // If we can't parse the individual order, just refresh all orders
      _refreshOrdersFromWebsocket();
    }
  }
  
  /// Refresh orders from websocket events (background refresh)
  void _refreshOrdersFromWebsocket() async {
    try {
      log('OrderProvider: Refreshing orders from websocket event...');
      
      // Get current subentity ID
      final subentityId = await _orderService.getSubentityId();
      if (subentityId == null) {
        log('OrderProvider: No subentity ID found for websocket refresh');
        return;
      }
      
      // Store current order IDs to detect new orders
      final existingOrderIds = _allOrders.map((order) => order.id).toSet();
      
      // Fetch orders without changing the loading state (silent refresh)
      final orders = await _orderService.fetchOrders(subentityId);
      
      // Check for new orders that weren't in the previous list
      final newOrders = <FainzyUserOrder>[];
      for (final order in orders) {
        if (order.id != null && !existingOrderIds.contains(order.id)) {
          newOrders.add(order);
          log('OrderProvider: Detected new order ${order.id} during websocket refresh');
        }
      }
      
      // Play sound notification and show dialogs for new orders
      if (newOrders.isNotEmpty) {
        for (final order in newOrders) {
          _playNewOrderSound(order.id!);
          _showNewOrderNotification(order);
        }
      }
      
      _allOrders = orders;
      _categorizeOrders();
      notifyListeners();
      
      log('OrderProvider: Successfully refreshed ${orders.length} orders from websocket (new orders: ${newOrders.length})');
    } catch (e) {
      log('OrderProvider: Error refreshing orders from websocket - $e');
    }
  }

  /// Disconnect websocket when no longer needed
  void disconnectWebsocket() {
    if (!_isWebsocketInitialized) return;
    
    log('OrderProvider: Disconnecting websocket...');
    _cleanupWebsocketConnections();
    _webSocketService.disconnect();
    _isWebsocketInitialized = false;
    _connectionStatus = 'Disconnected';
    notifyListeners();
    log('OrderProvider: Websocket disconnected successfully');
  }

  /// Reset WebSocket initialization state (useful for reconnection scenarios)
  void resetWebsocketState() {
    log('OrderProvider: Resetting WebSocket state');
    _isWebsocketInitialized = false;
    _connectionStatus = 'Disconnected';
    notifyListeners();
  }

  /// Force reconnect WebSocket (useful for network recovery)
  void reconnectWebsocket(String storeID) {
    log('OrderProvider: Force reconnecting WebSocket for store: $storeID');
    disconnectWebsocket();
    
    // Small delay to ensure cleanup is complete
    Future.delayed(const Duration(milliseconds: 500), () {
      resetWebsocketState();
      initializeWebsocket(storeID);
    });
  }

  /// Fetch all orders and categorize them - matches OrderRepository pattern
  Future<void> fetchOrders([int? subentityId, String? filter]) async {
    try {
      _setStatus(OrderStatus.loading);
      _clearError();

      // Get subentity ID from OrderService if not provided
      int? effectiveSubentityId = subentityId;
      if (effectiveSubentityId == null) {
        effectiveSubentityId = await _orderService.getSubentityId();
        if (effectiveSubentityId == null) {
          throw Exception('No subentity ID found');
        }
      }

      log('OrderProvider: Fetching orders for subentity $effectiveSubentityId...');
      final orders = await _orderService.fetchOrders(effectiveSubentityId, filter);
      
      _allOrders = orders;
      _categorizeOrders();
      
      _setStatus(OrderStatus.success);
      log('OrderProvider: Successfully fetched ${orders.length} orders');
    } catch (e) {
      log('OrderProvider: Error fetching orders - $e');
      _setError('Failed to fetch orders: $e');
      _setStatus(OrderStatus.error);
    }
  }

  /// Refresh orders (same as fetch but indicates it's a refresh)
  Future<void> refreshOrders([int? subentityId, String? filter]) async {
    return fetchOrders(subentityId, filter);
  }

  /// Fetch a specific order by ID - matches OrderRepository pattern
  Future<void> fetchOrderById({required int orderId}) async {
    try {
      _setStatus(OrderStatus.loading);
      _clearError();

      log('OrderProvider: Fetching order $orderId...');
      final order = await _orderService.fetchOrderById(orderId: orderId);
      
      _selectedOrder = order;
      _setStatus(OrderStatus.success);
      log('OrderProvider: Successfully fetched order $orderId');
    } catch (e) {
      log('OrderProvider: Error fetching order $orderId - $e');
      _setError('Failed to fetch order: $e');
      _setStatus(OrderStatus.error);
    }
  }

  /// Update order status - matches OrderRepository pattern
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      _setActionStatus(OrderActionStatus.updating);
      _clearError();

      log('OrderProvider: Updating order $orderId status to $status...');
      
      // Stop notification sound when order status is being updated
      log('OrderProvider: Stopping notification sound for order $orderId due to status update');
      _stopOrderSound(orderId);
      
      await _orderService.updateOrderStatus(orderId: orderId, status: status);
      
      // Update the order in our local lists
      _updateOrderInLists(orderId, status);
      
      _setActionStatus(OrderActionStatus.idle);
      log('OrderProvider: Successfully updated order $orderId status to $status');
    } catch (e) {
      log('OrderProvider: Error updating order $orderId status - $e');
      _setError('Failed to update order status: $e');
      _setActionStatus(OrderActionStatus.idle);
    }
  }

  /// Accept order - changes status from pending to payment_processing
  Future<bool> acceptOrder(int orderId) async {
    try {
      log('OrderProvider: Accepting order $orderId...');
      await updateOrderStatus(orderId: orderId, status: 'payment_processing');
      log('OrderProvider: Successfully accepted order $orderId');
      return true;
    } catch (e) {
      log('OrderProvider: Error accepting order $orderId - $e');
      return false;
    }
  }

  /// Reject order - changes status from pending to rejected
  Future<bool> rejectOrder(int orderId) async {
    try {
      log('OrderProvider: Rejecting order $orderId...');
      await updateOrderStatus(orderId: orderId, status: 'rejected');
      log('OrderProvider: Successfully rejected order $orderId');
      return true;
    } catch (e) {
      log('OrderProvider: Error rejecting order $orderId - $e');
      return false;
    }
  }

  /// Mark order as ready - changes status from order_processing to ready
  Future<bool> markOrderReady(int orderId) async {
    try {
      log('OrderProvider: Marking order $orderId as ready...');
      await updateOrderStatus(orderId: orderId, status: 'ready');
      log('OrderProvider: Successfully marked order $orderId as ready');
      return true;
    } catch (e) {
      log('OrderProvider: Error marking order $orderId as ready - $e');
      return false;
    }
  }

  /// Start order preparation - changes status from payment_processing to order_processing
  Future<bool> startOrderPreparation(int orderId) async {
    try {
      log('OrderProvider: Starting preparation for order $orderId...');
      await updateOrderStatus(orderId: orderId, status: 'order_processing');
      log('OrderProvider: Successfully started preparation for order $orderId');
      return true;
    } catch (e) {
      log('OrderProvider: Error starting preparation for order $orderId - $e');
      return false;
    }
  }

  /// Update preparation time for an order
  Future<bool> updatePreparationTime({
    required int orderId,
    required int preparationTimeMinutes,
  }) async {
    try {
      log('OrderProvider: Updating preparation time for order $orderId to $preparationTimeMinutes minutes...');
      
      // Note: This would require an API endpoint that supports updating preparation time
      // For now, we'll just log this functionality as it's not implemented in the current API
      log('OrderProvider: Preparation time update requested but API endpoint not available');
      
      // In a complete implementation, this would be:
      // await _orderService.updatePreparationTime(orderId: orderId, minutes: preparationTimeMinutes);
      
      notifyListeners();
      return true;
    } catch (e) {
      log('OrderProvider: Error updating preparation time for order $orderId - $e');
      return false;
    }
  }

  /// Complete order - changes status to completed
  Future<bool> completeOrder(int orderId) async {
    try {
      log('OrderProvider: Completing order $orderId...');
      await updateOrderStatus(orderId: orderId, status: 'completed');
      log('OrderProvider: Successfully completed order $orderId');
      return true;
    } catch (e) {
      log('OrderProvider: Error completing order $orderId - $e');
      return false;
    }
  }

  /// Cancel order - changes status to cancelled
  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      log('OrderProvider: Cancelling order $orderId with reason: ${reason ?? 'No reason provided'}...');
      await updateOrderStatus(orderId: orderId, status: 'cancelled');
      log('OrderProvider: Successfully cancelled order $orderId');
      return true;
    } catch (e) {
      log('OrderProvider: Error cancelling order $orderId - $e');
      return false;
    }
  }

  /// Individual order action tracking methods
  void _setOrderActionStatus(int orderId, OrderActionStatus status) {
    _orderActionStates[orderId] = status;
    notifyListeners();
  }

  void _setOrderActionError(int orderId, String? error) {
    _orderActionErrors[orderId] = error;
    notifyListeners();
  }

  void _clearOrderActionError(int orderId) {
    _orderActionErrors.remove(orderId);
    notifyListeners();
  }

  /// Batch operation methods
  void enableBatchOperation() {
    _isBatchOperation = true;
    _selectedOrderIds.clear();
    notifyListeners();
  }

  void disableBatchOperation() {
    _isBatchOperation = false;
    _selectedOrderIds.clear();
    notifyListeners();
  }

  void toggleOrderSelection(int orderId) {
    if (_selectedOrderIds.contains(orderId)) {
      _selectedOrderIds.remove(orderId);
    } else {
      _selectedOrderIds.add(orderId);
    }
    notifyListeners();
  }

  void selectAllOrders(List<FainzyUserOrder> orders) {
    _selectedOrderIds.clear();
    _selectedOrderIds.addAll(orders.map((order) => order.id!).where((id) => true));
    notifyListeners();
  }

  void clearSelection() {
    _selectedOrderIds.clear();
    notifyListeners();
  }

  /// Batch accept orders
  Future<Map<int, bool>> batchAcceptOrders(List<int> orderIds) async {
    final results = <int, bool>{};
    
    for (final orderId in orderIds) {
      _setOrderActionStatus(orderId, OrderActionStatus.updating);
      results[orderId] = await acceptOrder(orderId);
      _setOrderActionStatus(orderId, OrderActionStatus.idle);
    }
    
    return results;
  }

  /// Batch reject orders
  Future<Map<int, bool>> batchRejectOrders(List<int> orderIds) async {
    final results = <int, bool>{};
    
    for (final orderId in orderIds) {
      _setOrderActionStatus(orderId, OrderActionStatus.updating);
      results[orderId] = await rejectOrder(orderId);
      _setOrderActionStatus(orderId, OrderActionStatus.idle);
    }
    
    return results;
  }

  /// Advanced filtering methods
  List<FainzyUserOrder> filterOrdersByDateRange(DateTime start, DateTime end) {
    return _allOrders.where((order) {
      if (order.created == null) return false;
      return order.created!.isAfter(start) && order.created!.isBefore(end);
    }).toList();
  }

  List<FainzyUserOrder> filterOrdersByCustomer(String customerName) {
    return _allOrders.where((order) {
      final userName = order.user?.name;
      if (userName == null) return false;
      return userName.toLowerCase().contains(customerName.toLowerCase());
    }).toList();
  }

  List<FainzyUserOrder> filterOrdersByMinimumAmount(double minAmount) {
    return _allOrders.where((order) {
      final totalPrice = order.totalPrice;
      if (totalPrice == null) return false;
      return totalPrice >= minAmount;
    }).toList();
  }

  /// Order analytics methods
  double getTotalRevenue() {
    return _allOrders
        .where((order) => order.status == 'completed' && order.totalPrice != null)
        .map((order) => order.totalPrice!)
        .fold(0.0, (sum, price) => sum + price);
  }

  double getAverageOrderValue() {
    final completedOrders = _allOrders.where((order) => order.status == 'completed' && order.totalPrice != null).toList();
    if (completedOrders.isEmpty) return 0.0;
    
    final total = completedOrders.map((order) => order.totalPrice!).fold(0.0, (sum, price) => sum + price);
    return total / completedOrders.length;
  }

  Map<String, int> getOrderStatusCounts() {
    final counts = <String, int>{};
    for (final order in _allOrders) {
      if (order.status != null) {
        counts[order.status!] = (counts[order.status!] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Fetch order statistics
  Future<void> fetchOrderStatistics([int? subentityId]) async {
    try {
      log('OrderProvider: Fetching order statistics...');
      final statistics = await _orderService.fetchOrderStatistics(subentityId);
      
      _orderStatistics = statistics;
      notifyListeners();
      log('OrderProvider: Successfully fetched order statistics');
    } catch (e) {
      log('OrderProvider: Error fetching order statistics - $e');
      // Don't set error status for statistics as it's not critical
      // Just log the error
    }
  }

  /// Clear all data and disconnect websocket
  void clearData() {
    log('OrderProvider: Clearing all order data and disconnecting WebSocket');
    
    _allOrders.clear();
    _pendingOrders.clear();
    _activeOrders.clear();
    _pastOrders.clear();
    _selectedOrder = null;
    _orderStatistics = null;
    _setStatus(OrderStatus.initial);
    _clearError();
    
    // Clear notification tracking
    _notifiedOrders.clear();
    _existingOrders.clear();
    
    // Clear action states
    _orderActionStates.clear();
    _orderActionErrors.clear();
    
    // Disconnect websocket when clearing data (on logout)
    disconnectWebsocket();
    
    notifyListeners();
    log('OrderProvider: Data cleared successfully');
  }

  /// Dispose of resources when provider is destroyed
  @override
  void dispose() {
    disconnectWebsocket();
    super.dispose();
  }

  /// Get orders by status
  List<FainzyUserOrder> getOrdersByStatus(String status) {
    return _allOrders.where((order) => order.status == status).toList();
  }

  /// Get order count by status
  int getOrderCountByStatus(String status) {
    return getOrdersByStatus(status).length;
  }

  /// Categorize orders into pending, active, and past based on order status
  void _categorizeOrders() {
    // Sort all orders by creation date (latest first)
    _allOrders.sort((a, b) {
      final dateA = a.created ?? DateTime.now();
      final dateB = b.created ?? DateTime.now();
      return dateB.compareTo(dateA); // Descending order (latest first)
    });
    
    // Pending orders: orders waiting for store action
    _pendingOrders = _allOrders.where((order) => 
      order.status == 'pending'
    ).toList();
    
    // Past orders: completed, cancelled, rejected, or refunded orders
    _pastOrders = _allOrders.where((order) => 
      order.status == 'completed' || 
      order.status == 'rejected' || 
      order.status == 'cancelled' ||
      order.status == 'refunded'
    ).toList();
    
    // Active orders: any order that is not pending, completed, cancelled, rejected, or refunded
    _activeOrders = _allOrders.where((order) => 
      order.status != 'pending' &&
      order.status != 'completed' && 
      order.status != 'rejected' && 
      order.status != 'cancelled' &&
      order.status != 'refunded'
    ).toList();
    
    log('OrderProvider: Categorized orders - Pending: ${_pendingOrders.length}, Active: ${_activeOrders.length}, Past: ${_pastOrders.length}');
  }

  /// Update order status in local lists after successful API update
  void _updateOrderInLists(int orderId, String newStatus) {
    // Find and update the order in all lists
    for (int i = 0; i < _allOrders.length; i++) {
      if (_allOrders[i].id == orderId) {
        _allOrders[i] = _allOrders[i].copyWith(status: newStatus);
        break;
      }
    }
    
    // Update selected order if it matches
    if (_selectedOrder?.id == orderId) {
      _selectedOrder = _selectedOrder!.copyWith(status: newStatus);
    }
    
    // Re-categorize orders
    _categorizeOrders();
    notifyListeners();
  }

  /// Set status and notify listeners
  void _setStatus(OrderStatus status) {
    if (_status != status) {
      _status = status;
      notifyListeners();
    }
  }

  /// Set action status and notify listeners
  void _setActionStatus(OrderActionStatus actionStatus) {
    if (_actionStatus != actionStatus) {
      _actionStatus = actionStatus;
      notifyListeners();
    }
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Handle order status changes and audio notifications exactly like last_mile_store
  void _handleOrderStatusChange(FainzyUserOrder order) {
    if (order.id == null) return;
    
    final orderId = order.id!;
    final status = order.status;
    
    if (_lastStatus != status) {
      _existingOrders.clear();
    }

    log('OrderProvider: New order update from websocket: $status');
    
    // Add detailed logging for payment-related status changes
    if (status == 'payment_processing') {
      log('🔄 Order $orderId is now in payment_processing status - waiting for user payment');
    }
    
    if (status == 'order_processing') {
      log('✅ Order $orderId payment confirmed - order is now processing');
    }
    
    // Play sound for new pending orders (matches last_mile_store exactly)
    if (status == 'pending' && !_existingOrders.contains(orderId)) {
      log('🔔 New pending order detected: $orderId');
      log('🔊 Triggering audio for new order');
      _playNewOrderSound(orderId);
      _showNewOrderNotification(order);
    }

    // Play sound for robot arrived (matches last_mile_store exactly)
    if (status == 'robot_arrived_for_pickup' && !_existingOrders.contains(orderId)) {
      log('🤖 Robot arrived for pickup - playing sound');
      _playRobotArrivedSound(orderId);
    }

    // Play sound for payment confirmed (matches last_mile_store exactly)
    if (status == 'order_processing' && !_existingOrders.contains(orderId)) {
      log('💳 Payment confirmed - playing sound');
      _playPaymentConfirmedSound(orderId);
    }

    // Track this order to prevent duplicate notifications
    _existingOrders.add(orderId);
    _lastStatus = status ?? '';

    // Stop sounds when order reaches final states (matches last_mile_store exactly)
    if (_existingOrders.contains(orderId) &&
        (status == 'rejected' ||
         status == 'cancelled' ||
         status == 'refunded' ||
         status == 'completed')) {
      log('🛑 Order $orderId reached final state ($status) - stopping sound');
      _stopOrderSound(orderId);
    }
  }

}
