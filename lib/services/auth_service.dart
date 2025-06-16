import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'fainzy_api_client.dart';

class AuthService {
  static const String _apiTokenKey = 'api_token';
  static const String _storeIdKey = 'store_id';
  static const String _isLoggedInKey = 'is_logged_in';

  final FainzyApiClient _apiClient = FainzyApiClient();

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get stored API token
  Future<String?> getApiToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiTokenKey);
  }

  /// Get stored store ID
  Future<String?> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storeIdKey);
  }

  /// Login with store ID
  Future<bool> login(String storeId) async {
    try {
      log('AuthService: Attempting login with store ID: $storeId');
      
      // Authenticate with the API using store ID
      final response = await _apiClient.authenticateStore(storeId: storeId);
      
      if (response.status == 'success' && response.data != null) {
        final token = response.data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_apiTokenKey, token);
          await prefs.setString(_storeIdKey, storeId);
          await prefs.setBool(_isLoggedInKey, true);
          
          log('AuthService: Successfully logged in with store ID: $storeId');
          return true;
        }
      }
      
      log('AuthService: Login failed - ${response.message}');
      return false;
    } catch (e) {
      log('AuthService: Login failed - $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiTokenKey);
      await prefs.remove(_storeIdKey);
      await prefs.setBool(_isLoggedInKey, false);
      
      log('AuthService: Successfully logged out');
    } catch (e) {
      log('AuthService: Logout failed - $e');
    }
  }

  /// Save API token
  Future<void> saveApiToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiTokenKey, token);
  }
}
