import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://fainzy.tech/api';

  Future<dynamic> getOrders() async {
    final response = await http.get(Uri.parse('https://fainzy.tech/orders'));
    return response.body;
  }

  // Get current subentity ID from storage
  Future<int?> getSubEntityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('menu_subentity_id');
  }

  // Save subentity ID to storage with menu prefix
  Future<void> saveSubEntityId(int subEntityId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('menu_subentity_id', subEntityId);
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('menu_auth_token');
  }

  // Save authentication token with menu prefix
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('menu_auth_token', token);
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
