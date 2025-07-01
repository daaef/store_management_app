import 'dart:developer';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:store_management_app/models/fainzy_menu.dart';
import 'package:store_management_app/services/fainzy_api_client.dart';

class MenuRepository {
  MenuRepository() : _apiClient = FainzyApiClient();

  final FainzyApiClient _apiClient;

  // ===============================
  // MENU CRUD OPERATIONS
  // ===============================

  /// Create a new menu
  Future<FainzyMenu> createMenu({
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required int categoryId,
  }) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final menuData = {
        'name': name,
        'description': description,
        'price': price,
        'category': categoryId,
        'discount': 0, // Always send discount as 0 by default
        if (discountPrice != null) 'discount_price': discountPrice,
      };

      final response = await _apiClient.createMenu(
        subEntityId: subentityId,
        data: menuData,
        apiToken: apiToken,
      );

      if (response.status == 'success' && response.data != null) {
        return FainzyMenu.fromJson(response.data as Map<String, dynamic>);
      }

      throw 'Failed to create menu: ${response.message}';
    } catch (e) {
      log('MenuRepository.createMenu error: $e');
      throw 'Failed to create menu: $e';
    }
  }

  /// Update an existing menu
  Future<FainzyMenu> updateMenu({
    required int menuId,
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required int categoryId,
  }) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final menuData = {
        'name': name,
        'description': description,
        'price': price,
        'category': categoryId,
        'discount': 0, // Always send discount as 0 by default
        if (discountPrice != null) 'discount_price': discountPrice,
      };

      final response = await _apiClient.updateMenu(
        subEntityId: subentityId,
        menuId: menuId,
        data: menuData,
        apiToken: apiToken,
      );

      if (response.status == 'success' && response.data != null) {
        return FainzyMenu.fromJson(response.data as Map<String, dynamic>);
      }

      throw 'Failed to update menu: ${response.message}';
    } catch (e) {
      log('MenuRepository.updateMenu error: $e');
      throw 'Failed to update menu: $e';
    }
  }

  /// Delete a menu
  Future<void> deleteMenu({required int menuId}) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final response = await _apiClient.deleteMenu(
        subEntityId: subentityId,
        menuId: menuId,
        apiToken: apiToken,
      );

      if (response.status != 'success') {
        throw 'Failed to delete menu: ${response.message}';
      }
    } catch (e) {
      log('MenuRepository.deleteMenu error: $e');
      throw 'Failed to delete menu: $e';
    }
  }

  // ===============================
  // IMAGE OPERATIONS
  // ===============================

  /// Upload a single image for a menu
  Future<Map<String, dynamic>> uploadMenuImage({
    required int menuId,
    required File imageFile,
  }) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final response = await _apiClient.uploadImage(
        subentityId: subentityId,
        image: imageFile,
        apiToken: apiToken,
      );

      if (response.status == 'success' && response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      throw 'Failed to upload image: ${response.message}';
    } catch (e) {
      log('MenuRepository.uploadMenuImage error: $e');
      throw 'Failed to upload image: $e';
    }
  }

  /// Upload multiple images for a menu
  Future<List<Map<String, dynamic>>> uploadImages({
    required int menuId,
    required List<File> images,
  }) async {
    final uploadedImages = <Map<String, dynamic>>[];
    
    for (final image in images) {
      try {
        final uploadedImage = await uploadMenuImage(menuId: menuId, imageFile: image);
        uploadedImages.add(uploadedImage);
      } catch (e) {
        log('Failed to upload image ${image.path}: $e');
        // Continue with other images
      }
    }
    
    return uploadedImages;
  }

  /// Delete an image by ID
  Future<void> deleteImageById({required int imageId}) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final response = await _apiClient.deleteImage(
        subEntityId: subentityId,
        imageId: imageId,
        apiToken: apiToken,
      );

      if (response.status != 'success') {
        throw 'Failed to delete image: ${response.message}';
      }
    } catch (e) {
      log('MenuRepository.deleteImageById error: $e');
      throw 'Failed to delete image: $e';
    }
  }

  // ===============================
  // CATEGORY OPERATIONS
  // ===============================

  /// Get all categories using the fetchCategoriesBySubentity method
  Future<List<dynamic>> getCategories() async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final response = await _apiClient.fetchCategoriesBySubentity(
        subEntityId: subentityId,
        apiToken: apiToken,
      );

      if (response.status == 'success' && response.data != null) {
        return response.data as List<dynamic>;
      }

      throw 'Failed to get categories: ${response.message}';
    } catch (e) {
      log('MenuRepository.getCategories error: $e');
      throw 'Failed to get categories: $e';
    }
  }

  /// Create a new category
  Future<dynamic> createCategory({required String name}) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final response = await _apiClient.createCategory(
        subEntityId: subentityId,
        data: {'name': name},
        apiToken: apiToken,
      );

      if (response.status == 'success' && response.data != null) {
        return response.data;
      }

      throw 'Failed to create category: ${response.message}';
    } catch (e) {
      log('MenuRepository.createCategory error: $e');
      throw 'Failed to create category: $e';
    }
  }

  // ===============================
  // HELPER METHODS
  // ===============================

  /// Get subentity ID from SharedPreferences
  Future<int?> _getSubentityId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Try different possible keys for subentity ID
      final possibleKeys = ['subentityId', 'storeID', 'StoreId', 'store_id'];
      
      for (final key in possibleKeys) {
        final value = prefs.getInt(key);
        if (value != null) {
          return value;
        }
        
        // Also try string values that can be parsed to int
        final stringValue = prefs.getString(key);
        if (stringValue != null) {
          final parsed = int.tryParse(stringValue);
          if (parsed != null) {
            return parsed;
          }
        }
      }
      
      log('MenuRepository: No subentity ID found in any expected key');
      return null;
    } catch (e) {
      log('MenuRepository._getSubentityId error: $e');
      return null;
    }
  }

  /// Get Fainzy API token from SharedPreferences
  Future<String?> _getFainzyApiToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Try different possible keys for the API token
      final possibleKeys = ['apiToken', 'FainzyApiToken', 'api_token', 'token'];
      
      for (final key in possibleKeys) {
        final token = prefs.getString(key);
        if (token != null && token.isNotEmpty) {
          return token;
        }
      }
      
      log('MenuRepository: No API token found in any expected key');
      return null;
    } catch (e) {
      log('MenuRepository._getFainzyApiToken error: $e');
      return null;
    }
  }
}
