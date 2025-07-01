import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:store_management_app/models/fainzy_menu.dart';
import 'package:store_management_app/repositories/menu_repository.dart';
import 'package:store_management_app/services/menu_api_service.dart';

enum MenuStatus { idle, loading, submitting, success, error }
enum ImageStatus { idle, picking, uploading, deleting, error }

class MenuProvider with ChangeNotifier {
  MenuProvider() : _menuRepository = MenuRepository();

  final MenuRepository _menuRepository;

  // ===============================
  // STATE VARIABLES
  // ===============================

  // Menu operations state
  MenuStatus _status = MenuStatus.idle;
  String? _error;
  final List<FainzyMenu> _menus = [];
  FainzyMenu? _currentMenu;

  // Image operations state
  ImageStatus _imageStatus = ImageStatus.idle;
  String? _imageError;
  final List<File> _formPickedImages = [];
  final List<Map<String, dynamic>> _uploadedImageData = []; // Store uploaded image data
  final Map<int, List<Map<String, dynamic>>> _menuImages = {};

  // Form state for create/edit
  String _name = '';
  String _description = '';
  double _price = 0.0;
  double? _discountPrice;
  int? _categoryId;

  // Sides management state
  final List<Side> _currentMenuSides = [];
  final Map<int, List<Side>> _menuSides = {}; // Cache sides for each menu

  // ===============================
  // GETTERS
  // ===============================

  MenuStatus get status => _status;
  String? get error => _error;
  List<FainzyMenu> get menus => _menus;
  FainzyMenu? get currentMenu => _currentMenu;

  ImageStatus get imageStatus => _imageStatus;
  String? get imageError => _imageError;
  List<File> get formPickedImages => _formPickedImages;
  List<Map<String, dynamic>> get uploadedImageData => _uploadedImageData;
  Map<int, List<Map<String, dynamic>>> get menuImages => _menuImages;

  // Form getters
  String get name => _name;
  String get description => _description;
  double get price => _price;
  double? get discountPrice => _discountPrice;
  int? get categoryId => _categoryId;

  // Sides getters
  List<Side> get currentMenuSides => _currentMenuSides;
  Map<int, List<Side>> get menuSides => _menuSides;

  // Validation getters
  bool get isFormValid => 
      _name.isNotEmpty && 
      _description.isNotEmpty && 
      _price > 0 && 
      _categoryId != null;

  // ===============================
  // FETCH OPERATIONS
  // ===============================

  /// Fetch all menus from server
  Future<bool> fetchAllMenus() async {
    try {
      _setStatus(MenuStatus.loading);
      
      // Use MenuApiService directly since MenuRepository doesn't have a fetch method
      final MenuApiService menuApiService = MenuApiService();
      final menus = await menuApiService.fetchMenus();
      
      _menus.clear();
      _menus.addAll(menus);
      
      _setStatus(MenuStatus.success);
      
      log('MenuProvider: Fetched ${menus.length} menus');
      return true;
    } catch (e) {
      _setError('Failed to fetch menus: $e');
      return false;
    }
  }

  /// Refresh menu data (alias for fetchAllMenus)
  Future<bool> refreshMenus() async {
    return await fetchAllMenus();
  }

  // ===============================
  // MENU CRUD OPERATIONS
  // ===============================

  /// Create a new menu
  Future<bool> createMenu() async {
    if (!isFormValid) {
      _setError('Please fill all required fields');
      return false;
    }

    try {
      _setStatus(MenuStatus.submitting);
      
      final menu = await _menuRepository.createMenu(
        name: _name,
        description: _description,
        price: _price,
        discountPrice: _discountPrice,
        categoryId: _categoryId!,
      );

      _currentMenu = menu;
      
      // Refresh all menus to ensure we have the latest data
      await fetchAllMenus();
      
      // Save sides for this menu if any
      if (_currentMenuSides.isNotEmpty) {
        _menuSides[menu.id!] = List.from(_currentMenuSides);
      }
      
      log('MenuProvider: Created menu with ID ${menu.id}');
      return true;
    } catch (e) {
      _setError('Failed to create menu: $e');
      return false;
    }
  }

