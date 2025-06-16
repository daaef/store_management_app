# Store Management App - Complete Code Flow Documentation

## Overview
This documentation explains the complete architecture and code flow of the Store Management App, focusing on the three critical features implemented: **Push Notifications**, **Error Handling**, and **Real-time WebSocket Updates**.

## Table of Contents
1. [Application Architecture](#application-architecture)
2. [App Initialization Flow](#app-initialization-flow)
3. [Authentication Flow](#authentication-flow)
4. [Push Notification System](#push-notification-system)
5. [WebSocket Real-time Updates](#websocket-real-time-updates)
6. [Error Handling System](#error-handling-system)
7. [Order Management Flow](#order-management-flow)
8. [Key Components Interaction](#key-components-interaction)
9. [State Management Pattern](#state-management-pattern)
10. [Configuration and Setup](#configuration-and-setup)

---

## Application Architecture

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├─────────────────────────────────────────────────────────┤
│  UI Layer (Screens & Widgets)                          │
│  ├── OrderManagementScreen                             │
│  ├── AuthenticationScreen                              │
│  └── Various other screens...                          │
├─────────────────────────────────────────────────────────┤
│  State Management (Provider Pattern)                   │
│  ├── AuthProvider                                      │
│  ├── OrderProvider                                     │
│  └── Other providers...                                │
├─────────────────────────────────────────────────────────┤
│  Services Layer                                        │
│  ├── WebSocketService                                  │
│  ├── NotificationHelper                                │
│  ├── ErrorHandlingService                              │
│  └── API Clients                                       │
├─────────────────────────────────────────────────────────┤
│  Models & Data                                         │
│  ├── ApiResponse                                       │
│  ├── FainzyUserOrder                                   │
│  └── Other models...                                   │
└─────────────────────────────────────────────────────────┘
```

### Key Design Patterns
- **Provider Pattern**: For state management across the app
- **Repository Pattern**: For data access and API communication
- **Singleton Pattern**: For WebSocket service and notification helper
- **Factory Pattern**: For API response creation and error handling
- **Observer Pattern**: For real-time updates via WebSocket and Provider

---

## App Initialization Flow

### 1. Main App Entry Point (`main.dart`)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load environment variables
  await dotenv.load(fileName: ".env");
  
  // 2. Initialize OneSignal notifications
  await NotificationHelper.initialize();
  
  // 3. Set device orientation
  await SystemChrome.setPreferredOrientations([...]);
  
  // 4. Run app with providers
  runApp(MultiProvider(...));
}
```

### 2. Provider Setup
The app uses multiple providers for different concerns:
- **AuthProvider**: Authentication and user session management
- **OrderProvider**: Order data and real-time updates
- **StoreProvider**: Store information and settings
- **NavigationProvider**: Navigation state management

### 3. App Wrapper with WebSocket Listener
```dart
class AppWithWebsocketListener extends StatefulWidget {
  // Sets up post-authentication callbacks
  // Initializes WebSocket when user authenticates
  // Handles logout cleanup
}
```

---

## Authentication Flow

### AuthProvider Lifecycle

1. **App Startup Check**
   ```dart
   Future<void> _checkAuthStatus() async {
     final prefs = await SharedPreferences.getInstance();
     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
     
     if (isLoggedIn && storedStoreId != null && storedToken != null) {
       // Restore authentication state
       _authState = AuthState.authenticated;
       // Initialize OneSignal with user ID
       _postAuthCallback?.call(_storeID);
     }
   }
   ```

2. **Login Process**
   ```dart
   Future<bool> login(String storeId) async {
     _authState = AuthState.authenticating;
     
     // Call authentication API
     final ApiResponse response = await _apiClient.authenticateStore(storeId: storeId);
     
     if (response.status == 'success') {
       // Save authentication data
       await prefs.setBool('isLoggedIn', true);
       await prefs.setString('storeId', storeId);
       await prefs.setString('apiToken', response.data['token']);
       
       // Set OneSignal user ID and tags
       await NotificationHelper.setExternalUserId(_storeID);
       await NotificationHelper.sendTag('store_id', _storeID);
       
       // Initialize WebSocket connection
       _postAuthCallback?.call(_storeID);
       
       return true;
     }
   }
   ```

3. **Logout Process**
   ```dart
   Future<void> logout() async {
     // Update server-side store status
     await _apiClient.logoutStore(subEntityId: int.parse(_storeID), apiToken: _token);
     
     // Clear local storage
     await prefs.clear();
     
     // Remove OneSignal user ID and tags
     await NotificationHelper.removeExternalUserId();
     await NotificationHelper.removeTag('store_id');
     
     // Clear OrderProvider data
     _onLogoutCallback?.call();
   }
   ```

---

## Push Notification System

### NotificationHelper Architecture

The `NotificationHelper` is a singleton class that manages OneSignal integration:

```dart
class NotificationHelper {
  static const String _appId = 'your-onesignal-app-id';
  
  // 1. Initialize OneSignal
  static Future<void> initialize() async {
    OneSignal.initialize(_appId);
    await OneSignal.Notifications.requestPermission(true);
    
    // Set up event listeners
    OneSignal.Notifications.addForegroundWillDisplayListener(_onForegroundWillDisplay);
    OneSignal.Notifications.addClickListener(_onNotificationClicked);
  }
}
```

### Notification Event Flow

1. **Initialization** (App Startup)
   - OneSignal SDK initialized with App ID
   - Permission requested from user
   - Event listeners registered

2. **User Authentication**
   - External User ID set to store ID
   - Tags added for store identification
   - User segmentation enabled

3. **Notification Reception**
   ```
   Server → OneSignal → Device → App
   ↓
   _onForegroundWillDisplay (if app is open)
   ↓
   _onNotificationClicked (if user taps notification)
   ↓
   _handleNotificationNavigation (route to appropriate screen)
   ```

4. **Notification Types Handled**
   - `new_order`: Navigate to order details or refresh order list
   - `order_update`: Handle order status changes
   - `store_update`: Navigate to store settings

### Integration with AuthProvider

```dart
// On Login
await NotificationHelper.setExternalUserId(_storeID);
await NotificationHelper.sendTag('store_id', _storeID);
await NotificationHelper.sendTag('store_name', _storeData?.name ?? 'Unknown Store');

// On Logout
await NotificationHelper.removeExternalUserId();
await NotificationHelper.removeTag('store_id');
await NotificationHelper.removeTag('store_name');
```

---

## WebSocket Real-time Updates

### WebSocketService Architecture

The `WebSocketService` provides enterprise-level WebSocket functionality:

```dart
class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  
  // Stream controllers for different message types
  final StreamController<Map<String, dynamic>> _orderUpdateController;
  final StreamController<String> _connectionStatusController;
  
  // Public streams
  Stream<Map<String, dynamic>> get orderUpdates;
  Stream<String> get connectionStatus;
}
```

### Connection Lifecycle

1. **Connection Establishment**
   ```dart
   Future<void> connect(String url) async {
     _lastUrl = url;
     _isConnecting = true;
     _shouldReconnect = true;
     
     await _performConnection(url);
   }
   ```

2. **Automatic Reconnection with Exponential Backoff**
   ```dart
   void _scheduleReconnect() {
     final delay = _reconnectDelay * pow(2, _reconnectAttempts);
     _reconnectTimer = Timer(delay, () {
       if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
         _attemptReconnect();
       }
     });
   }
   ```

3. **Heartbeat Mechanism**
   ```dart
   void _startPingTimer() {
     _pingTimer = Timer.periodic(_pingInterval, (timer) {
       if (_channel != null) {
         _channel!.sink.add(jsonEncode({'type': 'ping'}));
       }
     });
   }
   ```

4. **Message Processing**
   ```dart
   void _handleMessage(dynamic data) {
     try {
       final Map<String, dynamic> message = jsonDecode(data);
       
       if (message['type'] == 'pong') {
         // Handle heartbeat response
         return;
       }
       
       // Forward to order update stream
       _orderUpdateController.add(message);
     } catch (e) {
       print('Error processing WebSocket message: $e');
     }
   }
   ```

### Integration with OrderProvider

```dart
class OrderProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _orderStreamSubscription;
  StreamSubscription<String>? _connectionStatusSubscription;
  
  void initializeWebsocket(String storeID) {
    final wsUrl = 'wss://your-websocket-server.com/stores/$storeID/orders';
    _webSocketService.connect(wsUrl);
    _subscribeToOrderUpdates();
    _subscribeToConnectionStatus();
  }
  
  void _subscribeToOrderUpdates() {
    _orderStreamSubscription = _webSocketService.orderUpdates.listen(
      (orderData) => _handleWebsocketOrderUpdate(orderData),
      onError: (error) => log('Websocket order stream error - $error'),
    );
  }
}
```

---

## Error Handling System

### Enhanced ApiResponse Model

The `ApiResponse` class provides structured error handling:

```dart
class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;
  
  // Factory constructors for different scenarios
  factory ApiResponse.success(T data, {String? message}) { ... }
  factory ApiResponse.error(String error, {int? statusCode}) { ... }
  factory ApiResponse.fromHttpResponse(http.Response response) { ... }
}
```

### Custom Exception Classes

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}
```

### HTTP Status Code Handling

```dart
factory ApiResponse.fromHttpResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
    case 201:
      return ApiResponse.success(jsonDecode(response.body));
    case 400:
      return ApiResponse.error('Bad request. Please check your input.');
    case 401:
      throw UnauthorizedException('Authentication required');
    case 403:
      return ApiResponse.error('Access denied');
    case 404:
      return ApiResponse.error('Requested resource not found');
    case 408:
      throw NetworkException('Request timeout');
    case 422:
      return ApiResponse.error('Invalid data provided');
    case 429:
      return ApiResponse.error('Too many requests. Please try again later.');
    case 500:
      return ApiResponse.error('Server error. Please try again.');
    case 502:
    case 503:
      throw NetworkException('Service temporarily unavailable');
    default:
      return ApiResponse.error('Unexpected error occurred');
  }
}
```

### ErrorHandlingService Usage

```dart
class ErrorHandlingService {
  static void handleApiError(BuildContext context, dynamic error) {
    String userMessage = 'An unexpected error occurred';
    
    if (error is ApiException) {
      userMessage = error.message;
    } else if (error is NetworkException) {
      userMessage = 'Network connection error. Please check your internet connection.';
    } else if (error is UnauthorizedException) {
      userMessage = 'Your session has expired. Please log in again.';
      _showLogoutDialog(context);
      return;
    }
    
    _showErrorSnackBar(context, userMessage);
  }
}
```

---

## Order Management Flow

### OrderProvider State Management

```dart
class OrderProvider with ChangeNotifier {
  // Status tracking
  OrderStatus _status = OrderStatus.initial;
  OrderActionStatus _actionStatus = OrderActionStatus.idle;
  String? _error;
  
  // Order data
  List<FainzyUserOrder> _allOrders = [];
  List<FainzyUserOrder> _pendingOrders = [];
  List<FainzyUserOrder> _activeOrders = [];
  List<FainzyUserOrder> _pastOrders = [];
  
  // WebSocket integration
  String _connectionStatus = 'Disconnected';
  bool _isWebsocketInitialized = false;
}
```

### Order Data Flow

1. **Initial Load**
   ```dart
   Future<void> fetchOrders([int? subentityId, String? filter]) async {
     _setStatus(OrderStatus.loading);
     
     final orders = await _orderService.fetchOrders(effectiveSubentityId, filter);
     _allOrders = orders;
     _categorizeOrders();
     _setStatus(OrderStatus.success);
   }
   ```

2. **Real-time Updates via WebSocket**
   ```dart
   void _handleWebsocketOrderUpdate(Map<String, dynamic> orderData) {
     final eventType = orderData['type'] ?? 'order_update';
     
     if (eventType == 'new_order' || eventType == 'order_notification') {
       _playNewOrderSound();
       _refreshOrdersFromWebsocket();
     } else {
       // Update individual order
       final updatedOrder = FainzyUserOrder.fromJson(orderData);
       _updateOrderInList(updatedOrder);
     }
     
     _categorizeOrders();
     notifyListeners();
   }
   ```

3. **Order Categorization**
   ```dart
   void _categorizeOrders() {
     _pendingOrders = _allOrders.where((order) => order.status == 'pending').toList();
     _pastOrders = _allOrders.where((order) => 
       order.status == 'completed' || 
       order.status == 'rejected' || 
       order.status == 'cancelled'
     ).toList();
     _activeOrders = _allOrders.where((order) => 
       order.status != 'pending' &&
       order.status != 'completed' && 
       order.status != 'rejected' && 
       order.status != 'cancelled'
     ).toList();
   }
   ```

### UI Integration

```dart
class OrderManagementScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        // Status-based UI rendering
        if (orderProvider.status == OrderStatus.loading) {
          return LoadingWidget();
        }
        
        if (orderProvider.status == OrderStatus.error) {
          return ErrorWidget(orderProvider.error);
        }
        
        return Column(
          children: [
            _buildConnectionStatusIndicator(orderProvider),
            _buildOrdersList(orderProvider),
          ],
        );
      },
    );
  }
}
```

---

## Key Components Interaction

### Authentication → WebSocket → Orders Flow

```
1. User Login (AuthProvider)
   ↓
2. Store authentication data locally
   ↓
3. Set OneSignal external user ID
   ↓
4. Trigger post-auth callback
   ↓
5. Initialize WebSocket (OrderProvider)
   ↓
6. Connect to real-time order updates
   ↓
7. Fetch initial order data
   ↓
8. Listen for real-time updates
   ↓
9. Update UI automatically
```

### Error Handling Integration

```
API Call → ApiResponse → Exception Handling → User Notification
    ↓           ↓              ↓                    ↓
Network     Success/Error   Custom Exceptions   SnackBar/Dialog
Request     Factory         (Api/Network/Auth)   with user message
```

### Real-time Update Flow

```
Server Event → WebSocket → OrderProvider → UI Update
     ↓            ↓            ↓             ↓
Order Status   Message      State Change   Re-render
Changed        Received     Notification   Components
```

---

## State Management Pattern

### Provider Pattern Implementation

1. **State Definition**
   ```dart
   class OrderProvider with ChangeNotifier {
     // Private state variables
     OrderStatus _status = OrderStatus.initial;
     List<FainzyUserOrder> _allOrders = [];
     
     // Public getters
     OrderStatus get status => _status;
     List<FainzyUserOrder> get allOrders => _allOrders;
     
     // State mutation methods
     void _setStatus(OrderStatus status) {
       if (_status != status) {
         _status = status;
         notifyListeners(); // Trigger UI updates
       }
     }
   }
   ```

2. **Provider Registration**
   ```dart
   MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => AuthProvider()),
       ChangeNotifierProvider(create: (_) => OrderProvider()),
       // ... other providers
     ],
     child: App(),
   )
   ```

3. **Provider Consumption**
   ```dart
   Consumer<OrderProvider>(
     builder: (context, orderProvider, child) {
       return orderProvider.isLoading 
         ? LoadingWidget()
         : OrderListWidget(orders: orderProvider.allOrders);
     },
   )
   ```

### Cross-Provider Communication

```dart
// AuthProvider sets up callbacks for OrderProvider
authProvider.setPostAuthCallback((storeID) {
  orderProvider.initializeWebsocket(storeID);
});

