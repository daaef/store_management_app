import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_management_app/models/api_response.dart';
import 'package:store_management_app/models/store_data.dart';
import 'package:store_management_app/models/location.dart';
import 'package:store_management_app/services/fainzy_api_client.dart';
import 'package:store_management_app/helpers/notification_helper.dart';

enum AuthState { initial, authenticating, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final FainzyApiClient _apiClient = FainzyApiClient();
  AuthState _authState = AuthState.initial;
  String _storeId = '';
  String _storeID = '';
  String _token = '';
  String? _error;
  StoreData? _storeData;

  // Callback for post-authentication actions
  Function(String storeID)? _postAuthCallback;

  AuthState get authState => _authState;
  bool get isLoggedIn => _authState == AuthState.authenticated;
  String get storeId => _storeId;
  String get storeID => _storeID;
  String get token => _token;
  String? get error => _error;
  StoreData? get storeData => _storeData;

  /// Set callback to be called after successful authentication
  void setPostAuthCallback(Function(String storeID)? callback) {
    _postAuthCallback = callback;
  }

  /// Set callback to be called on logout (to clear OrderProvider data)
  VoidCallback? _onLogoutCallback;
  
  void setLogoutCallback(VoidCallback? callback) {
    _onLogoutCallback = callback;
  }

  AuthProvider() {
    // Check stored authentication status on initialization
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    log('🔄 Checking authentication status on app startup...');
    
    // Fetch LastMile token on app startup (before checking auth status)
    await fetchLastMileTokenOnStartup();

    // Validate stored token with server
    final isValidToken = await validateStoredToken();
    
    if (!isValidToken) {
      log('❌ Stored token is invalid or missing');
      _authState = AuthState.unauthenticated;
      notifyListeners();
    } else {
      log('✅ Authentication status check completed successfully');
    }
  }

  Future<void> fetchLastMileTokenOnStartup() async {
    try {
      log('🔑 Starting LastMile token fetch...');
      final lastMileResponse = await _apiClient.fetchLastMileToken();
      log('🔑 LastMile response status: ${lastMileResponse.status}');
      log('🔑 LastMile response data: ${lastMileResponse.data}');
      log('🔑 LastMile response message: ${lastMileResponse.message}');
      
      if (lastMileResponse.status == 'success' && lastMileResponse.data != null) {
        final prefs = await SharedPreferences.getInstance();
        final lastMileToken = lastMileResponse.data as String;
        await prefs.setString('LastMileApiToken', lastMileToken);
        log('🔑 LastMile token saved successfully on startup: ${lastMileToken.substring(0, 20)}...');
        
        // Verify it was saved correctly
        final savedToken = prefs.getString('LastMileApiToken');
        log('🔑 Verification - saved token: ${savedToken?.substring(0, 20)}...');
      } else {
        log('⚠️ Failed to fetch LastMile token on startup: ${lastMileResponse.message}');
        log('⚠️ Response status: ${lastMileResponse.status}');
        log('⚠️ Response data: ${lastMileResponse.data}');
      }
    } catch (e) {
      log('⚠️ Error fetching LastMile token on startup: $e');
      log('⚠️ Error details: ${e.toString()}');
    }
  }

