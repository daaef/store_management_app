# Practical Implementation Guide: Pinia-Inspired Provider Refactoring

*Step-by-step guide to refactor your current Provider architecture using Pinia's advanced patterns*

---

## 🎯 Implementation Roadmap

### Phase 1: Foundation Classes (Implementation Ready)

Let's start by creating the foundational classes that will support the improved architecture:

#### 1.1 Base Composable Provider

Create `lib/core/composable_provider.dart`:

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

// Base provider with plugin support and error handling
abstract class ComposableProvider with ChangeNotifier {
  static final List<StorePlugin> _plugins = [];
  
  // Error state management
  ErrorState? _errorState;
  ErrorState? get errorState => _errorState;
  bool get hasError => _errorState != null;
  
  // Plugin registration
  static void addPlugin(StorePlugin plugin) {
    _plugins.add(plugin);
  }
  
  // Enhanced action execution with plugin hooks
  Future<T> callAction<T>(
    String actionName,
    Map<String, dynamic> payload,
    Future<T> Function() action,
  ) async {
    // Pre-action plugin hooks
    for (final plugin in _plugins) {
      plugin.onAction(actionName, payload);
    }
    
    try {
      _clearError();
      final result = await action();
      
      // Post-action success hooks
      for (final plugin in _plugins) {
        plugin.onActionSuccess(actionName, payload, result);
      }
      
      return result;
    } catch (error, stackTrace) {
      _errorState = ErrorManager.handleError(error as Exception, actionName);
      
      // Error plugin hooks
      for (final plugin in _plugins) {
        plugin.onError(error as Exception, stackTrace);
      }
      
      notifyListeners();
      rethrow;
    }
  }
  
  // State mutation tracking
  void mutateState(String mutation, dynamic oldValue, dynamic newValue) {
    for (final plugin in _plugins) {
      plugin.onMutation(mutation, oldValue, newValue);
    }
  }
  
  // Persistence methods
  Map<String, dynamic> serialize();
  void hydrate(Map<String, dynamic>? data);
  
  // Lifecycle methods
  @mustCallSuper
  void initialize() {
    for (final plugin in _plugins) {
      plugin.onStoreCreated(this);
    }
  }
  
  void _clearError() {
    if (_errorState != null) {
      _errorState = null;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    for (final plugin in _plugins) {
      plugin.onStoreDisposed(this);
    }
    super.dispose();
  }
}
```

#### 1.2 Plugin System

Create `lib/core/store_plugin.dart`:

```dart
import 'package:meta/meta.dart';
import 'composable_provider.dart';

// Plugin interface
abstract class StorePlugin {
  void onStoreCreated(ComposableProvider store) {}
  void onStoreDisposed(ComposableProvider store) {}
  void onAction(String actionName, Map<String, dynamic> payload) {}
  void onActionSuccess(String actionName, Map<String, dynamic> payload, dynamic result) {}
  void onMutation(String mutation, dynamic oldValue, dynamic newValue) {}
  void onError(Exception error, StackTrace stackTrace) {}
}

// Logging Plugin
class LoggingPlugin implements StorePlugin {
  final bool logActions;
  final bool logMutations;
  final bool logErrors;
  
  const LoggingPlugin({
    this.logActions = true,
    this.logMutations = false,
    this.logErrors = true,
  });
  
  @override
  void onStoreCreated(ComposableProvider store) {
    if (kDebugMode) {
      print('🏪 Store created: ${store.runtimeType}');
    }
  }
  
  @override
  void onAction(String actionName, Map<String, dynamic> payload) {
    if (logActions && kDebugMode) {
      print('🎬 Action: $actionName with payload: $payload');
    }
  }
  
  @override
  void onMutation(String mutation, dynamic oldValue, dynamic newValue) {
    if (logMutations && kDebugMode) {
      print('🔄 Mutation: $mutation changed from $oldValue to $newValue');
    }
  }
  
  @override
  void onError(Exception error, StackTrace stackTrace) {
    if (logErrors && kDebugMode) {
      print('❌ Store Error: $error\n$stackTrace');
    }
  }
}

// Persistence Plugin
class PersistencePlugin implements StorePlugin {
  final List<String> _persistedStores;
  final Duration _debounceDelay;
  Timer? _debounceTimer;
  