authProvider.setLogoutCallback(() {
  orderProvider.clearData();
});
```

---

## Configuration and Setup

### Required Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5                    # State management
  onesignal_flutter: ^5.0.4          # Push notifications
  web_socket_channel: ^2.4.0         # WebSocket communication
  http: ^1.1.0                       # HTTP requests
  shared_preferences: ^2.2.3         # Local storage
  # ... other dependencies
```

### Android Configuration

```gradle
// android/app/build.gradle
defaultConfig {
    minSdkVersion 21  // Required for OneSignal
    targetSdkVersion flutter.targetSdkVersion
}
```

### Environment Setup

```dart
// .env file
ONESIGNAL_APP_ID=your-onesignal-app-id
WEBSOCKET_URL=wss://your-websocket-server.com
API_BASE_URL=https://your-api-server.com
```

### OneSignal Setup Checklist

1. Create OneSignal account and app
2. Get App ID from OneSignal dashboard
3. Configure Android/iOS push certificates
4. Replace `'your-onesignal-app-id'` in NotificationHelper
5. Test push notifications in development/production

### WebSocket Server Requirements

Your WebSocket server should:
1. Accept connections at `/stores/{storeId}/orders`
2. Send JSON messages with order updates
3. Handle ping/pong heartbeat messages
4. Support reconnection attempts

