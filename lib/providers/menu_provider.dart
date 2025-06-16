import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/fainzy_menu.dart';
import '../models/menu_category.dart';
import '../models/menu_side.dart';
import '../models/fainzy_image.dart';
import '../repositories/menu_repository.dart';

/// Enum representing different menu status states
enum MenuStatus { 
  initial, 
  loading, 
  success, 
  error 
}

/// Enum representing different categories status states
enum CategoriesStatus { 
  initial,
  loading, 
  success, 
  error 
}

/// Enum representing different sides status states
enum SidesStatus { 
  initial,
  loading, 
  success, 
  error 
}

/// Enum representing different image operations status
enum ImageStatus { 
  idle, 
  picking, 
  uploading, 
  deleting 
}

/// Comprehensive MenuProvider following last_mile_store patterns
class MenuProvider with ChangeNotifier {
  final MenuRepository _menuRepository;

  MenuProvider({required MenuRepository menuRepository}) 
      : _menuRepository = menuRepository;

  // ===============================
  // STATE MANAGEMENT
  // ===============================

  // Menu state
  MenuStatus _menuStatus = MenuStatus.initial;
  List<FainzyMenu> _menus = [];
  String? _menuError;

  // Categories state
  CategoriesStatus _categoriesStatus = CategoriesStatus.initial;
  List<MenuCategory> _categories = [];
  MenuCategory? _selectedCategory;
  String? _categoriesError;

  // Sides state
  SidesStatus _sidesStatus = SidesStatus.initial;
  Map<int, List<MenuSide>> _menuSides = {}; // menuId -> List<MenuSide>
  String? _sidesError;

  // Image state
  ImageStatus _imageStatus = ImageStatus.idle;
  Map<int, List<FainzyImage>> _menuImages = {}; // menuId -> List<FainzyImage>
  String? _imageError;

  // Form state for create/edit menu
  String? _formMenuName;
  String? _formMenuDescription;
  String? _formMenuIngredients;
  double? _formMenuPrice;
  double? _formMenuDiscount;
  MenuCategory? _formMenuCategory;
  List<File> _formPickedImages = [];
  List<MenuSide> _formSelectedSides = [];
  Map<String, String> _formErrors = {};

  // ===============================
  // GETTERS
  // ===============================

  // Menu getters
  MenuStatus get menuStatus => _menuStatus;
  List<FainzyMenu> get menus => _menus;
  String? get menuError => _menuError;
  bool get isMenuLoading => _menuStatus == MenuStatus.loading;

  // Categories getters
  CategoriesStatus get categoriesStatus => _categoriesStatus;
  List<MenuCategory> get categories => _categories;
  MenuCategory? get selectedCategory => _selectedCategory;
  String? get categoriesError => _categoriesError;
  bool get isCategoriesLoading => _categoriesStatus == CategoriesStatus.loading;

  // Sides getters
  SidesStatus get sidesStatus => _sidesStatus;
  Map<int, List<MenuSide>> get menuSides => _menuSides;
  String? get sidesError => _sidesError;
  bool get isSidesLoading => _sidesStatus == SidesStatus.loading;

  // Image getters
  ImageStatus get imageStatus => _imageStatus;
  Map<int, List<FainzyImage>> get menuImages => _menuImages;
  String? get imageError => _imageError;
  bool get isImageLoading => _imageStatus != ImageStatus.idle;

  // Form getters
  String? get formMenuName => _formMenuName;
  String? get formMenuDescription => _formMenuDescription;
  String? get formMenuIngredients => _formMenuIngredients;
  double? get formMenuPrice => _formMenuPrice;
  double? get formMenuDiscount => _formMenuDiscount;
  MenuCategory? get formMenuCategory => _formMenuCategory;
  List<File> get formPickedImages => _formPickedImages;
  List<MenuSide> get formSelectedSides => _formSelectedSides;
  Map<String, String> get formErrors => _formErrors;

  // Form validation
  bool get isFormValid {
    return _formMenuName != null &&
           _formMenuName!.isNotEmpty &&
           _formMenuDescription != null &&
           _formMenuDescription!.isNotEmpty &&
           _formMenuPrice != null &&
           _formMenuPrice! > 0 &&
           _formMenuCategory != null &&
           _formPickedImages.isNotEmpty;
  }

  // Filtered menus based on selected category
  List<FainzyMenu> get filteredMenus {
    if (_selectedCategory == null || _selectedCategory!.id == -1) {
      return _menus;
    }
    return _menus.where((menu) => menu.category == _selectedCategory!.id).toList();
  }