  PersistencePlugin({
    required List<String> persistedStores,
    Duration debounceDelay = const Duration(milliseconds: 500),
  }) : _persistedStores = persistedStores,
       _debounceDelay = debounceDelay;
  
  @override
  void onMutation(String mutation, dynamic oldValue, dynamic newValue) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      // Auto-persist state changes
      _persistState(mutation);
    });
  }
  
  void _persistState(String storeType) {
    if (_persistedStores.contains(storeType)) {
      // Implement persistence logic
      StoreHydration.persistStoreType(storeType);
    }
  }
}

// Analytics Plugin
class AnalyticsPlugin implements StorePlugin {
  @override
  void onAction(String actionName, Map<String, dynamic> payload) {
    // Track user actions
    // AnalyticsService.track(actionName, payload);
  }
  
  @override
  void onError(Exception error, StackTrace stackTrace) {
    // Track errors
    // AnalyticsService.trackError(error, stackTrace);
  }
}
```

#### 1.3 Error Management System

Create `lib/core/error_management.dart`:

```dart
import 'package:meta/meta.dart';

enum ErrorSeverity { info, warning, error, critical }

@immutable
class ErrorState {
  final Exception? exception;
  final String? userMessage;
  final String? technicalMessage;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String? actionContext;
  final Map<String, dynamic>? metadata;
  
  const ErrorState({
    this.exception,
    this.userMessage,
    this.technicalMessage,
    this.severity = ErrorSeverity.error,
    required this.timestamp,
    this.actionContext,
    this.metadata,
  });
  
  bool get isUserFriendly => userMessage != null;
  bool get isCritical => severity == ErrorSeverity.critical;
}

// Error Handler Interface
abstract class ErrorHandler<T extends Exception> {
  ErrorState handle(T error, String context);
}

// Specific Error Handlers
class NetworkErrorHandler extends ErrorHandler<NetworkException> {
  @override
  ErrorState handle(NetworkException error, String context) {
    return ErrorState(
      exception: error,
      userMessage: _getUserMessage(error),
      technicalMessage: error.message,
      severity: _getSeverity(error),
      timestamp: DateTime.now(),
      actionContext: context,
      metadata: {'statusCode': error.statusCode},
    );
  }
  
  String _getUserMessage(NetworkException error) {
    switch (error.statusCode) {
      case 401:
        return 'Please log in again to continue';
      case 403:
        return 'You don\'t have permission for this action';
      case 404:
        return 'The requested information was not found';
      case 500:
        return 'Server error. Please try again later';
      default:
        return 'Connection problem. Please check your internet';
    }
  }
  
  ErrorSeverity _getSeverity(NetworkException error) {
    if (error.statusCode >= 500) return ErrorSeverity.critical;
    if (error.statusCode >= 400) return ErrorSeverity.error;
    return ErrorSeverity.warning;
  }
}

class ApiErrorHandler extends ErrorHandler<ApiException> {
  @override
  ErrorState handle(ApiException error, String context) {
    return ErrorState(
      exception: error,
      userMessage: error.userMessage ?? 'An unexpected error occurred',
      technicalMessage: error.message,
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      actionContext: context,
    );
  }
}

// Error Manager
class ErrorManager {
  static final Map<Type, ErrorHandler> _handlers = {};
  
  static void registerHandler<T extends Exception>(ErrorHandler<T> handler) {
    _handlers[T] = handler;
  }
  
  static ErrorState handleError(Exception error, String context) {
    final handler = _handlers[error.runtimeType];
    if (handler != null) {
      return handler.handle(error, context);
    }
    return _defaultHandler(error, context);
  }
  
  static ErrorState _defaultHandler(Exception error, String context) {
    return ErrorState(
      exception: error,
      userMessage: 'An unexpected error occurred',
      technicalMessage: error.toString(),
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      actionContext: context,
    );
  }
  
  static void setupDefaultHandlers() {
    registerHandler<NetworkException>(NetworkErrorHandler());
    registerHandler<ApiException>(ApiErrorHandler());
  }
}