---

## Debugging and Monitoring

### Connection Status Monitoring

The app provides real-time connection status:
```dart
Widget _buildConnectionStatusIndicator(OrderProvider orderProvider) {
  return Container(
    child: Row(
      children: [
        Icon(orderProvider.isWebsocketConnected ? Icons.wifi : Icons.wifi_off),
        Text('Connection: ${orderProvider.connectionStatus}'),
      ],
    ),
  );
}
```

### Error Logging

```dart
// All services include comprehensive logging
log('OrderProvider: Websocket connection status: $status');
log('OrderProvider: Received order update from websocket - ${orderData['id']}');
log('OrderProvider: Error handling websocket order update - $e');
```

### Testing Notifications

1. Use OneSignal dashboard to send test notifications
2. Include additional data: `{"type": "new_order", "order_id": "123"}`
3. Monitor app logs for notification handling

---

## Best Practices and Patterns

### Error Handling Best Practices

1. **Always use try-catch blocks** for async operations
2. **Provide user-friendly error messages** instead of technical details
3. **Handle different error types** (network, API, authentication)
4. **Show loading states** during operations
5. **Implement retry mechanisms** for failed operations

### State Management Best Practices

1. **Keep state immutable** - create new objects instead of modifying existing ones
2. **Minimize notifyListeners() calls** - only call when state actually changes
3. **Use specific status enums** instead of boolean flags
4. **Separate concerns** - different providers for different features
5. **Implement proper disposal** - clean up resources in dispose methods

### WebSocket Best Practices

1. **Implement reconnection logic** with exponential backoff
2. **Use heartbeat/ping-pong** to detect connection issues
3. **Handle connection state properly** - connecting, connected, disconnected, error
4. **Graceful error handling** - don't crash on malformed messages
5. **Clean disconnection** - properly close connections when not needed

---

This documentation provides a comprehensive understanding of how all the components work together to create a robust, real-time store management application with enterprise-level error handling and push notification capabilities.
