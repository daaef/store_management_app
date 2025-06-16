# Complete Flutter Provider Architecture - Pinia Style Guide

*A comprehensive guide showing all 6 providers organized in Pinia-style architecture for Vue/Nuxt developers*

---

## 🏪 Complete Store Structure Overview

### Store Organization (Pinia → Flutter)

```typescript
// Pinia Store Structure (Reference for Vue developers)
stores/
├── auth.js              // Authentication & user session
├── orders.js            // Order management & real-time updates  
├── store.js             // Store data & business info
├── menu.js              // Menu items & catalog management
├── navigation.js        // UI navigation & routing state
├── storeSetup.js        // Store onboarding & configuration
├── notifications.js     // Push notifications & alerts
└── websocket.js         // Real-time connection management
```

```dart
// Flutter Provider Structure (Complete Implementation)
providers/
├── auth_provider.dart         // ≈ stores/auth.js
├── order_provider.dart        // ≈ stores/orders.js  
├── store_provider.dart        // ≈ stores/store.js
├── menu_provider.dart         // ≈ stores/menu.js
├── navigation_provider.dart   // ≈ stores/navigation.js
├── store_setup_provider.dart  // ≈ stores/storeSetup.js
└── helpers/
    └── notification_helper.dart // ≈ stores/notifications.js (Static service)
```

---

## 🎯 Quick Reference: Pinia → Flutter Mapping

| **Pinia Concept** | **Flutter Provider Equivalent** | **Usage** |
|-------------------|----------------------------------|-----------|
| `defineStore('auth', {})` | `class AuthProvider with ChangeNotifier` | Store definition |
| `state: () => ({})` | `private fields + getters` | Reactive state |
| `getters: {}` | `get propertyName => computed` | Computed properties |
| `actions: {}` | `async methods` | State mutations & API calls |
| `$patch()` | `notifyListeners()` | Trigger reactivity |
| `$subscribe()` | `Consumer<Provider>` | Listen to changes |
| `$reset()` | `clearData()` method | Reset store state |
| `$dispose()` | `dispose()` override | Cleanup resources |
| `storeToRefs()` | `Consumer<Provider>(builder:)` | Reactive references |
| Store composition | `MultiProvider` + callbacks | Cross-store communication |

---

## 🏗️ Complete Store Implementations

### 1. Authentication Store (auth_provider.dart)

**Purpose**: User authentication, session management, OneSignal integration

#### Pinia Equivalent
```javascript
// stores/auth.js
export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: null,
    isLoggedIn: false,
    loading: false,
    error: null,
    authState: 'initial',
    storeData: null
  }),
  
  getters: {
    isAuthenticated: (state) => !!state.token && state.authState === 'authenticated',
    userName: (state) => state.user?.name || 'Guest',
    storeId: (state) => state.storeData?.id
  },
  
  actions: {
    async login(storeId) { /* auth logic */ },
    async logout() { /* cleanup logic */ },
    async checkAuthStatus() { /* restore session */ }
  }
})
```

#### Flutter Implementation
```dart
class AuthProvider with ChangeNotifier {
  // === STATE ===
  AuthState _authState = AuthState.initial;
  String _storeId = '';
  String _token = '';
  String? _error;
  StoreData? _storeData;
  bool _loading = false;

  // === GETTERS ===
  AuthState get authState => _authState;
  bool get isLoggedIn => _authState == AuthState.authenticated;
  String get storeId => _storeId;
  String get token => _token;
  String? get error => _error;
  StoreData? get storeData => _storeData;
  bool get loading => _loading;
  
  // Computed properties
  bool get isAuthenticated => _token.isNotEmpty && _authState == AuthState.authenticated;
  String get userName => _storeData?.name ?? 'Guest';
  String get storeID => _storeData?.internalId ?? '';

  // === ACTIONS ===
  Future<bool> login(String storeId) async {
    _setLoading(true);
    try {
      _authState = AuthState.authenticating;
      notifyListeners();

      final response = await _apiClient.authenticateStore(storeId: storeId);
      
      if (response.status == 'success') {
        await _saveAuthData(response.data, storeId);
        await _initializePostAuthServices();
        
        _authState = AuthState.authenticated;
        return true;
      }
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
    await _cleanupServices();
    _resetState();
    notifyListeners();
  }

  // Cross-store communication
  Function(String)? _postAuthCallback;
  VoidCallback? _onLogoutCallback;

  void setPostAuthCallback(Function(String)? callback) => _postAuthCallback = callback;
  void setLogoutCallback(VoidCallback? callback) => _onLogoutCallback = callback;
}
```