  /// Update an existing menu
  Future<bool> updateMenu(int menuId) async {
    if (!isFormValid) {
      _setError('Please fill all required fields');
      return false;
    }

    try {
      _setStatus(MenuStatus.submitting);
      
      final menu = await _menuRepository.updateMenu(
        menuId: menuId,
        name: _name,
        description: _description,
        price: _price,
        discountPrice: _discountPrice,
        categoryId: _categoryId!,
      );

      // Update menu in list
      final index = _menus.indexWhere((m) => m.id == menuId);
      if (index >= 0) {
        _menus[index] = menu;
      }
      
      _currentMenu = menu;
      
      // Refresh all menus to ensure we have the latest data
      await fetchAllMenus();
      
      // Update sides for this menu
      if (_currentMenuSides.isNotEmpty) {
        _menuSides[menuId] = List.from(_currentMenuSides);
      } else {
        _menuSides.remove(menuId);
      }
      
      log('MenuProvider: Updated menu with ID $menuId');
      return true;
    } catch (e) {
      _setError('Failed to update menu: $e');
      return false;
    }
  }

  /// Delete a menu
  Future<bool> deleteMenu(int menuId) async {
    try {
      _setStatus(MenuStatus.submitting);
      
      await _menuRepository.deleteMenu(menuId: menuId);
      
      // Refresh all menus to ensure we have the latest data
      await fetchAllMenus();
      
      // Clear current menu if it was deleted
      if (_currentMenu?.id == menuId) {
        _currentMenu = null;
      }
      
      // Remove associated images and sides
      _menuImages.remove(menuId);
      _menuSides.remove(menuId);
      
      log('MenuProvider: Deleted menu with ID $menuId');
      return true;
    } catch (e) {
      _setError('Failed to delete menu: $e');
      return false;
    }
  }

  // ===============================
  // SIDES MANAGEMENT
  // ===============================

  /// Add a side to the current menu
  void addSide(Side side) {
    _currentMenuSides.add(side);
    notifyListeners();
    log('✅ MenuProvider: Added side "${side.name}" - \$${side.price} (Default: ${side.isDefault}) [ID: ${side.id}]');
    log('📋 Current menu now has ${_currentMenuSides.length} sides total');
  }

  /// Remove a side from the current menu
  void removeSide(Side side) {
    _currentMenuSides.removeWhere((s) => s.id == side.id);
    notifyListeners();
    log('❌ MenuProvider: Removed side "${side.name}" from current menu');
    log('📋 Current menu now has ${_currentMenuSides.length} sides total');
  }

  /// Update a side in the current menu
  void updateSide(Side updatedSide) {
    final index = _currentMenuSides.indexWhere((s) => s.id == updatedSide.id);
    if (index >= 0) {
      _currentMenuSides[index] = updatedSide;
      notifyListeners();
      log('🔄 MenuProvider: Updated side "${updatedSide.name}" - \$${updatedSide.price} (Default: ${updatedSide.isDefault}) [ID: ${updatedSide.id}]');
    } else {
      log('⚠️ MenuProvider: Could not find side with ID ${updatedSide.id} to update');
    }
    log('📋 Current menu has ${_currentMenuSides.length} sides total');
  }

  /// Clear all sides for current menu
  void clearCurrentMenuSides() {
    _currentMenuSides.clear();
    notifyListeners();
  }

  /// Load sides for a specific menu
  void loadMenuSides(int menuId) {
    _currentMenuSides.clear();
    if (_menuSides.containsKey(menuId)) {
      _currentMenuSides.addAll(_menuSides[menuId]!);
    }
    notifyListeners();
  }

  /// Get sides for a specific menu
  List<Side> getSidesForMenu(int menuId) {
    return _menuSides[menuId] ?? [];
  }

  /// Create a new side
  Side createSide({
    required String name,
    required double price,
    bool isDefault = false,
  }) {
    return Side(
      id: -DateTime.now().millisecondsSinceEpoch, // Use negative ID for new sides
      name: name,
      price: price,
      isDefault: isDefault,
      created: DateTime.now(),
      modified: DateTime.now(),
    );
  }