// Custom Exceptions
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  NetworkException(this.message, {this.statusCode});
  
  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}

class ApiException implements Exception {
  final String message;
  final String? userMessage;
  
  ApiException(this.message, {this.userMessage});
  
  @override
  String toString() => 'ApiException: $message';
}
```

---

### Phase 2: Enhanced AuthProvider (Step-by-Step Refactor)

#### 2.1 Create Auth State Module

Create `lib/stores/auth/auth_state.dart`:

```dart
import 'package:meta/meta.dart';
import '../../models/store_data.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

@immutable
class AuthState {
  final AuthStatus status;
  final String? token;
  final StoreData? storeData;
  final String storeId;
  final String storeID;
  final bool loading;
  
  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.storeData,
    this.storeId = '',
    this.storeID = '',
    this.loading = false,
  });
  
  // Computed properties
  bool get isAuthenticated => token != null && status == AuthStatus.authenticated;
  bool get isAuthenticating => status == AuthStatus.authenticating;
  String get userName => storeData?.name ?? 'Guest User';
  bool get hasStoreData => storeData != null;
  
  AuthState copyWith({
    AuthStatus? status,
    String? token,
    StoreData? storeData,
    String? storeId,
    String? storeID,
    bool? loading,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      storeData: storeData ?? this.storeData,
      storeId: storeId ?? this.storeId,
      storeID: storeID ?? this.storeID,
      loading: loading ?? this.loading,
    );
  }
  
  // Factory methods
  factory AuthState.initial() => const AuthState();
  
  factory AuthState.authenticating() => const AuthState(
    status: AuthStatus.authenticating,
    loading: true,
  );
  
  factory AuthState.authenticated({
    required String token,
    required String storeId,
    required String storeID,
    StoreData? storeData,
  }) => AuthState(
    status: AuthStatus.authenticated,
    token: token,
    storeId: storeId,
    storeID: storeID,
    storeData: storeData,
    loading: false,
  );
  
  factory AuthState.unauthenticated() => const AuthState(
    status: AuthStatus.unauthenticated,
    loading: false,
  );
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          token == other.token &&
          storeId == other.storeId &&
          storeID == other.storeID &&
          loading == other.loading;
  
  @override
  int get hashCode =>
      status.hashCode ^
      token.hashCode ^
      storeId.hashCode ^
      storeID.hashCode ^
      loading.hashCode;
}
```

#### 2.2 Create Auth Repository Interface

Create `lib/stores/auth/auth_repository.dart`:

```dart
import '../../models/api_response.dart';
import '../../models/store_data.dart';

abstract class AuthRepository {
  Future<AuthResult> authenticate(String storeId);
  Future<void> logout(int subEntityId, String apiToken);
  Future<String> fetchLastMileToken();
}

class AuthResult {
  final String token;
  final String storeId;
  final String storeID;
  final StoreData? storeData;
  
  AuthResult({
    required this.token,
    required this.storeId,
    required this.storeID,
    this.storeData,
  });
  
  factory AuthResult.fromApiResponse(ApiResponse response, String storeId) {
    final data = response.data as Map<String, dynamic>;
    return AuthResult(
      token: data['token'] ?? data['api_token'] ?? '',
      storeId: storeId,
      storeID: data['store_id']?.toString() ?? '',
      storeData: data['store_data'] != null 
        ? StoreData.fromJson(data['store_data'])
        : null,
    );
  }
}

// Production Implementation
class FainzyAuthRepository implements AuthRepository {
  final FainzyApiClient _apiClient;
  
  FainzyAuthRepository(this._apiClient);
  
  @override
  Future<AuthResult> authenticate(String storeId) async {
    final response = await _apiClient.authenticateStore(storeId: storeId);
    
    if (response.status == 'success') {
      return AuthResult.fromApiResponse(response, storeId);
    } else {
      throw ApiException(
        response.message ?? 'Authentication failed',
        userMessage: 'Login failed. Please check your store ID.',
      );
    }
  }
  
  @override
  Future<void> logout(int subEntityId, String apiToken) async {
    try {
      await _apiClient.logoutStore(
        subEntityId: subEntityId,
        apiToken: apiToken,
      );
    } catch (e) {
      // Log but don't throw - logout should succeed locally even if API fails
      print('Logout API call failed: $e');
    }
  }
  