---

### 2. Order Management Store (order_provider.dart)

**Purpose**: Order fetching, real-time updates, WebSocket management, sound notifications

#### Pinia Equivalent
```javascript
// stores/orders.js
export const useOrderStore = defineStore('orders', {
  state: () => ({
    allOrders: [],
    pendingOrders: [],
    activeOrders: [],
    pastOrders: [],
    selectedOrder: null,
    loading: false,
    error: null,
    connectionStatus: 'disconnected',
    soundEnabled: true
  }),

  getters: {
    totalOrders: (state) => state.allOrders.length,
    ordersByStatus: (state) => (status) => state.allOrders.filter(o => o.status === status),
    isConnected: (state) => state.connectionStatus === 'connected'
  },

  actions: {
    async fetchOrders() { /* fetch logic */ },
    async updateOrderStatus(id, status) { /* update logic */ },
    initializeWebSocket(storeId) { /* websocket setup */ },
    handleRealtimeUpdate(data) { /* real-time handling */ }
  }
})
```

#### Flutter Implementation
```dart
class OrderProvider with ChangeNotifier {
  // === STATE ===
  List<FainzyUserOrder> _allOrders = [];
  List<FainzyUserOrder> _pendingOrders = [];
  List<FainzyUserOrder> _activeOrders = [];
  List<FainzyUserOrder> _pastOrders = [];
  FainzyUserOrder? _selectedOrder;
  OrderStatus _status = OrderStatus.initial;
  String? _error;
  String _connectionStatus = 'Disconnected';
  bool _soundNotificationsEnabled = true;

  // === GETTERS ===
  List<FainzyUserOrder> get allOrders => _allOrders;
  List<FainzyUserOrder> get pendingOrders => _pendingOrders;
  List<FainzyUserOrder> get activeOrders => _activeOrders;
  List<FainzyUserOrder> get pastOrders => _pastOrders;
  OrderStatus get status => _status;
  String? get error => _error;
  String get connectionStatus => _connectionStatus;
  
  // Computed properties
  bool get isLoading => _status == OrderStatus.loading;
  bool get hasOrders => _allOrders.isNotEmpty;
  int get totalOrders => _allOrders.length;

  // Parameterized getters
  List<FainzyUserOrder> getOrdersByStatus(String status) {
    return _allOrders.where((order) => order.status == status).toList();
  }

  // === ACTIONS ===
  Future<void> fetchOrders([int? subentityId, String? filter]) async {
    _setStatus(OrderStatus.loading);
    try {
      final orders = await _orderService.fetchOrders(subentityId, filter);
      _allOrders = orders;
      _categorizeOrders();
      _setStatus(OrderStatus.success);
    } catch (e) {
      _setError('Failed to fetch orders: $e');
    }
  }

  void initializeWebsocket(String storeID) {
    _webSocketService.connect('wss://api.example.com/stores/$storeID/orders');
    _subscribeToOrderUpdates();
    _subscribeToConnectionStatus();
  }

  Future<void> updateOrderStatus({required int orderId, required String status}) async {
    try {
      await _orderService.updateOrderStatus(orderId: orderId, status: status);
      _updateOrderInLists(orderId, status);
    } catch (e) {
      _setError('Failed to update order: $e');
    }
  }

  void clearData() {
    _allOrders.clear();
    _pendingOrders.clear();
    _activeOrders.clear();
    _pastOrders.clear();
    _setStatus(OrderStatus.initial);
    notifyListeners();
  }
}
```