  // ===============================
  // FORM OPERATIONS
  // ===============================

  /// Initialize form with menu data for editing
  void initializeForm({FainzyMenu? menu}) {
    log('🔄 MenuProvider.initializeForm called with menu: ${menu?.id} "${menu?.name}"');
    
    if (menu != null) {
      _name = menu.name ?? '';
      _description = menu.description ?? '';
      _price = menu.price ?? 0.0;
      _discountPrice = menu.discountPrice;
      _categoryId = menu.category;
      _currentMenu = menu;
      
      // Load sides for this menu - initialize from the menu object itself
      _currentMenuSides.clear();
      if (menu.sides.isNotEmpty) {
        _currentMenuSides.addAll(menu.sides);
        log('MenuProvider: Initialized ${menu.sides.length} sides for menu ${menu.id}');
        
        // Debug: Log each side being initialized
        for (int i = 0; i < menu.sides.length; i++) {
          final side = menu.sides[i];
          log('  📦 Init Side ${i + 1}: "${side.name}" - \$${side.price} (Default: ${side.isDefault}) [ID: ${side.id}]');
        }
      } else {
        log('MenuProvider: No sides found in menu ${menu.id}');
      }
      
      // Also cache the sides if we have a menu ID
      if (menu.id != null) {
        _menuSides[menu.id!] = List.from(menu.sides);
        log('MenuProvider: Cached ${menu.sides.length} sides for menu ${menu.id}');
      }
    } else {
      log('MenuProvider: initializeForm called with null menu - clearing form');
      clearForm();
    }
    notifyListeners();
  }

  /// Clear form data
  void clearForm() {
    log('🧹 MenuProvider: clearForm called - clearing all form data and sides');
    _name = '';
    _description = '';
    _price = 0.0;
    _discountPrice = null;
    _categoryId = null;
    _formPickedImages.clear();
    _uploadedImageData.clear();
    _imageError = null;
    _imageStatus = ImageStatus.idle;
    _currentMenuSides.clear();
    log('✅ MenuProvider: Form cleared - ${_currentMenuSides.length} sides remaining');
    notifyListeners();
  }

  /// Clear form fields only (preserve sides for create menu scenario)
  void clearFormFieldsOnly() {
    log('🧹 MenuProvider: clearFormFieldsOnly called - clearing form fields but preserving sides');
    _name = '';
    _description = '';
    _price = 0.0;
    _discountPrice = null;
    _categoryId = null;
    _formPickedImages.clear();
    _uploadedImageData.clear();
    _imageError = null;
    _imageStatus = ImageStatus.idle;
    // NOTE: NOT clearing _currentMenuSides - preserve user-added sides
    log('✅ MenuProvider: Form fields cleared - ${_currentMenuSides.length} sides preserved');
    notifyListeners();
  }

  /// Update form fields
  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updatePrice(double value) {
    _price = value;
    notifyListeners();
  }

  void updateDiscountPrice(double? value) {
    _discountPrice = value;
    notifyListeners();
  }

  void updateCategoryId(int? value) {
    _categoryId = value;
    notifyListeners();
  }

  // ===============================
  // IMAGE OPERATIONS
  // ===============================