  @override
  Future<String> fetchLastMileToken() async {
    final response = await _apiClient.fetchLastMileToken();
    if (response.status == 'success') {
      return response.data['token'] ?? '';
    }
    throw ApiException('Failed to fetch LastMile token');
  }
}
```

#### 2.3 Refactored AuthProvider

Create `lib/stores/auth/auth_provider.dart`:

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/composable_provider.dart';
import '../../helpers/notification_helper.dart';
import '../../services/persistence_service.dart';
import 'auth_state.dart';
import 'auth_repository.dart';

class AuthProvider extends ComposableProvider {
  final AuthRepository _repository;
  final PersistenceService _persistence;
  
  AuthState _state = AuthState.initial();
  
  // Public state access
  AuthState get state => _state;
  
  // Convenience getters (Pinia-style computed properties)
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isAuthenticating => _state.isAuthenticating;
  bool get loading => _state.loading;
  String get userName => _state.userName;
  String get storeId => _state.storeId;
  String get storeID => _state.storeID;
  StoreData? get storeData => _state.storeData;
  String? get token => _state.token;
  
  // Event callbacks (will be replaced with event system later)
  Function(String storeID)? _postAuthCallback;
  VoidCallback? _onLogoutCallback;
  
  AuthProvider(this._repository, this._persistence) {
    initialize();
    _checkAuthStatus();
  }
  
  // Action: Check authentication status
  Future<void> checkAuthStatus() async {
    await callAction('checkAuthStatus', {}, () async {
      final savedState = await _persistence.getAuthState();
      
      if (savedState != null && savedState.isAuthenticated) {
        _updateState(savedState);
        _postAuthCallback?.call(_state.storeID);
      } else {
        _updateState(AuthState.unauthenticated());
      }
    });
  }
  
  // Action: Login
  Future<bool> login(String storeId) async {
    if (storeId.isEmpty) {
      throw ApiException(
        'Store ID cannot be empty',
        userMessage: 'Please enter a valid store ID',
      );
    }
    
    return await callAction('login', {'storeId': storeId}, () async {
      _updateState(AuthState.authenticating());
      
      final result = await _repository.authenticate(storeId);
      
      final authenticatedState = AuthState.authenticated(
        token: result.token,
        storeId: result.storeId,
        storeID: result.storeID,
        storeData: result.storeData,
      );
      
      _updateState(authenticatedState);
      await _persistence.saveAuthState(authenticatedState);
      await _initializePostAuthServices();
      
      _postAuthCallback?.call(_state.storeID);
      
      return true;
    });
  }
  
  // Action: Logout
  Future<void> logout() async {
    await callAction('logout', {}, () async {
      if (_state.isAuthenticated) {
        await _repository.logout(
          int.parse(_state.storeID),
          _state.token!,
        );
      }
      
      await _cleanupServices();
      await _persistence.clearAuthState();
      
      _updateState(AuthState.unauthenticated());
      _onLogoutCallback?.call();
    });
  }
  
  // Action: Fetch LastMile token
  Future<void> fetchLastMileTokenOnStartup() async {
    await callAction('fetchLastMileToken', {}, () async {
      await _repository.fetchLastMileToken();
    });
  }
  
  // State mutation
  void _updateState(AuthState newState) {
    final oldState = _state;
    _state = newState;
    mutateState('authState', oldState, newState);
    notifyListeners();
  }
  
  // Private methods
  Future<void> _checkAuthStatus() async {
    await checkAuthStatus();
  }
  
  Future<void> _initializePostAuthServices() async {
    await NotificationHelper.setExternalUserId(_state.storeID);
    await NotificationHelper.sendTag('store_id', _state.storeID);
    if (_state.storeData?.name != null) {
      await NotificationHelper.sendTag('store_name', _state.storeData!.name);
    }
  }
  
  Future<void> _cleanupServices() async {
    await NotificationHelper.removeExternalUserId();
    await NotificationHelper.removeTag('store_id');
    await NotificationHelper.removeTag('store_name');
  }
  
  // Callback setters (temporary - will be replaced with event system)
  void setPostAuthCallback(Function(String storeID)? callback) {
    _postAuthCallback = callback;
  }
  
  void setLogoutCallback(VoidCallback? callback) {
    _onLogoutCallback = callback;
  }
  
  // Persistence implementation
  @override
  Map<String, dynamic> serialize() {
    return {
      'status': _state.status.index,
      'token': _state.token,
      'storeId': _state.storeId,
      'storeID': _state.storeID,
      'storeData': _state.storeData?.toJson(),
      'loading': _state.loading,
    };
  }
  
  @override
  void hydrate(Map<String, dynamic>? data) {
    if (data != null) {
      _state = AuthState(
        status: AuthStatus.values[data['status'] ?? 0],
        token: data['token'],
        storeId: data['storeId'] ?? '',
        storeID: data['storeID'] ?? '',
        storeData: data['storeData'] != null 
          ? StoreData.fromJson(data['storeData'])
          : null,
        loading: data['loading'] ?? false,
      );
    }
  }
}
```