---

### 3. Store Data Provider (store_provider.dart)

**Purpose**: Store business information, statistics, store status management

#### Pinia Equivalent
```javascript
// stores/store.js
export const useStoreStore = defineStore('store', {
  state: () => ({
    storeData: null,
    statistics: null,
    storeStatus: 'closed',
    loading: false,
    error: null
  }),

  getters: {
    isStoreOpen: (state) => state.storeStatus === 'open',
    formattedEarnings: (state) => formatCurrency(state.statistics?.totalEarnings),
    storeInfo: (state) => ({
      name: state.storeData?.name,
      location: state.storeData?.location
    })
  },

  actions: {
    async loadStoreData(storeId) { /* load store info */ },
    async updateStoreStatus(status) { /* update status */ },
    async fetchStatistics() { /* get analytics */ }
  }
})
```

#### Flutter Implementation
```dart
class StoreProvider with ChangeNotifier {
  // === STATE ===
  StoreData? _storeData;
  OrderStatistics? _statistics;
  StoreStatus _storeStatus = StoreStatus.close;
  bool _loading = false;
  String? _error;

  // === GETTERS ===
  StoreData? get storeData => _storeData;
  OrderStatistics? get statistics => _statistics;
  StoreStatus get storeStatus => _storeStatus;
  bool get loading => _loading;
  String? get error => _error;
  
  // Computed properties
  bool get isStoreOpen => _storeStatus == StoreStatus.open;
  String get formattedEarnings => CurrencyFormatter.format(_statistics?.totalEarnings ?? 0);
  Map<String, dynamic> get storeInfo => {
    'name': _storeData?.name,
    'location': _storeData?.location,
    'isOpen': isStoreOpen
  };

  // === ACTIONS ===
  Future<void> loadStoreData(int storeId) async {
    _setLoading(true);
    try {
      _storeData = await _statisticsRepository.getStoreData(storeId);
      await fetchStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load store data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStoreStatus(StoreStatus status) async {
    try {
      await _apiClient.updateStoreStatus(status.value);
      _storeStatus = status;
      await _saveStoreStatus(status);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update store status: $e');
    }
  }

  Future<void> fetchStatistics() async {
    try {
      _statistics = await _statisticsRepository.getOrderStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch statistics: $e');
    }
  }

  void clearData() {
    _storeData = null;
    _statistics = null;
    _storeStatus = StoreStatus.close;
    _error = null;
    notifyListeners();
  }
}
```

---

### 4. Menu Management Store (menu_provider.dart)

**Purpose**: Menu items, catalog management, simple CRUD operations

#### Pinia Equivalent
```javascript
// stores/menu.js
export const useMenuStore = defineStore('menu', {
  state: () => ({
    menuItems: [],
    loading: false,
    error: null
  }),

  getters: {
    totalItems: (state) => state.menuItems.length,
    itemsByCategory: (state) => (category) => state.menuItems.filter(item => item.category === category)
  },

  actions: {
    addMenuItem(item) { /* add item */ },
    deleteMenuItem(id) { /* remove item */ },
    updateMenuItem(id, data) { /* update item */ }
  }
})
```

