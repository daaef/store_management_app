# Visual Flow Diagrams - Store Management App

## 1. Application Startup Flow

```
App Start
    ↓
Initialize Flutter Binding
    ↓
Load Environment Variables (.env)
    ↓
Initialize OneSignal (NotificationHelper.initialize())
    ├── Set App ID
    ├── Request Permissions
    └── Setup Event Listeners
    ↓
Setup Device Orientation
    ↓
Create MultiProvider with:
    ├── AuthProvider
    ├── OrderProvider  
    ├── StoreProvider
    └── NavigationProvider
    ↓
Run App
    ↓
AppWithWebsocketListener Widget
    ├── Setup post-auth callback
    ├── Setup logout callback
    └── Check if already authenticated
    ↓
AuthProvider._checkAuthStatus()
    ├── Load stored credentials
    ├── If authenticated → trigger callbacks
    └── If not → show login screen
```

## 2. Authentication Flow

```
User enters Store ID
    ↓
AuthProvider.login(storeId)
    ↓
Set state to "authenticating"
    ↓
Call FainzyApiClient.authenticateStore()
    ↓
API Response
    ├── Success (200) ──────────────┐
    │                               ↓
    │                           Save to SharedPreferences:
    │                               ├── isLoggedIn: true
    │                               ├── storeId: "1234567"
    │                               ├── apiToken: "abc123..."
    │                               └── storeID: "internal_id"
    │                               ↓
    │                           OneSignal Integration:
    │                               ├── setExternalUserId(storeID)
    │                               ├── sendTag('store_id', storeID)
    │                               └── sendTag('store_name', storeName)
    │                               ↓
    │                           Set AuthState.authenticated
    │                               ↓
    │                           Trigger _postAuthCallback(storeID)
    │                               ↓
    │                           OrderProvider.initializeWebsocket(storeID)
    │                               ↓
    │                           Navigate to Order Management
    │
    └── Error (4xx/5xx) ────────────┐
                                    ↓
                                Set AuthState.error
                                    ↓
                                Show error message
                                    ↓
                                Stay on login screen
```

## 3. WebSocket Connection Flow

```
OrderProvider.initializeWebsocket(storeID)
    ↓
Create WebSocket URL: wss://server.com/stores/{storeID}/orders
    ↓
WebSocketService.connect(url)
    ↓
Set _isConnecting = true
    ↓
Create WebSocketChannel
    ├── Success ────────────────────┐
    │                               ↓
    │                           Connection Established
    │                               ├── _connectionStatusController.add('Connected')
    │                               ├── _startPingTimer() (every 30s)
    │                               └── Listen for messages
    │                               ↓
    │                           Subscribe to streams:
    │                               ├── orderUpdates.listen()
    │                               └── connectionStatus.listen()
    │                               ↓
    │                           Ready for real-time updates
    │
    └── Error ──────────────────────┐
                                    ↓
                                _scheduleReconnect()
                                    ↓
                                Exponential backoff delay
                                    ↓
                                Retry connection (max 5 attempts)
```

## 4. Real-time Order Update Flow

```
Server sends order update
    ↓
WebSocket receives message
    ↓
WebSocketService._handleMessage()
    ├── JSON.decode(message)
    ├── Check message type
    │   ├── 'ping' → ignore
    │   ├── 'pong' → update heartbeat
    │   └── order data → forward to stream
    └── _orderUpdateController.add(orderData)
    ↓
OrderProvider._subscribeToOrderUpdates() listener
    ↓
OrderProvider._handleWebsocketOrderUpdate(orderData)
    ├── Extract event type
    │   ├── 'new_order' ────────────┐
    │   ├── 'order_notification' ───┤
    │   │                           ↓
    │   │                       Play sound notification
    │   │                           ↓
    │   │                       _refreshOrdersFromWebsocket()
    │   │                           ↓
    │   │                       Fetch all orders from API
    │   │                           ↓
    │   │                       Update _allOrders list
    │   │
    │   └── 'order_update' ─────────┐
    │                               ↓
    │                           Parse individual order
    │                               ↓
    │                           Update specific order in list
    │                               ↓
    │                           _categorizeOrders()
    └── notifyListeners() ────────────────┐
                                          ↓
                                      UI automatically rebuilds
                                          ├── Order count badges update
                                          ├── Order lists refresh
                                          └── Connection status shows
```

## 5. Push Notification Flow

```
Server triggers notification
    ↓
OneSignal Cloud Service
    ↓
Device receives push notification
    ├── App in Foreground ──────────┐
    │                               ↓
    │                           _onForegroundWillDisplay()
    │                               ├── Log notification received
    │                               └── Display notification
    │
    └── User taps notification ─────┐
                                    ↓
                                _onNotificationClicked()
                                    ↓
                                Extract additionalData
                                    ├── type: 'new_order'
                                    └── order_id: '12345'
                                    ↓
                                _handleNotificationNavigation()
                                    ├── 'new_order' → Navigate to order details
                                    ├── 'order_update' → Refresh orders
                                    └── 'store_update' → Go to settings
```