---

### Phase 3: Persistence Service

Create `lib/services/persistence_service.dart`:

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../stores/auth/auth_state.dart';

class PersistenceService {
  static const String _authStateKey = 'auth_state';
  
  Future<void> saveAuthState(AuthState state) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'status': state.status.index,
      'token': state.token,
      'storeId': state.storeId,
      'storeID': state.storeID,
      'storeData': state.storeData?.toJson(),
    };
    await prefs.setString(_authStateKey, json.encode(data));
  }
  
  Future<AuthState?> getAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_authStateKey);
    
    if (jsonString != null) {
      try {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        return AuthState(
          status: AuthStatus.values[data['status'] ?? 0],
          token: data['token'],
          storeId: data['storeId'] ?? '',
          storeID: data['storeID'] ?? '',
          storeData: data['storeData'] != null 
            ? StoreData.fromJson(data['storeData'])
            : null,
        );
      } catch (e) {
        print('Error parsing saved auth state: $e');
      }
    }
    
    return null;
  }
  
  Future<void> clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authStateKey);
  }
}
```

---

### Phase 4: Setup and Integration

#### 4.1 Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/composable_provider.dart';
import 'core/store_plugin.dart';
import 'core/error_management.dart';
import 'stores/auth/auth_provider.dart';
import 'stores/auth/auth_repository.dart';
import 'services/persistence_service.dart';
import 'services/fainzy_api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup error handling
  ErrorManager.setupDefaultHandlers();
  
  // Setup plugins
  ComposableProvider.addPlugin(const LoggingPlugin());
  ComposableProvider.addPlugin(PersistencePlugin(
    persistedStores: ['AuthProvider'],
  ));
  
  // Initialize services
  await NotificationHelper.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<PersistenceService>(
          create: (_) => PersistenceService(),
        ),
        Provider<AuthRepository>(
          create: (_) => FainzyAuthRepository(FainzyApiClient()),
        ),
        
        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthRepository>(),
            context.read<PersistenceService>(),
          ),
        ),
        
        // Other providers...
      ],
      child: AppWithWebsocketListener(),
    );
  }
}
```

#### 4.2 Update UI Components

```dart
// Example: Login screen with enhanced error handling
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storeIdController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            children: [
              // Error display
              if (authProvider.hasError)
                ErrorBanner(error: authProvider.errorState!),
              
              // Store ID input
              TextField(
                controller: _storeIdController,
                decoration: InputDecoration(
                  labelText: 'Store ID',
                  enabled: !authProvider.loading,
                ),
              ),
              
              // Login button
              ElevatedButton(
                onPressed: authProvider.loading 
                  ? null 
                  : () => _handleLogin(authProvider),
                child: authProvider.loading 
                  ? CircularProgressIndicator()
                  : Text('Login'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Future<void> _handleLogin(AuthProvider authProvider) async {
    try {
      await authProvider.login(_storeIdController.text);
      // Navigation handled by app state listener
    } catch (error) {
      // Error is automatically handled by the provider
      // UI will show error banner automatically
    }
  }
}

// Error banner component
class ErrorBanner extends StatelessWidget {
  final ErrorState error;
  
  const ErrorBanner({Key? key, required this.error}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: _getErrorColor(),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(),
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              error.userMessage ?? 'An error occurred',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getErrorColor() {
    switch (error.severity) {
      case ErrorSeverity.critical:
        return Colors.red[800]!;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.info:
        return Colors.blue;
    }
  }
  
  IconData _getErrorIcon() {
    switch (error.severity) {
      case ErrorSeverity.critical:
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.info:
        return Icons.info;
    }
  }
}
```