#### Flutter Implementation
```dart
class MenuProvider with ChangeNotifier {
  // === STATE ===
  List<MenuItem> _menuItems = [
    MenuItem(name: 'Burger', price: 10.99),
    MenuItem(name: 'Pizza', price: 12.99),
  ];

  // === GETTERS ===
  List<MenuItem> get menuItems => _menuItems;
  
  // Computed properties
  int get totalItems => _menuItems.length;
  List<MenuItem> getItemsByCategory(String category) {
    return _menuItems.where((item) => item.category == category).toList();
  }

  // === ACTIONS ===
  void addMenuItem(MenuItem item) {
    _menuItems.add(item);
    notifyListeners();
  }

  void deleteMenuItem(String name) {
    _menuItems.removeWhere((item) => item.name == name);
    notifyListeners();
  }

  void updateMenuItem(String name, MenuItem updatedItem) {
    final index = _menuItems.indexWhere((item) => item.name == name);
    if (index >= 0) {
      _menuItems[index] = updatedItem;
      notifyListeners();
    }
  }

  void clearData() {
    _menuItems.clear();
    notifyListeners();
  }
}

class MenuItem {
  final String name;
  final double price;
  final String category;

  MenuItem({required this.name, required this.price, this.category = 'default'});
}
```

---

### 5. Navigation Store (navigation_provider.dart)

**Purpose**: UI navigation state, tab management, routing

#### Pinia Equivalent
```javascript
// stores/navigation.js
export const useNavigationStore = defineStore('navigation', {
  state: () => ({
    currentPageIndex: 0,
    navigationHistory: [],
    canGoBack: false
  }),

  getters: {
    currentPage: (state) => state.pages[state.currentPageIndex],
    hasHistory: (state) => state.navigationHistory.length > 0
  },

  actions: {
    setPage(index) { /* change page */ },
    goBack() { /* navigate back */ },
    clearHistory() { /* reset navigation */ }
  }
})
```

#### Flutter Implementation
```dart
class NavigationProvider with ChangeNotifier {
  // === STATE ===
  int _currentPageIndex = 0;
  List<int> _navigationHistory = [];
  
  // Navigation keys for each tab
  final List<GlobalKey<NavigatorState>> navigators = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // === GETTERS ===
  int get currentPageIndex => _currentPageIndex;
  List<int> get navigationHistory => _navigationHistory;
  
  // Computed properties
  bool get canGoBack => _navigationHistory.isNotEmpty;
  bool get hasHistory => _navigationHistory.length > 1;

  // === ACTIONS ===
  void onPageChanged(int index) {
    _navigationHistory.add(_currentPageIndex);
    _currentPageIndex = index;
    notifyListeners();
  }

  Future<bool> onWillPop() async {
    final navigator = navigators[_currentPageIndex].currentState;
    if (navigator != null && await navigator.maybePop()) {
      return false;
    }
    return true;
  }

  void goBack() {
    if (_navigationHistory.isNotEmpty) {
      _currentPageIndex = _navigationHistory.removeLast();
      notifyListeners();
    }
  }

  void clearHistory() {
    _navigationHistory.clear();
    notifyListeners();
  }
}
```

---

### 6. Store Setup Provider (store_setup_provider.dart)

**Purpose**: Store onboarding, multi-step form management, store configuration

#### Pinia Equivalent
```javascript
// stores/storeSetup.js
export const useStoreSetupStore = defineStore('storeSetup', {
  state: () => ({
    currentStep: 0,
    stepIndex: 0,
    formData: {
      storeName: '',
      description: '',
      phone: '',
      location: null,
      schedule: {}
    },
    status: 'initial',
    error: null,
    validationErrors: {}
  }),

  getters: {
    isValidStep: (state) => (step) => validateStep(state.formData, step),
    canProceed: (state) => state.validationErrors.length === 0,
    completionProgress: (state) => (state.stepIndex / state.totalSteps) * 100
  },

  actions: {
    nextStep() { /* advance step */ },
    previousStep() { /* go back */ },
    updateFormData(field, value) { /* update field */ },
    async submitSetup() { /* submit form */ }
  }
})
```

