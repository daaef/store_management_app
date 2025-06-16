import 'dart:developer';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fainzy_menu.dart';
import '../models/menu_category.dart';
import '../models/menu_side.dart';
import '../models/fainzy_image.dart';
import '../services/fainzy_api_client.dart';

class MenuRepository {
  final FainzyApiClient _apiClient;

  const MenuRepository(this._apiClient);

  /// Get the Fainzy API token from shared preferences
  Future<String?> _getFainzyApiToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('FainzyApiToken');
  }

  /// Get the subentity ID from shared preferences
  Future<int?> _getSubentityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('subentityId');
  }

  // ===============================
  // CATEGORY OPERATIONS
  // ===============================

  /// Fetch all categories for the store
  Future<List<MenuCategory>> fetchCategories() async {
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
        final List<dynamic> data = response.data as List<dynamic>;
        final categories = data
            .map((e) => MenuCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // Add "All" category at the beginning
        return [MenuCategory.all(), ...categories];
      }
      
      return [MenuCategory.all()];
    } catch (e) {
      log('MenuRepository.fetchCategories error: $e');
      throw 'Failed to fetch categories: $e';
    }
  }

  /// Create a new category
  Future<MenuCategory> createCategory({required String name}) async {
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
        return MenuCategory.fromJson(response.data as Map<String, dynamic>);
      }

      throw 'Failed to create category: ${response.message}';
    } catch (e) {
      log('MenuRepository.createCategory error: $e');
      throw 'Failed to create category: $e';
    }
  }

  // ===============================
  // MENU OPERATIONS
  // ===============================

  /// Fetch all menus or menus by category
  Future<List<FainzyMenu>> fetchMenus({int? categoryId}) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final response = await _apiClient.fetchMenus(
        subEntityId: subentityId,
        apiToken: apiToken,
        categoryId: categoryId,
      );

      if (response.status == 'success' && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((e) => FainzyMenu.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      log('MenuRepository.fetchMenus error: $e');
      throw 'Failed to fetch menus: $e';
    }
  }

  /// Create a new menu item
  Future<FainzyMenu> createMenu({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? ingredients,
    double? discount,
    List<File>? images,
    List<MenuSide>? sides,
  }) async {
    final menu = FainzyMenu(
      name: name,
      description: description,
      price: price,
      category: categoryId,
      ingredients: ingredients,
      discount: discount,
      sides: sides?.map((side) => side.toJson()).toList(),
    );
    return await createMenuFromModel(menu: menu);
  }

  /// Create a new menu item from model
  Future<FainzyMenu> createMenuFromModel({required FainzyMenu menu}) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final menuData = menu.toJson();
      // Remove null values and adjust for server format
      menuData.removeWhere((key, value) => value == null);
      
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

  /// Update an existing menu item
  Future<FainzyMenu> updateMenu({
    required int menuId,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? ingredients,
    double? discount,
    List<File>? images,
    List<MenuSide>? sides,
  }) async {
    final menu = FainzyMenu(
      id: menuId,
      name: name,
      description: description,
      price: price,
      category: categoryId,
      ingredients: ingredients,
      discount: discount,
      sides: sides?.map((side) => side.toJson()).toList(),
    );
    return await updateMenuFromModel(menuId: menuId, menu: menu);
  }

  /// Update an existing menu item from model
  Future<FainzyMenu> updateMenuFromModel({
    required int menuId,
    required FainzyMenu menu,
  }) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final menuData = menu.toJson();
      // Remove null values and adjust for server format
      menuData.removeWhere((key, value) => value == null);

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

  /// Delete a menu item
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
  // SIDES OPERATIONS
  // ===============================

  /// Fetch sides for a specific menu
  Future<List<MenuSide>> fetchSidesByMenu({required int menuId}) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final response = await _apiClient.fetchSidesByMenu(
        subEntityId: subentityId,
        menuId: menuId,
        apiToken: apiToken,
      );

      if (response.status == 'success' && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((e) => MenuSide.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      log('MenuRepository.fetchSidesByMenu error: $e');
      throw 'Failed to fetch sides: $e';
    }
  }

  /// Create a new side
  Future<MenuSide> createSide({
    required String title,
    required String name,
    required double price,
    required bool isDefault,
    bool? isRequired,
  }) async {
    final side = MenuSide(
      title: title,
      name: name,
      price: price,
      isDefault: isDefault,
    );
    return await createSideFromModel(side: side);
  }

  /// Create a new side from model
  Future<MenuSide> createSideFromModel({required MenuSide side}) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final sideData = side.toJson();
      // Remove null values
      sideData.removeWhere((key, value) => value == null);

      final response = await _apiClient.createSide(
        subEntityId: subentityId,
        data: sideData,
        apiToken: apiToken,
      );

      if (response.status == 'success' && response.data != null) {
        return MenuSide.fromJson(response.data as Map<String, dynamic>);
      }

      throw 'Failed to create side: ${response.message}';
    } catch (e) {
      log('MenuRepository.createSide error: $e');
      throw 'Failed to create side: $e';
    }
  }

  /// Update an existing side
  Future<MenuSide> updateSide({
    required int sideId,
    required String title,
    required String name,
    required double price,
    required bool isDefault,
    bool? isRequired,
    String? description,
  }) async {
    final side = MenuSide(
      id: sideId,
      title: title,
      name: name,
      price: price,
      isDefault: isDefault,
    );
    return await updateSideFromModel(sideId: sideId, side: side);
  }

  /// Update an existing side from model
  Future<MenuSide> updateSideFromModel({
    required int sideId,
    required MenuSide side,
  }) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final sideData = side.toJson();
      // Remove null values
      sideData.removeWhere((key, value) => value == null);

      final response = await _apiClient.updateSide(
        subEntityId: subentityId,
        sideId: sideId,
        data: sideData,
        apiToken: apiToken,
      );

      if (response.status == 'success' && response.data != null) {
        return MenuSide.fromJson(response.data as Map<String, dynamic>);
      }

      throw 'Failed to update side: ${response.message}';
    } catch (e) {
      log('MenuRepository.updateSide error: $e');
      throw 'Failed to update side: $e';
    }
  }

  /// Delete a side
  Future<void> deleteSide({required int sideId}) async {
    try {
      final subentityId = await _getSubentityId();
      final apiToken = await _getFainzyApiToken();

      if (subentityId == null || apiToken == null) {
        throw 'Store not authenticated or subentity ID not found';
      }

      final response = await _apiClient.deleteSide(
        subEntityId: subentityId,
        sideId: sideId,
        apiToken: apiToken,
      );

      if (response.status != 'success') {
        throw 'Failed to delete side: ${response.message}';
      }
    } catch (e) {
      log('MenuRepository.deleteSide error: $e');
      throw 'Failed to delete side: $e';
    }
  }

  // ===============================
  // IMAGE OPERATIONS
  // ===============================

  /// Upload an image for a menu item
  Future<FainzyImage> uploadMenuImage({
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
        return FainzyImage.fromJson(response.data as Map<String, dynamic>);
      }

      throw 'Failed to upload image: ${response.message}';
    } catch (e) {
      log('MenuRepository.uploadMenuImage error: $e');
      throw 'Failed to upload image: $e';
    }
  }

  /// Upload multiple images for a menu
  Future<List<FainzyImage>> uploadImages({
    required int menuId,
    required List<File> images,
  }) async {
    final uploadedImages = <FainzyImage>[];
    
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

  /// Delete an image with menu association
  Future<void> deleteImage({
    required int menuId,
    required int imageId,
  }) async {
    await deleteImageById(imageId: imageId);
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
      log('MenuRepository.deleteImage error: $e');
      throw 'Failed to delete image: $e';
    }
  }
}