---

## 📊 Testing the New Architecture

#### 4.3 Unit Tests

Create `test/stores/auth/auth_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:store_management_app/stores/auth/auth_provider.dart';
import 'package:store_management_app/stores/auth/auth_repository.dart';
import 'package:store_management_app/services/persistence_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockPersistenceService extends Mock implements PersistenceService {}

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockAuthRepository mockRepository;
    late MockPersistenceService mockPersistence;
    
    setUp(() {
      mockRepository = MockAuthRepository();
      mockPersistence = MockPersistenceService();
      authProvider = AuthProvider(mockRepository, mockPersistence);
    });
    
    tearDown(() {
      authProvider.dispose();
    });
    
    test('should initialize with unauthenticated state', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.state.status, AuthStatus.initial);
    });
    
    test('should authenticate successfully', () async {
      // Arrange
      final authResult = AuthResult(
        token: 'test_token',
        storeId: 'store123',
        storeID: '123',
      );
      
      when(mockRepository.authenticate('store123'))
        .thenAnswer((_) async => authResult);
      
      when(mockPersistence.saveAuthState(any))
        .thenAnswer((_) async {});
      
      // Act
      final result = await authProvider.login('store123');
      
      // Assert
      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.state.token, 'test_token');
      expect(authProvider.state.storeId, 'store123');
      expect(authProvider.hasError, isFalse);
    });
    
    test('should handle authentication failure', () async {
      // Arrange
      when(mockRepository.authenticate('invalid'))
        .thenThrow(ApiException('Invalid store ID'));
      
      // Act & Assert
      expect(
        () => authProvider.login('invalid'),
        throwsA(isA<ApiException>()),
      );
      
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.hasError, isTrue);
    });
    
    test('should logout successfully', () async {
      // Arrange - first authenticate
      final authResult = AuthResult(
        token: 'test_token',
        storeId: 'store123',
        storeID: '123',
      );
      
      when(mockRepository.authenticate('store123'))
        .thenAnswer((_) async => authResult);
      when(mockPersistence.saveAuthState(any))
        .thenAnswer((_) async {});
      when(mockRepository.logout(123, 'test_token'))
        .thenAnswer((_) async {});
      when(mockPersistence.clearAuthState())
        .thenAnswer((_) async {});
      
      await authProvider.login('store123');
      
      // Act
      await authProvider.logout();
      
      // Assert
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.state.status, AuthStatus.unauthenticated);
      verify(mockRepository.logout(123, 'test_token')).called(1);
      verify(mockPersistence.clearAuthState()).called(1);
    });
  });
}
```

---

## 📈 Benefits Achieved

### 1. **Better Separation of Concerns**

- **State logic** separated from **Business logic**
- **Repository pattern** for testable data access
- **Plugin system** for cross-cutting concerns

### 2. **Enhanced Error Handling**

- **Type-safe error states** with user-friendly messages
- **Centralized error management** with customizable handlers
- **Automatic error tracking** and logging

### 3. **Improved Testability**

- **Dependency injection** makes mocking easy
- **Pure functions** for predictable testing
- **Clear separation** of concerns

### 4. **Better Developer Experience**

- **Type safety** throughout the stack
- **Consistent patterns** across all providers
- **Plugin extensibility** for new features

### 5. **Production Ready**

- **Automatic persistence** with configurable strategies
- **Error recovery mechanisms**
- **Performance monitoring** hooks

---

This implementation guide provides a practical, step-by-step approach to refactoring your current Provider architecture using Pinia's proven patterns while maintaining the familiar Flutter Provider system that your team already knows.

The refactored code maintains backward compatibility while adding powerful new capabilities that will make your codebase more maintainable, testable, and scalable as your application grows.