#### Flutter Implementation
```dart
class StoreSetupProvider with ChangeNotifier {
  // === STATE ===
  StoreSetupStatus _status = StoreSetupStatus.initial;
  StoreSetupStep _currentStep = StoreSetupStep.basicInfo;
  int _stepIndex = 0;
  String? _error;
  bool _isInitialized = false;

  // Form fields
  String _storeName = '';
  String _storeDescription = '';
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  String _selectedCurrency = 'JPY';
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 18, minute: 0);
  Set<int> _workingDays = {1, 2, 3, 4, 5};
  Location? _location;

  // === GETTERS ===
  StoreSetupStatus get status => _status;
  StoreSetupStep get currentStep => _currentStep;
  int get stepIndex => _stepIndex;
  String? get error => _error;
  String get storeName => _storeName;
  String get storeDescription => _storeDescription;
  Location? get location => _location;
  
  // Computed properties
  bool get canProceed => _isCurrentStepValid();
  double get completionProgress => (_stepIndex / 4) * 100;
  bool get isLastStep => _stepIndex == 4;

  // === ACTIONS ===
  void nextStep() {
    if (_stepIndex < 4) {
      _stepIndex++;
      _currentStep = StoreSetupStep.values[_stepIndex];
      notifyListeners();
    }
  }

  void previousStep() {
    if (_stepIndex > 0) {
      _stepIndex--;
      _currentStep = StoreSetupStep.values[_stepIndex];
      notifyListeners();
    }
  }

  void updateStoreName(String value) {
    _storeName = value;
    notifyListeners();
  }

  void updateStoreDescription(String value) {
    _storeDescription = value;
    notifyListeners();
  }

  void updateLocation(Location location) {
    _location = location;
    notifyListeners();
  }

  Future<bool> submitSetup() async {
    _setStatus(StoreSetupStatus.submitting);
    try {
      final storeData = _buildStoreData();
      await _apiClient.createStore(storeData);
      _setStatus(StoreSetupStatus.success);
      return true;
    } catch (e) {
      _setError('Failed to create store: $e');
      _setStatus(StoreSetupStatus.failed);
      return false;
    }
  }

  void reset() {
    _status = StoreSetupStatus.initial;
    _currentStep = StoreSetupStep.basicInfo;
    _stepIndex = 0;
    _storeName = '';
    _storeDescription = '';
    _location = null;
    _error = null;
    notifyListeners();
  }
}
```

---

### 7. Notification Service (notification_helper.dart)

**Purpose**: OneSignal integration, push notifications, static service pattern

#### Pinia Equivalent
```javascript
// stores/notifications.js
export const useNotificationStore = defineStore('notifications', {
  state: () => ({
    initialized: false,
    playerId: null,
    tags: {},
    permissions: false
  }),

  actions: {
    async initialize() { /* OneSignal setup */ },
    async setUserId(userId) { /* set external ID */ },
    async addTag(key, value) { /* add user tag */ },
    async removeTag(key) { /* remove tag */ }
  }
})
```

#### Flutter Implementation (Static Service)
```dart
class NotificationHelper {
  // === STATIC STATE ===
  static bool _initialized = false;
  static String? _playerId;
  static Map<String, String> _tags = {};

  // === GETTERS ===
  static bool get initialized => _initialized;
  static String? get playerId => _playerId;
  static Map<String, String> get tags => Map.from(_tags);

  // === ACTIONS ===
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      OneSignal.initialize(_appId);
      await OneSignal.Notifications.requestPermission(true);
      
      OneSignal.Notifications.addForegroundWillDisplayListener(_onForegroundWillDisplay);
      OneSignal.Notifications.addClickListener(_onNotificationClicked);

      _playerId = await getPlayerId();
      _initialized = true;
    } catch (e) {
      print('Failed to initialize OneSignal: $e');
    }
  }

  static Future<void> setExternalUserId(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    try {
      await OneSignal.login(userId);
    } catch (e) {
      print('Failed to set OneSignal external user ID: $e');
    }
  }

  static Future<void> sendTag(String key, String value) async {
    try {
      await OneSignal.User.addTags({key: value});
      _tags[key] = value;
    } catch (e) {
      print('Failed to send OneSignal tag: $e');
    }
  }

  static Future<void> removeTag(String key) async {
    try {
      await OneSignal.User.removeTags([key]);
      _tags.remove(key);
    } catch (e) {
      print('Failed to remove OneSignal tag: $e');
    }
  }

  static Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      _tags.clear();
    } catch (e) {
      print('Failed to remove OneSignal external user ID: $e');
    }
  }
}
```