  /// Pick and upload an image immediately (like last_mile_store)
  Future<bool> pickAndUploadImage() async {
    try {
      _imageStatus = ImageStatus.picking;
      _imageError = null;
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        _imageStatus = ImageStatus.idle;
        notifyListeners();
        return false;
      }

      final File imageFile = File(image.path);
      
      _imageStatus = ImageStatus.uploading;
      notifyListeners();

      // Upload the image immediately like last_mile_store
      final uploadedImage = await _menuRepository.uploadMenuImage(
        menuId: 0, // Use 0 as temporary ID for standalone upload
        imageFile: imageFile,
      );

      // Add to form images collection
      _formPickedImages.add(imageFile);
      
      // Store the uploaded image data for later use when creating menu
      _uploadedImageData.add(uploadedImage);
      
      _imageStatus = ImageStatus.idle;
      
      log('MenuProvider: Successfully picked and uploaded image with ID: ${uploadedImage['id']}');
      return true;
    } catch (e) {
      _imageStatus = ImageStatus.idle;
      _imageError = e.toString();
      log('MenuProvider: Error picking/uploading image - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Remove an uploaded image
  Future<bool> removeUploadedImage(int index) async {
    try {
      if (index >= 0 && index < _formPickedImages.length) {
        // Remove from uploaded data if available
        if (index < _uploadedImageData.length) {
          final imageData = _uploadedImageData[index];
          if (imageData['id'] != null) {
            try {
              await _menuRepository.deleteImageById(imageId: imageData['id']);
              log('MenuProvider: Deleted uploaded image with ID: ${imageData['id']}');
            } catch (e) {
              log('MenuProvider: Warning - could not delete uploaded image: $e');
            }
          }
          _uploadedImageData.removeAt(index);
        }
        
        // Remove from local images
        _formPickedImages.removeAt(index);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _imageError = e.toString();
      log('MenuProvider: Error removing image - $e');
      notifyListeners();
      return false;
    }
  }

  /// Get uploaded image IDs for menu creation (like last_mile_store)
  List<Map<String, dynamic>> getUploadedImagesForMenu() {
    return _uploadedImageData.map((imageData) => {
      'id': imageData['id'],
    }).toList();
  }

  /// Upload images for a menu
  Future<bool> uploadImages({
    required int menuId,
    required List<File> images,
  }) async {
    try {
      _imageStatus = ImageStatus.uploading;
      _imageError = null;
      notifyListeners();

      final uploadedImages = await _menuRepository.uploadImages(
        menuId: menuId,
        images: images,
      );

      _menuImages[menuId] = uploadedImages;
      _imageStatus = ImageStatus.idle;
      
      log('MenuProvider: Uploaded ${uploadedImages.length} images for menu $menuId');
      return true;
    } catch (e) {
      _imageStatus = ImageStatus.idle;
      _imageError = e.toString();
      log('MenuProvider: Error uploading images - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Delete an image
  Future<bool> deleteImage({
    required int menuId,
    required int imageId,
  }) async {
    try {
      _imageStatus = ImageStatus.deleting;
      _imageError = null;
      notifyListeners();

      await _menuRepository.deleteImageById(imageId: imageId);

      _menuImages[menuId]?.removeWhere((image) => image['id'] == imageId);
      _imageStatus = ImageStatus.idle;
      
      log('MenuProvider: Deleted image $imageId from menu $menuId');
      return true;
    } catch (e) {
      _imageStatus = ImageStatus.idle;
      _imageError = e.toString();
      log('MenuProvider: Error deleting image - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Remove a picked image before upload
  void removePickedImage(int index) {
    if (index >= 0 && index < _formPickedImages.length) {
      _formPickedImages.removeAt(index);
      notifyListeners();
    }
  }

  // ===============================
  // CATEGORY OPERATIONS
  // ===============================

  /// Get all categories
  Future<List<dynamic>> getCategories() async {
    try {
      return await _menuRepository.getCategories();
    } catch (e) {
      log('MenuProvider: Error getting categories - $e');
      throw 'Failed to get categories: $e';
    }
  }

  /// Create a new category
  Future<dynamic> createCategory({required String name}) async {
    try {
      final result = await _menuRepository.createCategory(name: name);
      
      // Refresh menu data to ensure any screens using this provider get updated data
      await fetchAllMenus();
      
      log('MenuProvider: Created category "$name" and refreshed menu data');
      return result;
    } catch (e) {
      log('MenuProvider: Error creating category - $e');
      throw 'Failed to create category: $e';
    }
  }

  // ===============================
  // HELPER METHODS
  // ===============================

  void _setStatus(MenuStatus status) {
    _status = status;
    if (status != MenuStatus.error) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _status = MenuStatus.error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