  // Legacy getters for backward compatibility
  List<MenuItem> get menuItems => _menus
      .map((menu) => MenuItem(
            name: menu.name ?? '',
            price: menu.price ?? 0.0,
          ))
      .toList();

  // ===============================
  // MENU OPERATIONS
  // ===============================

  /// Fetch all menus for the store
  Future<void> fetchMenus({int? categoryId}) async {
    try {
      _menuStatus = MenuStatus.loading;
      _menuError = null;
      notifyListeners();

      final menus = await _menuRepository.fetchMenus(categoryId: categoryId);
      
      _menus = menus;
      _menuStatus = MenuStatus.success;
      
      log('MenuProvider: Fetched ${menus.length} menus');
    } catch (e) {
      _menuStatus = MenuStatus.error;
      _menuError = e.toString();
      log('MenuProvider: Error fetching menus - $e');
    } finally {
      notifyListeners();
    }
  }

  /// Create a new menu
  Future<bool> createMenu({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? ingredients,
    double? discount,
    List<File>? images,
    List<MenuSide>? sides,
  }) async {
    try {
      _menuStatus = MenuStatus.loading;
      _menuError = null;
      notifyListeners();

      // final newMenu = await _menuRepository.createMenu(
      //   name: name,
      //   description: description,
      //   price: price,
      //   categoryId: categoryId,
      //   ingredients: ingredients,
      //   discount: discount,
      //   images: images,
      //   sides: sides,
      // );
      
      // Temporary workaround - create menu directly
      final menu = FainzyMenu(
        name: name,
        description: description,
        price: price,
        category: categoryId,
        ingredients: ingredients,
        discount: discount,
        sides: sides?.map((side) => side.toJson()).toList(),
      );
      final newMenu = await _menuRepository.createMenuFromModel(menu: menu);

      _menus.add(newMenu);
      _menuStatus = MenuStatus.success;
      
      // Clear form
      clearForm();
      
      log('MenuProvider: Created menu ${newMenu.name}');
      return true;
    } catch (e) {
      _menuStatus = MenuStatus.error;
      _menuError = e.toString();
      log('MenuProvider: Error creating menu - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Update an existing menu
  Future<bool> updateMenu({
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
    try {
      _menuStatus = MenuStatus.loading;
      _menuError = null;
      notifyListeners();

      final updatedMenu = await _menuRepository.updateMenu(
        menuId: menuId,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        ingredients: ingredients,
        discount: discount,
        images: images,
        sides: sides,
      );

      final index = _menus.indexWhere((menu) => menu.id == menuId);
      if (index != -1) {
        _menus[index] = updatedMenu;
      }
      
      _menuStatus = MenuStatus.success;
      log('MenuProvider: Updated menu ${updatedMenu.name}');
      return true;
    } catch (e) {
      _menuStatus = MenuStatus.error;
      _menuError = e.toString();
      log('MenuProvider: Error updating menu - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Delete a menu
  Future<bool> deleteMenu(int menuId) async {
    try {
      _menuStatus = MenuStatus.loading;
      _menuError = null;
      notifyListeners();

      await _menuRepository.deleteMenu(menuId: menuId);
      
      _menus.removeWhere((menu) => menu.id == menuId);
      _menuSides.remove(menuId);
      _menuImages.remove(menuId);
      
      _menuStatus = MenuStatus.success;
      log('MenuProvider: Deleted menu $menuId');
      return true;
    } catch (e) {
      _menuStatus = MenuStatus.error;
      _menuError = e.toString();
      log('MenuProvider: Error deleting menu - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // ===============================
  // CATEGORY OPERATIONS
  // ===============================

  /// Fetch all categories
  Future<void> fetchCategories() async {
    try {
      _categoriesStatus = CategoriesStatus.loading;
      _categoriesError = null;
      notifyListeners();

      final categories = await _menuRepository.fetchCategories();
      
      // Add "All" category at the beginning
      _categories = [
        const MenuCategory(id: -1, name: 'All'),
        ...categories,
      ];
      
      // Set default selected category to "All"
      if (_selectedCategory == null) {
        _selectedCategory = _categories.first;
      }
      
      _categoriesStatus = CategoriesStatus.success;
      log('MenuProvider: Fetched ${categories.length} categories');
    } catch (e) {
      _categoriesStatus = CategoriesStatus.error;
      _categoriesError = e.toString();
      log('MenuProvider: Error fetching categories - $e');
    } finally {
      notifyListeners();
    }
  }

  /// Create a new category
  Future<bool> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      _categoriesStatus = CategoriesStatus.loading;
      _categoriesError = null;
      notifyListeners();

      final newCategory = await _menuRepository.createCategory(
        name: name,
      );

      _categories.add(newCategory);
      _categoriesStatus = CategoriesStatus.success;
      
      log('MenuProvider: Created category ${newCategory.name}');
      return true;
    } catch (e) {
      _categoriesStatus = CategoriesStatus.error;
      _categoriesError = e.toString();
      log('MenuProvider: Error creating category - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Select a category for filtering
  void selectCategory(MenuCategory? category) {
    _selectedCategory = category;
    notifyListeners();
    
    // Fetch menus for the selected category
    if (category != null) {
      fetchMenus(categoryId: category.id == -1 ? null : category.id);
    }
  }

  // ===============================
  // SIDES OPERATIONS
  // ===============================

  /// Fetch sides for a specific menu
  Future<void> fetchSidesByMenu(int menuId) async {
    try {
      _sidesStatus = SidesStatus.loading;
      _sidesError = null;
      notifyListeners();

      final sides = await _menuRepository.fetchSidesByMenu(menuId: menuId);
      _menuSides[menuId] = sides;
      
      _sidesStatus = SidesStatus.success;
      log('MenuProvider: Fetched ${sides.length} sides for menu $menuId');
    } catch (e) {
      _sidesStatus = SidesStatus.error;
      _sidesError = e.toString();
      log('MenuProvider: Error fetching sides for menu $menuId - $e');
    } finally {
      notifyListeners();
    }
  }

  /// Create a new side
  Future<bool> createSide({
    required String title,
    required String name,
    required double price,
    required bool isDefault,
    bool? isRequired,
    String? description,
  }) async {
    try {
      _sidesStatus = SidesStatus.loading;
      _sidesError = null;
      notifyListeners();

      final newSide = await _menuRepository.createSide(
        title: title,
        name: name,
        price: price,
        isDefault: isDefault,
        isRequired: isRequired,
      );

      _sidesStatus = SidesStatus.success;
      log('MenuProvider: Created side ${newSide.name}');
      return true;
    } catch (e) {
      _sidesStatus = SidesStatus.error;
      _sidesError = e.toString();
      log('MenuProvider: Error creating side - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Update an existing side
  Future<bool> updateSide({
    required int sideId,
    required String title,
    required String name,
    required double price,
    required bool isDefault,
    bool? isRequired,
    String? description,
  }) async {
    try {
      _sidesStatus = SidesStatus.loading;
      _sidesError = null;
      notifyListeners();

      final updatedSide = await _menuRepository.updateSide(
        sideId: sideId,
        title: title,
        name: name,
        price: price,
        isDefault: isDefault,
        isRequired: isRequired,
        description: description,
      );

      // Update the side in all menu sides maps
      for (final entry in _menuSides.entries) {
        final index = entry.value.indexWhere((side) => side.id == sideId);
        if (index != -1) {
          entry.value[index] = updatedSide;
        }
      }

      _sidesStatus = SidesStatus.success;
      log('MenuProvider: Updated side ${updatedSide.name}');
      return true;
    } catch (e) {
      _sidesStatus = SidesStatus.error;
      _sidesError = e.toString();
      log('MenuProvider: Error updating side - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Delete a side
  Future<bool> deleteSide(int sideId) async {
    try {
      _sidesStatus = SidesStatus.loading;
      _sidesError = null;
      notifyListeners();

      await _menuRepository.deleteSide(sideId: sideId);

      // Remove the side from all menu sides maps
      for (final entry in _menuSides.entries) {
        entry.value.removeWhere((side) => side.id == sideId);
      }
      
      _sidesStatus = SidesStatus.success;
      log('MenuProvider: Deleted side $sideId');
      return true;
    } catch (e) {
      _sidesStatus = SidesStatus.error;
      _sidesError = e.toString();
      log('MenuProvider: Error deleting side - $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // ===============================
  // IMAGE OPERATIONS
  // ===============================

  /// Pick images from gallery
  Future<void> pickImages({bool multiple = true}) async {
    try {
      _imageStatus = ImageStatus.picking;
      _imageError = null;
      notifyListeners();

      final ImagePicker picker = ImagePicker();
      
      if (multiple) {
        final List<XFile> images = await picker.pickMultiImage(
          imageQuality: 80,
        );
        
        for (final image in images) {
          _formPickedImages.add(File(image.path));
        }
      } else {
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        
        if (image != null) {
          _formPickedImages.add(File(image.path));
        }
      }

      _imageStatus = ImageStatus.idle;
      log('MenuProvider: Picked ${_formPickedImages.length} images');
    } catch (e) {
      _imageStatus = ImageStatus.idle;
      _imageError = e.toString();
      log('MenuProvider: Error picking images - $e');
    } finally {
      notifyListeners();
    }
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

      await _menuRepository.deleteImage(menuId: menuId, imageId: imageId);

      _menuImages[menuId]?.removeWhere((image) => image.id == imageId);
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
  // FORM OPERATIONS
  // ===============================

  /// Initialize form with menu data for editing
  void initializeForm({FainzyMenu? menu}) {
    if (menu != null) {
      _formMenuName = menu.name;
      _formMenuDescription = menu.description;
      _formMenuIngredients = menu.ingredients;
      _formMenuPrice = menu.price;
      _formMenuDiscount = menu.discount;
      _formMenuCategory = _categories.firstWhere(
        (cat) => cat.id == menu.category,
        orElse: () => _categories.first,
      );
      
      // Load existing sides for the menu
      if (menu.id != null) {
        fetchSidesByMenu(menu.id!);
      }
    } else {
      clearForm();
    }
    notifyListeners();
  }

  /// Update form field values
  void updateFormField(String field, dynamic value) {
    switch (field) {
      case 'name':
        _formMenuName = value as String?;
        break;
      case 'description':
        _formMenuDescription = value as String?;
        break;
      case 'ingredients':
        _formMenuIngredients = value as String?;
        break;
      case 'price':
        _formMenuPrice = value as double?;
        break;
      case 'discount':
        _formMenuDiscount = value as double?;
        break;
      case 'category':
        _formMenuCategory = value as MenuCategory?;
        break;
    }
    
    // Clear related field error
    _formErrors.remove(field);
    notifyListeners();
  }

  /// Add side to form selection
  void addSideToForm(MenuSide side) {
    if (!_formSelectedSides.any((s) => s.id == side.id)) {
      _formSelectedSides.add(side);
      notifyListeners();
    }
  }

  /// Remove side from form selection
  void removeSideFromForm(MenuSide side) {
    _formSelectedSides.removeWhere((s) => s.id == side.id);
    notifyListeners();
  }

  /// Validate form and set errors
  bool validateForm() {
    _formErrors.clear();

    if (_formMenuName == null || _formMenuName!.trim().isEmpty) {
      _formErrors['name'] = 'Menu name is required';
    }

    if (_formMenuDescription == null || _formMenuDescription!.trim().isEmpty) {
      _formErrors['description'] = 'Description is required';
    }

    if (_formMenuPrice == null || _formMenuPrice! <= 0) {
      _formErrors['price'] = 'Valid price is required';
    }

    if (_formMenuCategory == null) {
      _formErrors['category'] = 'Category is required';
    }

    if (_formPickedImages.isEmpty) {
      _formErrors['images'] = 'At least one image is required';
    }

    notifyListeners();
    return _formErrors.isEmpty;
  }

  /// Clear the form
  void clearForm() {
    _formMenuName = null;
    _formMenuDescription = null;
    _formMenuIngredients = null;
    _formMenuPrice = null;
    _formMenuDiscount = null;
    _formMenuCategory = null;
    _formPickedImages.clear();
    _formSelectedSides.clear();
    _formErrors.clear();
    notifyListeners();
  }

  // ===============================
  // DATA REFRESH & INITIALIZATION
  // ===============================

  /// Initialize the provider with all necessary data
  Future<void> initialize() async {
    await Future.wait([
      fetchCategories(),
      fetchMenus(),
    ]);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await initialize();
  }

  /// Clear all data
  void clearAll() {
    _menuStatus = MenuStatus.initial;
    _menus.clear();
    _menuError = null;

    _categoriesStatus = CategoriesStatus.initial;
    _categories.clear();
    _selectedCategory = null;
    _categoriesError = null;

    _sidesStatus = SidesStatus.initial;
    _menuSides.clear();
    _sidesError = null;

    _imageStatus = ImageStatus.idle;
    _menuImages.clear();
    _imageError = null;

    clearForm();
    notifyListeners();
  }

  // ===============================
  // LEGACY SUPPORT
  // ===============================

  /// Legacy method for backward compatibility
  void addMenuItem(MenuItem item) {
    // Convert MenuItem to FainzyMenu and create
    createMenu(
      name: item.name,
      description: 'Legacy menu item',
      price: item.price,
      categoryId: _categories.isNotEmpty ? _categories.first.id! : 1,
    );
  }

  /// Legacy method for backward compatibility
  void deleteMenuItem(String name) {
    final menu = _menus.firstWhere(
      (menu) => menu.name == name,
      orElse: () => const FainzyMenu(),
    );
    
    if (menu.id != null) {
      deleteMenu(menu.id!);
    }
  }
}

/// Legacy MenuItem class for backward compatibility
class MenuItem {
  final String name;
  final double price;

  MenuItem({required this.name, required this.price});
}
