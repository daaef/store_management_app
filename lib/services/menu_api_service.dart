import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fainzy_menu.dart';
import '../models/fainzy_category.dart';
import 'fainzy_api_client.dart';

class MenuApiService {
  static const String baseUrl = 'fainzy.tech';
  final FainzyApiClient _apiClient = FainzyApiClient();
  
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiToken');
  }

  Future<int?> _getSubEntityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('subentityId');
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  Future<List<FainzyMenu>> fetchMenus([int? categoryId]) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      String path = '/v1/core/subentities/$subEntityId/menu';
      Map<String, String> queryParams = {};
      if (categoryId != null && categoryId > 0) {
        queryParams['categoryId'] = '$categoryId';
      }

      final uri = Uri.https(baseUrl, path, queryParams.isEmpty ? null : queryParams);
      log('Fetching menus from: $uri');

      final response = await http.get(
        uri,
        headers: _getHeaders(token),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle different response formats
        List<dynamic> menusData;
        if (responseData is List) {
          // Direct array response
          menusData = responseData;
        } else if (responseData is Map) {
          if (responseData.containsKey('data') && responseData['data'] is List) {
            // Wrapped response with 'data' field
            menusData = responseData['data'] as List;
          } else if (responseData.containsKey('results') && responseData['results'] is List) {
            // Wrapped response with 'results' field
            menusData = responseData['results'] as List;
          } else {
            throw Exception('Unexpected menus response format. Expected array or object with data/results field. Got: ${responseData.keys}');
          }
        } else {
          throw Exception('Unexpected menus response format: ${responseData.runtimeType}');
        }
        
        return menusData.map((item) => FainzyMenu.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch menus: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error fetching menus: $e');
      rethrow;
    }
  }

  Future<FainzyMenu> updateMenu(FainzyMenu menu) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      if (menu.id == null) {
        throw Exception('Menu ID is required for update');
      }

      final uri = Uri.https(baseUrl, '/v1/core/subentities/$subEntityId/menu/${menu.id}');
      log('Updating menu at: $uri');
      log('Update data: ${menu.toJson()}');

      final response = await http.patch(
        uri,
        headers: _getHeaders(token),
        body: json.encode(menu.toJson()),
      );

      log('Update menu response status: ${response.statusCode}');
      log('Update menu response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return FainzyMenu.fromJson(responseData);
      } else {
        throw Exception('Failed to update menu: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error updating menu: $e');
      rethrow;
    }
  }

  Future<FainzyMenu> updateMenuStatus(int menuId, String status) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      final uri = Uri.https(baseUrl, '/v1/core/subentities/$subEntityId/menu/$menuId');
      log('Updating menu status at: $uri');
      log('Update status data: {"status": "$status"}');

      final response = await http.patch(
        uri,
        headers: _getHeaders(token),
        body: json.encode({'status': status}),
      );

      log('Update menu status response status: ${response.statusCode}');
      log('Update menu status response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return FainzyMenu.fromJson(responseData);
      } else {
        throw Exception('Failed to update menu status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error updating menu status: $e');
      rethrow;
    }
  }

  Future<List<FainzyCategory>> fetchCategories() async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      final uri = Uri.https(baseUrl, '/v1/core/subentities/$subEntityId/categories');
      log('Fetching categories from: $uri');

      final response = await http.get(
        uri,
        headers: _getHeaders(token),
      );

      log('Categories response status: ${response.statusCode}');
      log('Categories response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle different response formats
        List<dynamic> categoriesData;
        if (responseData is List) {
          // Direct array response
          categoriesData = responseData;
        } else if (responseData is Map) {
          if (responseData.containsKey('data') && responseData['data'] is List) {
            // Wrapped response with 'data' field
            categoriesData = responseData['data'] as List;
          } else if (responseData.containsKey('results') && responseData['results'] is List) {
            // Wrapped response with 'results' field
            categoriesData = responseData['results'] as List;
          } else {
            throw Exception('Unexpected categories response format. Expected array or object with data/results field. Got: ${responseData.keys}');
          }
        } else {
          throw Exception('Unexpected categories response format: ${responseData.runtimeType}');
        }
        
        final categories = categoriesData.map((item) => FainzyCategory.fromJson(item)).toList();
        return [FainzyCategory.all(), ...categories];
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<FainzyCategory> createCategory(String categoryName) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      final uri = Uri.https(baseUrl, '/v1/core/subentities/$subEntityId/categories');
      log('Creating category at: $uri');

      final requestBody = json.encode({
        'name': categoryName,
      });

      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: requestBody,
      );

      log('Create category response status: ${response.statusCode}');
      log('Create category response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return FainzyCategory.fromJson(responseData);
      } else {
        throw Exception('Failed to create category: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error creating category: $e');
      rethrow;
    }
  }

  Future<FainzyMenu> createMenu(FainzyMenu menu) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      final uri = Uri.https(baseUrl, '/v1/core/subentities/$subEntityId/menu');
      log('Creating menu at: $uri');

      final requestBody = json.encode(menu.toJson());
      log('Create menu request body: $requestBody');

      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: requestBody,
      );

      log('Create menu response status: ${response.statusCode}');
      log('Create menu response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // The API response has a nested structure: {"status": "success", "data": {...}}
        // We need to extract the actual menu data from the 'data' field
        if (responseData is Map && responseData.containsKey('data')) {
          return FainzyMenu.fromJson(responseData['data']);
        } else {
          // Fallback: try to parse the response directly (in case the structure changes)
          return FainzyMenu.fromJson(responseData);
        }
      } else {
        throw Exception('Failed to create menu: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error creating menu: $e');
      rethrow;
    }
  }

  Future<void> deleteMenu(int menuId) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      final uri = Uri.https(baseUrl, '/v1/core/subentities/$subEntityId/menu/$menuId');
      log('Deleting menu from: $uri');

      final response = await http.delete(
        uri,
        headers: _getHeaders(token),
      );

      log('Delete menu response status: ${response.statusCode}');
      log('Delete menu response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('Menu deleted successfully');
      } else {
        throw Exception('Failed to delete menu: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error deleting menu: $e');
      rethrow;
    }
  }

  // ===============================
  // SIDES MANAGEMENT
  // ===============================

  /// Fetch sides for a specific menu
  Future<List<Side>> fetchSidesByMenu(int menuId) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      final response = await _apiClient.fetchSidesByMenu(
        subEntityId: subEntityId,
        menuId: menuId,
        apiToken: token,
      );

      if (response.success && response.data != null) {
        final sidesData = response.data as List;
        return sidesData.map((item) => Side.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch sides: ${response.message}');
      }
    } catch (e) {
      log('Error fetching sides for menu $menuId: $e');
      rethrow;
    }
  }

  /// Create a new side for a menu
  Future<Side> createSide(Side side, int menuId) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      // Prepare side data for API
      final sideData = side.toJson();
      sideData['menu'] = menuId; // Associate with menu
      
      log('Creating side for menu $menuId: ${json.encode(sideData)}');

      final response = await _apiClient.createSide(
        subEntityId: subEntityId,
        data: sideData,
        apiToken: token,
      );

      if (response.success && response.data != null) {
        return Side.fromJson(response.data);
      } else {
        throw Exception('Failed to create side: ${response.message}');
      }
    } catch (e) {
      log('Error creating side: $e');
      rethrow;
    }
  }

  /// Update an existing side
  Future<Side> updateSide(Side side) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      if (side.id == null) {
        throw Exception('Side ID is required for update');
      }

      final sideData = side.toJson();
      log('Updating side ${side.id}: ${json.encode(sideData)}');

      final response = await _apiClient.updateSide(
        subEntityId: subEntityId,
        sideId: side.id!,
        data: sideData,
        apiToken: token,
      );

      if (response.success && response.data != null) {
        return Side.fromJson(response.data);
      } else {
        throw Exception('Failed to update side: ${response.message}');
      }
    } catch (e) {
      log('Error updating side: $e');
      rethrow;
    }
  }

  /// Delete a side
  Future<void> deleteSide(int sideId) async {
    try {
      final token = await _getAuthToken();
      final subEntityId = await _getSubEntityId();
      
      if (token == null) {
        throw Exception('No auth token found');
      }
      
      if (subEntityId == null) {
        throw Exception('No subentity ID found');
      }

      log('Deleting side $sideId');

      final response = await _apiClient.deleteSide(
        subEntityId: subEntityId,
        sideId: sideId,
        apiToken: token,
      );

      if (!response.success) {
        throw Exception('Failed to delete side: ${response.message}');
      }
    } catch (e) {
      log('Error deleting side: $e');
      rethrow;
    }
  }

  // ===============================
  // SIDE SYNCHRONIZATION
  // ===============================

  /// Synchronize sides for a menu - create new ones, update existing ones, and delete removed ones
  Future<void> syncMenuSides(int menuId, List<Side> newSides, List<Side> originalSides) async {
    try {
      log('🔄 Starting side synchronization for menu $menuId');
      log('📦 Original sides: ${originalSides.length}');
      log('🆕 New sides: ${newSides.length}');
      
      // Track which sides to create, update, or delete
      final sidesToCreate = <Side>[];
      final sidesToUpdate = <Side>[];
      final sidesToDelete = <Side>[];
      
      // Find sides that need to be created (negative IDs or IDs not in original)
      for (final newSide in newSides) {
        if (newSide.id == null || newSide.id! < 0) {
          // New side - needs to be created
          sidesToCreate.add(newSide);
          log('➕ Side to create: "${newSide.name}"');
        } else {
          // Check if it exists in original sides
          final originalSide = originalSides.firstWhere(
            (original) => original.id == newSide.id,
            orElse: () => Side(name: '', price: 0), // dummy side to indicate not found
          );
          
          if (originalSide.name?.isNotEmpty == true) {
            // Side exists - check if it needs updating
            if (!_sidesAreEqual(originalSide, newSide)) {
              sidesToUpdate.add(newSide);
              log('🔄 Side to update: "${newSide.name}" (ID: ${newSide.id})');
            }
          } else {
            // Side doesn't exist in original - create it
            sidesToCreate.add(newSide);
            log('➕ Side to create (unknown ID): "${newSide.name}"');
          }
        }
      }
      
      // Find sides that need to be deleted (in original but not in new)
      for (final originalSide in originalSides) {
        if (originalSide.id != null && originalSide.id! > 0) {
          final stillExists = newSides.any((newSide) => newSide.id == originalSide.id);
          if (!stillExists) {
            sidesToDelete.add(originalSide);
            log('🗑️ Side to delete: "${originalSide.name}" (ID: ${originalSide.id})');
          }
        }
      }
      
      // Execute the operations
      log('🚀 Executing side operations:');
      log('  - Creating: ${sidesToCreate.length} sides');
      log('  - Updating: ${sidesToUpdate.length} sides');
      log('  - Deleting: ${sidesToDelete.length} sides');
      
      // Create new sides
      for (final side in sidesToCreate) {
        try {
          final createdSide = await createSide(side, menuId);
          log('✅ Created side: "${createdSide.name}" (ID: ${createdSide.id})');
        } catch (e) {
          log('❌ Failed to create side "${side.name}": $e');
          rethrow;
        }
      }
      
      // Update existing sides
      for (final side in sidesToUpdate) {
        try {
          final updatedSide = await updateSide(side);
          log('✅ Updated side: "${updatedSide.name}" (ID: ${updatedSide.id})');
        } catch (e) {
          log('❌ Failed to update side "${side.name}": $e');
          rethrow;
        }
      }
      
      // Delete removed sides
      for (final side in sidesToDelete) {
        try {
          await deleteSide(side.id!);
          log('✅ Deleted side: "${side.name}" (ID: ${side.id})');
        } catch (e) {
          log('❌ Failed to delete side "${side.name}": $e');
          rethrow;
        }
      }
      
      log('🎉 Side synchronization completed successfully');
      
    } catch (e) {
      log('💥 Error during side synchronization: $e');
      rethrow;
    }
  }
  
    /// Helper method to compare if two sides are equal
    bool _sidesAreEqual(Side side1, Side side2) {
      return side1.name == side2.name &&
             side1.price == side2.price &&
             side1.isDefault == side2.isDefault;
    }
  }