  Future<bool> login(String storeId) async {
    if (storeId.isEmpty) {
      _error = 'Store ID cannot be empty';
      _authState = AuthState.error;
      notifyListeners();
      return false;
    }

    try {
      log('🔄 Starting login process for store: $storeId');
      _authState = AuthState.authenticating;
      notifyListeners();

      final ApiResponse response = await _apiClient.authenticateStore(storeId: storeId);
      
      if (response.status == 'success') {
        final prefs = await SharedPreferences.getInstance();
        
        log('✅ Login API call successful');
        
        // Save authentication data
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('storeId', storeId);
        await prefs.setString('apiToken', response.data['token']);
        await prefs.setString('api_token', response.data['token']); // For backward compatibility
        await prefs.setString('storeID', response.data['subentity']['id']?.toString() ?? '');
        
        // Save subentity ID as int for OrderRepository
        final subentityId = response.data['subentity']['id'];
        if (subentityId != null) {
          await prefs.setInt('subentityId', subentityId is int ? subentityId : int.parse(subentityId.toString()));
        }
        
        // Update provider state
        _storeId = storeId;
        _storeID = response.data['subentity']['id']?.toString() ?? '';
        _token = response.data['token'];
        _authState = AuthState.authenticated;
        _error = null;
        
        // If the API returned store data, save it
        // The API returns store data in 'subentity' field based on last_mile_store pattern
        if (response.data['subentity'] != null) {
          final subentityData = response.data['subentity'] as Map<String, dynamic>;

          log('🏪 Processing store data from login response');
          _storeData = _mapSubentityToStoreData(subentityData);
          await prefs.setString('storeData', jsonEncode(_storeData!.toJson()));
        }
        
        notifyListeners();
        
        // Initialize post-authentication services
        await _initializePostAuthServices();
        
        log('🎉 Login completed successfully');
        return true;
      } else {
        _error = response.message ?? 'Authentication failed';
        _authState = AuthState.error;
        log('❌ Login failed: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _authState = AuthState.error;
      log('❌ Login error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Change the store status to logged out (status = 2) before clearing data
    try {
      await _apiClient.logoutStore(
        subEntityId: int.parse(_storeID),
        apiToken: _token,
      );
      log('Store status updated to logged out');
    } catch (e) {
      log('Error updating store status on logout: $e');
      // Continue with logout even if status update fails
    }

    // Clear authentication data
    await prefs.remove('isLoggedIn');
    await prefs.remove('storeId');
    await prefs.remove('apiToken');
    await prefs.remove('api_token');
    await prefs.remove('LastMileApiToken');
    await prefs.remove('storeID');
    await prefs.remove('subentityId');
    await prefs.remove('storeData');
    
    // Remove OneSignal external user ID and tags
    await NotificationHelper.removeExternalUserId();
    await NotificationHelper.removeTag('store_id');
    await NotificationHelper.removeTag('store_name');
    
    // Reset provider state
    _storeId = '';
    _storeID = '';
    _token = '';
    _storeData = null;
    _authState = AuthState.unauthenticated;
    
    // Call logout callback to clear OrderProvider data
    _onLogoutCallback?.call();
    
    notifyListeners();
  }

  Future<void> updateStoreData(StoreData storeData) async {
    _storeData = storeData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeData', storeData.toJson().toString());
    notifyListeners();
  }

  /// Check if LastMile token exists and refetch if needed
  Future<bool> ensureLastMileToken() async {
    final prefs = await SharedPreferences.getInstance();
    final existingToken = prefs.getString('LastMileApiToken');
    
    if (existingToken != null && existingToken.isNotEmpty) {
      log('🔑 LastMile token already exists: ${existingToken.substring(0, 20)}...');
      return true;
    }
    
    log('🔑 LastMile token missing, attempting to fetch...');
    await fetchLastMileTokenOnStartup();
    
    final newToken = prefs.getString('LastMileApiToken');
    return newToken != null && newToken.isNotEmpty;
  }

  /// Validate stored token with server
  Future<bool> validateStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedStoreId = prefs.getString('storeId');
      final storedToken = prefs.getString('apiToken') ?? prefs.getString('api_token');
      final storedStoreID = prefs.getString('storeID');
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      log('🔍 Validating stored token...');
      log('  - Store ID: $storedStoreId');
      log('  - Token exists: ${storedToken != null}');
      log('  - Store ID (internal): $storedStoreID');
      log('  - Is logged in flag: $isLoggedIn');

      // If no token or credentials, token is invalid
      if (!isLoggedIn || storedStoreId == null || storedToken == null) {
        log('❌ Token validation failed: Missing credentials');
        _authState = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }

      // Validate token with server by making a test API call
      log('🔄 Making test API call to validate token...');
      final ApiResponse response = await _apiClient.authenticateStore(storeId: storedStoreId);
      
      if (response.status == 'success') {
        log('✅ Token validation successful: Server confirmed authentication');
        
        // Update auth state and store data if needed
        _storeId = storedStoreId;
        _storeID = storedStoreID ?? '';
        _token = storedToken;
        _authState = AuthState.authenticated;
        
        // Update store data from response if available
        if (response.data != null && response.data['subentity'] != null) {
          final subentityData = response.data['subentity'];
          _storeData = _mapSubentityToStoreData(subentityData);
          await prefs.setString('storeData', jsonEncode(_storeData!.toJson()));
        }
        
        notifyListeners();
        
        // Initialize post-auth services
        await _initializePostAuthServices();
        
        return true;
      } else {
        log('❌ Token validation failed: Server rejected token');
        log('  - Response status: ${response.status}');
        log('  - Response message: ${response.message}');
        
        // Token is invalid, clear stored data
        await _clearInvalidTokenData();
        return false;
      }
    } catch (e) {
      log('❌ Token validation error: $e');
      
      // If there's a network error or other issue, assume token might still be valid
      // but mark as unauthenticated for safety
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Clear invalid token data from storage
  Future<void> _clearInvalidTokenData() async {
    log('🧹 Clearing invalid token data...');
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('isLoggedIn');
    await prefs.remove('storeId');
    await prefs.remove('apiToken');
    await prefs.remove('api_token');
    await prefs.remove('storeID');
    await prefs.remove('storeData');
    
    _storeId = '';
    _storeID = '';
    _token = '';
    _storeData = null;
    _authState = AuthState.unauthenticated;
    notifyListeners();
    
    log('✅ Invalid token data cleared');
  }

  /// Initialize post-authentication services
  Future<void> _initializePostAuthServices() async {
    try {
      log('🚀 Initializing post-authentication services...');
      
      // Set OneSignal external user ID for push notifications
      await NotificationHelper.setExternalUserId(_storeID);
      await NotificationHelper.sendTag('store_id', _storeID);
      await NotificationHelper.sendTag('store_name', _storeData?.name ?? 'Unknown Store');
      
      // Call post-authentication callback to initialize websockets
      _postAuthCallback?.call(_storeID);
      
      log('✅ Post-authentication services initialized');
    } catch (e) {
      log('⚠️ Error initializing post-auth services: $e');
      // Don't fail the entire auth process for post-auth service errors
    }
  }

  /// Re-validate token when app resumes from background
  Future<bool> revalidateTokenOnResume() async {
    log('🔄 Re-validating token on app resume...');
    
    if (!isLoggedIn) {
      log('ℹ️ No active session to validate');
      return false;
    }
    
    final isValid = await validateStoredToken();
    
    if (!isValid) {
      log('⚠️ Token expired or invalid - user needs to re-login');
      _authState = AuthState.unauthenticated;
      notifyListeners();
    }
    
    return isValid;
  }

  /// Maps subentity data from API response to StoreData model
  /// Now uses JSON serialization for proper parsing
  StoreData _mapSubentityToStoreData(Map<String, dynamic> subentityData) {
    try {
      // Use the JSON serializable fromJson method to parse the API response
      return StoreData.fromJson(subentityData);
    } catch (e) {
      log('Error parsing store data with fromJson: $e');
      // Fallback to manual parsing if needed
      return _fallbackStoreDataMapping(subentityData);
    }
  }

  /// Fallback method for manual parsing if JSON serialization fails
  StoreData _fallbackStoreDataMapping(Map<String, dynamic> subentityData) {
    Location? location;
    if (subentityData['location'] != null && subentityData['location'] is List) {
      final locationList = subentityData['location'] as List;
      if (locationList.isNotEmpty && locationList.first is Map<String, dynamic>) {
        try {
          location = Location.fromJson(locationList.first as Map<String, dynamic>);
        } catch (e) {
          log('Error parsing location: $e');
        }
      }
    }

    return StoreData(
      id: subentityData['id'] as int?,
      name: subentityData['name'] as String?,
      description: subentityData['description'] as String?,
      phoneNumber: subentityData['mobile_number'] as String?,
      currency: subentityData['currency'] as String?,
      startTime: subentityData['start_time'] as String?,
      closingTime: subentityData['closing_time'] as String?,
      openingDays: subentityData['opening_days'] as String?,
      location: location,
      setup: subentityData['setup'] as bool?,
      branch: subentityData['branch'] as String?,
      storeType: subentityData['store_type'] as String?,
      storeCategory: subentityData['store_category'] as String?,
      rating: (subentityData['rating'] as num?)?.toDouble(),
      totalReviews: (subentityData['total_reviews'] as num?)?.toInt(),
      status: subentityData['status'] as int?,
      notificationId: subentityData['notification_id'] as String?,
    );
  }
}