## 6. Error Handling Flow

```
API Call/WebSocket Operation
    ↓
Try-Catch Block
    ├── Success ────────────────────┐
    │                               ↓
    │                           Continue normal flow
    │
    └── Exception ──────────────────┐
                                    ↓
                                Check Exception Type
                                    ├── ApiException ──────────┐
                                    │                           ↓
                                    │                       Extract user message
                                    │                           ↓
                                    │                       Show SnackBar
                                    │
                                    ├── NetworkException ──────┐
                                    │                           ↓
                                    │                       "Network error" message
                                    │                           ↓
                                    │                       Show retry option
                                    │
                                    ├── UnauthorizedException ─┐
                                    │                           ↓
                                    │                       "Session expired" dialog
                                    │                           ↓
                                    │                       Force logout → Login screen
                                    │
                                    └── Unknown Exception ─────┐
                                                                ↓
                                                            "Unexpected error" message
                                                                ↓
                                                            Log error details
```

## 7. Order Management Screen Component Interaction

```
OrderManagementScreen
    ↓
Consumer<OrderProvider>
    ├── Status Check
    │   ├── loading → SpinKitWave
    │   ├── error → ErrorView with retry
    │   └── success → Main Content
    │
    └── Main Content Layout
        ├── _buildConnectionStatusIndicator()
        │   ├── WebSocket status icon
        │   └── Connection status text
        │
        ├── _buildSearchAndStatsSection()
        │   ├── Search bar
        │   └── Order statistics
        │
        ├── _buildTabSection()
        │   ├── All Orders tab
        │   ├── Pending Orders tab
        │   ├── Active Orders tab
        │   └── Past Orders tab
        │
        └── _buildOrdersTabView()
            ├── Filtered order list
            ├── Pull-to-refresh
            └── Individual OrderItemWidget
```

## 8. State Management Data Flow

```
User Action (tap, swipe, etc.)
    ↓
Widget calls Provider method
    ↓
Provider updates internal state
    ├── _status = OrderStatus.loading
    ├── _allOrders = newOrdersList
    └── _error = null
    ↓
Provider calls notifyListeners()
    ↓
All Consumer<OrderProvider> widgets rebuild
    ├── OrderManagementScreen
    ├── OrderItemWidget
    └── Connection status indicator
    ↓
UI reflects new state
    ├── Loading indicators show/hide
    ├── Order lists update
    └── Error messages display
```

## 9. Complete Data Flow from Server to UI

```
1. Server Event
    ↓
2. WebSocket Message
    ↓
3. WebSocketService processes
    ↓
4. OrderProvider receives update
    ↓
5. OrderProvider modifies state
    ↓
6. notifyListeners() called
    ↓
7. Consumer widgets rebuild
    ↓
8. UI shows updated data
    ↓
9. User sees real-time change

Parallel to this:
- OneSignal sends push notification
- NotificationHelper handles click
- Navigation updates if needed
- Sound notification plays
```

## 10. Lifecycle Management

```
App Startup
    ↓
Providers created and initialized
    ↓
Authentication check
    ├── Authenticated → Initialize services
    └── Not authenticated → Show login
    ↓
WebSocket connection established
    ↓
Real-time updates active
    ↓
User interaction and data flow
    ↓
App backgrounded
    ├── WebSocket maintains connection
    └── Push notifications active
    ↓
App foregrounded
    ├── Reconnect if needed
    └── Refresh data
    ↓
User logout
    ├── Clear all data
    ├── Disconnect WebSocket
    ├── Remove OneSignal user ID
    └── Return to login screen
    ↓
App termination
    ├── Providers disposed
    ├── WebSocket closed
    └── Resources cleaned up
```

## Key Integration Points

### 1. AuthProvider ↔ OrderProvider
- **Trigger**: `_postAuthCallback?.call(_storeID)`
- **Action**: Initialize WebSocket connection
- **Result**: Real-time order updates enabled

### 2. AuthProvider ↔ NotificationHelper
- **Login**: Set external user ID and tags
- **Logout**: Remove user ID and tags
- **Result**: Targeted push notifications

### 3. WebSocketService ↔ OrderProvider
- **Connection**: Stream subscription setup
- **Updates**: Real-time order data flow
- **Errors**: Connection status monitoring

### 4. OrderProvider ↔ UI
- **State Changes**: notifyListeners() calls
- **UI Updates**: Consumer widget rebuilds
- **User Actions**: Provider method calls

### 5. Error Handling Integration
- **API Calls**: ApiResponse factory methods
- **Exceptions**: Custom exception classes
- **User Feedback**: ErrorHandlingService display methods

This visual flow documentation should help you understand exactly how data flows through the application and how all the components interact with each other in real-time.