---

## 🔄 Store Registration & Initialization

### MultiProvider Setup (like Pinia createPinia())

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services (like Nuxt plugins)
  await NotificationHelper.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        // Core stores
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        
        // UI stores
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        
        // Setup store
        ChangeNotifierProvider(create: (_) => StoreSetupProvider()),
      ],
      child: AppWithWebsocketListener(),
    ),
  );
}
```

### Cross-Store Communication Setup

```dart
class AppWithWebsocketListener extends StatefulWidget {
  @override
  State<AppWithWebsocketListener> createState() => _AppWithWebsocketListenerState();
}

class _AppWithWebsocketListenerState extends State<AppWithWebsocketListener> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupStoreCallbacks();
    });
  }

  void _setupStoreCallbacks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    
    // Auth → Order communication
    authProvider.setPostAuthCallback((storeID) {
      orderProvider.initializeWebsocket(storeID);
      storeProvider.loadStoreData(int.parse(storeID));
    });
    
    // Auth → All stores cleanup
    authProvider.setLogoutCallback(() {
      orderProvider.clearData();
      storeProvider.clearData();
    });
  }
}
```

---

## 🎨 Usage Patterns in UI

### Single Store Consumer (like Pinia storeToRefs)

```dart
// Basic reactive component
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.loading) {
      return CircularProgressIndicator();
    }
    
    if (!authProvider.isAuthenticated) {
      return LoginScreen();
    }
    
    return DashboardScreen(userName: authProvider.userName);
  },
)
```

### Multiple Store Consumer (like Pinia store composition)

```dart
// Multi-store reactive component
Consumer2<AuthProvider, OrderProvider>(
  builder: (context, authProvider, orderProvider, child) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${authProvider.userName}\'s Store'),
        actions: [
          Icon(
            orderProvider.connectionStatus == 'Connected' 
              ? Icons.wifi 
              : Icons.wifi_off,
            color: orderProvider.connectionStatus == 'Connected' 
              ? Colors.green 
              : Colors.red,
          ),
        ],
      ),
      body: OrderListWidget(
        orders: orderProvider.allOrders,
        isLoading: orderProvider.isLoading,
        onOrderTap: (order) => orderProvider.selectOrder(order),
      ),
    );
  },
)
```

### Selector Pattern (like Pinia specific getters)

```dart
// Listen to specific computed property only
Selector<OrderProvider, int>(
  selector: (context, orderProvider) => orderProvider.totalOrders,
  builder: (context, totalOrders, child) {
    return Text('Total Orders: $totalOrders');
  },
)
```

---

## 🚀 Key Benefits for Vue/Nuxt Developers

### 1. **Familiar Mental Model**
- Same store organization as Pinia
- Similar state/getters/actions pattern
- Cross-store communication like Pinia composition

### 2. **Reactive State Management**
- `notifyListeners()` = Pinia's reactivity
- `Consumer<T>` = Vue's reactive components
- Computed properties through getters

### 3. **TypeScript-like Safety**
- Dart's strong typing system
- Compile-time error checking
- IntelliSense support

### 4. **Developer Experience**
- Hot reload like Vite
- Flutter DevTools = Vue DevTools
- Familiar debugging patterns

### 5. **State Persistence**
- SharedPreferences = localStorage
- Automatic hydration on app restart
- Cross-platform state management

This architecture provides the same development experience as Pinia while leveraging Flutter's reactive UI system and Dart's type safety. The mental model remains consistent, making it easy for Vue/Nuxt developers to understand and maintain.
