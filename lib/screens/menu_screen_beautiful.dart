import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../services/menu_api_service.dart';
import '../services/currency_service.dart';
import '../models/fainzy_menu.dart';
import '../models/fainzy_category.dart';
import '../colors/app_colors.dart';
import 'create_menu_page.dart';
import 'edit_menu_page.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  final MenuApiService _menuApiService = MenuApiService();
  List<FainzyMenu> _menus = [];
  List<FainzyCategory> _categories = [];
  FainzyCategory? _selectedCategory;
  bool _isLoading = false;
  String? _error;
  String _currentCurrency = 'JPY';
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadCurrentCurrency();
    _loadMenuData();
  }

  Future<void> _loadCurrentCurrency() async {
    final currency = await CurrencyService.getCurrentCurrency();
    setState(() {
      _currentCurrency = currency;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch categories first
      final categories = await _menuApiService.fetchCategories();
      
      // Fetch all menus
      final menus = await _menuApiService.fetchMenus();

      setState(() {
        _categories = categories;
        _menus = menus;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
        _isLoading = false;
        
        // Update tab controller length
        _tabController.dispose();
        _tabController = TabController(length: _categories.length, vsync: this);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } finally {
      // Log the loaded menu and category data
      dev.log('📋 MENU SCREEN: Loaded ${_menus.length} menus and ${_categories.length} categories');
      
      // Log detailed menu information
      for (int i = 0; i < _menus.length; i++) {
        final menu = _menus[i];
        dev.log('🍽️ Menu ${i + 1}: "${menu.name}"');
        dev.log('  - ID: ${menu.id}');
        dev.log('  - Price: ¥${menu.price}');
        dev.log('  - Discount: ${menu.discount != null ? '${menu.discount}%' : 'none'}');
        dev.log('  - Discount Price: ${menu.discountPrice != null ? '¥${menu.discountPrice}' : 'none'}');
        dev.log('  - Images: ${menu.images?.length ?? 0} image(s)');
        if (menu.images != null && menu.images!.isNotEmpty) {
          for (int j = 0; j < menu.images!.length; j++) {
            dev.log('    📷 Image ${j + 1}: ${menu.images![j].upload ?? 'no URL'}');
          }
        }
        dev.log('  - Status: ${menu.status}');
        dev.log('  - Category: ${menu.category}');
      }
    }
  }

  List<FainzyMenu> get _filteredMenus {
    if (_selectedCategory == null || _selectedCategory!.id == -1) {
      return _menus;
    }
    return _menus.where((menu) => menu.category == _selectedCategory!.id).toList();
  }

  // Helper function to format numbers according to currency rules
  String _formatPrice(double price) {
    return CurrencyService.formatPriceForDisplay(price, _currentCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with gradient
            _buildHeader(),
            
            // Category Tabs with elevated design
            if (_categories.isNotEmpty) _buildCategoryTabs(),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryMain,
            AppColors.primaryMain.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMain.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Main header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu, 
                    size: 28, 
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Menu Management',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_menus.length} items across ${_categories.length} categories',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
            
            // Quick stats row
            const SizedBox(height: 20),
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _loadMenuData,
            icon: const Icon(Icons.refresh, color: AppColors.primaryMain),
            tooltip: 'Refresh Menu',
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _showAddMenuDialog,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Item'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryMain,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final activeMenus = _menus.where((menu) => menu.status == '1' || menu.status == 'available').length;
    final avgPrice = _menus.isNotEmpty 
        ? _menus.map((m) => m.price ?? 0).reduce((a, b) => a + b) / _menus.length
        : 0.0;

    return Row(
      children: [
        _buildStatCard('Active Items', '$activeMenus', Icons.check_circle, AppColors.success),
        const SizedBox(width: 16),
        _buildStatCard('Total Items', '${_menus.length}', Icons.restaurant, Colors.white),
        const SizedBox(width: 16),
        _buildStatCard('Avg Price', '${CurrencyService.getCurrencySymbol(_currentCurrency)}${_formatPrice(avgPrice)}', null, AppColors.warning, currencyIcon: true),
        const SizedBox(width: 16),
        _buildStatCard('Categories', '${_categories.length}', Icons.category, AppColors.info),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData? icon, Color color, {bool currencyIcon = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            currencyIcon 
                ? CurrencyService.getCurrencyIcon(
                    currencyCode: _currentCurrency,
                    size: 20,
                    color: color,
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: 60,
      child: Stack(
        children: [
          // Background for tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                // Add padding to the right to prevent tabs from going under the add button
                padding: const EdgeInsets.only(right: 80),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryMain, AppColors.primaryMain.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: _categories.map((category) => Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(category.name),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(category.name ?? 'Unknown'),
                        ],
                      ),
                    ),
                  )).toList(),
                  onTap: (index) {
                    setState(() {
                      _selectedCategory = _categories[index];
                    });
                  },
                ),
              ),
            ),
          ),
          
          // Floating Add Category Button
          Positioned(
            right: 8,
            top: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryMain, AppColors.primaryMain.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMain.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _showAddCategoryDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'hot drink':
        return Icons.local_cafe;
      case 'cold drink':
        return Icons.local_drink;
      case 'snack':
        return Icons.fastfood;
      case 'dessert':
        return Icons.cake;
      case 'meat':
        return Icons.lunch_dining;
      case 'bakery':
        return Icons.bakery_dining;
      case 'pizza':
        return Icons.local_pizza;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryMain),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading your delicious menu...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline, 
                  size: 48, 
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadMenuData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMain,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredMenus.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryMain.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu, 
                  size: 48, 
                  color: AppColors.primaryMain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No menu items yet',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Start building your menu by adding your first delicious item',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showAddMenuDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMain,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: _categories.map((category) {
        final categoryMenus = category.id == -1 
            ? _menus 
            : _menus.where((menu) => menu.category == category.id).toList();
        
        return Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive column count based on screen width
              int crossAxisCount;
              double cardMinWidth = 280; // Minimum width for each card
              
              if (constraints.maxWidth < 600) {
                // Mobile: 1-2 columns
                crossAxisCount = (constraints.maxWidth / cardMinWidth).floor().clamp(1, 2);
              } else if (constraints.maxWidth < 1200) {
                // Tablet: 2-3 columns
                crossAxisCount = (constraints.maxWidth / cardMinWidth).floor().clamp(2, 3);
              } else {
                // Desktop: 3-5 columns
                crossAxisCount = (constraints.maxWidth / cardMinWidth).floor().clamp(3, 5);
              }
              
              return GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1, // Increased to make cards less tall
                ),
                itemCount: categoryMenus.length,
                itemBuilder: (context, index) {
                  return _MenuCard(
                    menu: categoryMenus[index],
                    onTap: () => _showMenuDetails(categoryMenus[index]),
                    onEdit: () => _showEditMenuDialog(categoryMenus[index]),
                    onDelete: () => _showDeleteConfirmation(categoryMenus[index]),
                  );
                },
              );
            },
          ),
        );
      }).toList(),
    );
  }

  void _showAddMenuDialog() {
    _showCreateMenuPage();
  }

  void _showEditMenuDialog(FainzyMenu menu) {
    _showEditMenuPage(menu);
  }

  void _showDeleteConfirmation(FainzyMenu menu) {
    _showDeleteMenuDialog(menu);
  }

  void _showCreateMenuPage() {
    // Navigate to create menu page - provider clearing will happen in the page's initState
    dev.log('🆕 MENU SCREEN: Navigating to create menu page');
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateMenuPage(
          onMenuCreated: _loadMenuData,
          categories: _categories,
        ),
      ),
    );
  }

  void _showEditMenuPage(FainzyMenu menu) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMenuPage(
          menu: menu,
          onMenuUpdated: _loadMenuData,
          categories: _categories,
        ),
      ),
    );
  }

  void _showDeleteMenuDialog(FainzyMenu menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error, size: 24),
            SizedBox(width: 12),
            Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${menu.name}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteMenu(menu);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMenu(FainzyMenu menu) async {
    if (menu.id == null) {
      _showErrorSnackBar('Cannot delete menu: Invalid menu ID');
      return;
    }

    try {
      // Show loading state
      _showLoadingSnackBar('Deleting "${menu.name}"...');
      
      await _menuApiService.deleteMenu(menu.id!);
      
      // Remove from local list
      setState(() {
        _menus.removeWhere((m) => m.id == menu.id);
      });
      
      // Show success message
      _showSuccessSnackBar('Successfully deleted "${menu.name}"');
      
      // Refresh menu data to ensure consistency
      _loadMenuData();
    } catch (e) {
      _showErrorSnackBar('Failed to delete "${menu.name}": ${e.toString()}');
    }
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primaryMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showMenuDetails(FainzyMenu menu) {
    showDialog(
      context: context,
      builder: (context) => _MenuDetailsDialog(
        menu: menu,
        onEdit: () => _showEditMenuPage(menu),
        onDelete: () => _showDeleteMenuDialog(menu),
        onMenuUpdated: _loadMenuData,
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.category, color: AppColors.primaryMain, size: 24),
            SizedBox(width: 12),
            Text('Add New Category'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a name for the new category:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Hot Drinks, Snacks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final categoryName = categoryController.text.trim();
              if (categoryName.isNotEmpty) {
                Navigator.of(context).pop();
                _createCategory(categoryName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMain,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCategory(String categoryName) async {
    try {
      // Show loading state
      _showLoadingSnackBar('Creating category "$categoryName"...');
      
      final newCategory = await _menuApiService.createCategory(categoryName);
      
      // Refresh all menu data to ensure we have the latest data from server
      await _loadMenuData();
      
      // Show success message
      _showSuccessSnackBar('Successfully created category "$categoryName"');
      
      // Find and select the newly created category
      final createdCategoryIndex = _categories.indexWhere((cat) => cat.id == newCategory.id);
      if (createdCategoryIndex != -1) {
        setState(() {
          _selectedCategory = _categories[createdCategoryIndex];
          _tabController.animateTo(createdCategoryIndex);
        });
      }
      
    } catch (e) {
      _showErrorSnackBar('Failed to create category "$categoryName": ${e.toString()}');
    }
  }
}

class _MenuCard extends StatefulWidget {
  final FainzyMenu menu;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuCard({
    required this.menu,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  // Helper function to format numbers according to currency rules  
  String _formatPrice(double price) {
    // Get current currency from context or default to JPY
    return CurrencyService.formatPriceForDisplay(price, 'JPY'); // Default to JPY for now
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered 
                        ? AppColors.primaryMain.withOpacity(0.15)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: Offset(0, _isHovered ? 8 : 4),
                  ),
                ],
                border: _isHovered
                    ? Border.all(color: AppColors.primaryMain.withOpacity(0.3), width: 2)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: widget.onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section with status indicator - made more compact
                      Expanded(
                        flex: 3, // Reduced from 2 to make image section smaller relative to content
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryMain.withOpacity(0.1),
                                    AppColors.primaryLight.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: (widget.menu.images != null && 
                                      widget.menu.images!.isNotEmpty && 
                                      widget.menu.images![0].upload != null &&
                                      widget.menu.images![0].upload!.isNotEmpty)
                                  ? Image.network(
                                      widget.menu.images![0].upload!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: AppColors.primaryMain.withOpacity(0.1),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              valueColor: const AlwaysStoppedAnimation(AppColors.primaryMain),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildPlaceholderImage();
                                      },
                                    )
                                  : _buildPlaceholderImage(),
                            ),
                            
                            // Status badge
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(),
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getStatusText(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Hover overlay
                            if (_isHovered)
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.black.withOpacity(0.3),
                                child: const Center(
                                  child: Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Content section
                      Expanded(
                        flex: 2, // Added flex to balance with image section
                        child: Padding(
                          padding: const EdgeInsets.all(12), // Reduced from 16 to 12
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.menu.name ?? 'Unnamed Item',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15, // Slightly reduced from 16
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1, // Reduced from 2 to 1 to save space
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2), // Reduced from 4
                              if (widget.menu.description != null && widget.menu.description!.isNotEmpty)
                                Text(
                                  widget.menu.description!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11, // Reduced from 12
                                  ),
                                  maxLines: 1, // Reduced from 2 to save space
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const Spacer(), // Use spacer to push price/actions to bottom
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Price section with discount handling
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Show discount price if available
                                      if (widget.menu.discountPrice != null && widget.menu.discountPrice! > 0) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                          child: Text(
                                            '${CurrencyService.getCurrencySymbol('JPY')}${_formatPrice(widget.menu.discountPrice!)}',
                                            style: const TextStyle(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        // Original price with strikethrough
                                        Text(
                                          '${CurrencyService.getCurrencySymbol('JPY')}${_formatPrice(widget.menu.price ?? 0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.error,
                                            fontSize: 14,
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: AppColors.error,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                      ] else ...[
                                        // Regular price display
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                                          child: Text(
                                            '${CurrencyService.getCurrencySymbol('JPY')}${_formatPrice(widget.menu.price ?? 0)}',
                                            style: const TextStyle(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _ActionButton(
                                        icon: Icons.edit,
                                        color: AppColors.info,
                                        onPressed: widget.onEdit,
                                        tooltip: 'Edit',
                                      ),
                                      const SizedBox(width: 8),
                                      _ActionButton(
                                        icon: Icons.delete,
                                        color: AppColors.error,
                                        onPressed: widget.onDelete,
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      )
                    ],
                  ),
                ),
              ),
            )
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryMain.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.2),
          ],
        ),
      ),
      child: Icon(
        _getCategoryIcon(widget.menu.category),
        size: 48,
        color: AppColors.primaryMain.withOpacity(0.6),
      ),
    );
  }

  Color _getStatusColor() {
    if (widget.menu.isAvailable) return AppColors.success;
    if (widget.menu.isUnavailable) return AppColors.error;
    if (widget.menu.isSoldOut) return Colors.orange;
    return Colors.grey;
  }

  IconData _getStatusIcon() {
    if (widget.menu.isAvailable) return Icons.check_circle;
    if (widget.menu.isUnavailable) return Icons.pause_circle;
    if (widget.menu.isSoldOut) return Icons.remove_circle;
    return Icons.help_outline;
  }

  String _getStatusText() {
    if (widget.menu.isAvailable) return 'Available';
    if (widget.menu.isUnavailable) return 'Unavailable';
    if (widget.menu.isSoldOut) return 'Sold Out';
    return 'Unknown';
  }

  IconData _getCategoryIcon(int? categoryId) {
    // Map category IDs to icons based on the response data
    switch (categoryId) {
      case 1: // Hot drink
        return Icons.local_cafe;
      case 2: // Snack
        return Icons.fastfood;
      case 3: // Dessert
        return Icons.cake;
      case 4: // Meat
        return Icons.lunch_dining;
      case 5: // Cold drink
        return Icons.local_drink;
      case 6: // Bakery
        return Icons.bakery_dining;
      case 7: // Pizza
        return Icons.local_pizza;
      default:
        return Icons.restaurant;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _MenuDetailsDialog extends StatefulWidget {
  final FainzyMenu menu;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMenuUpdated;

  const _MenuDetailsDialog({
    required this.menu,
    this.onEdit,
    this.onDelete,
    this.onMenuUpdated,
  });

  @override
  State<_MenuDetailsDialog> createState() => _MenuDetailsDialogState();
}

class _MenuDetailsDialogState extends State<_MenuDetailsDialog> {
  final MenuApiService _menuApiService = MenuApiService();
  late String _currentStatus;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.menu.status ?? 'available';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: screenWidth > 700 ? 650 : screenWidth * 0.9,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
          minHeight: 400,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with image - Responsive height
            Container(
              height: screenHeight > 800 ? 180 : 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryMain.withOpacity(0.9),
                    AppColors.primaryLight.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  if (widget.menu.images != null && 
                      widget.menu.images!.isNotEmpty && 
                      widget.menu.images![0].upload != null &&
                      widget.menu.images![0].upload!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(
                        widget.menu.images![0].upload!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.primaryMain.withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                strokeWidth: 3,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      ),
                    )
                  else
                    _buildPlaceholderImage(),
                  
                  // Gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                  ),
                  
                  // Close button with improved styling
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status badge in header
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor().withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and price section with improved layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.menu.name ?? 'Unnamed Item',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.success.withOpacity(0.1),
                                      AppColors.success.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: AppColors.success.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CurrencyService.getCurrencyIcon(
                                      size: 18,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    FutureBuilder<String>(
                                      future: CurrencyService.getCurrentCurrency(),
                                      builder: (context, snapshot) {
                                        final currency = snapshot.data ?? 'JPY';
                                        return Text(
                                          '${CurrencyService.getCurrencySymbol(currency)}${(widget.menu.price ?? 0).floor()}',
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (widget.menu.description != null && widget.menu.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMain.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryMain.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: AppColors.primaryMain,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.menu.description!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons with improved design
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onEdit?.call();
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Edit Menu'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.info,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onDelete?.call();
                                  },
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Details section with improved styling
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primaryMain,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Menu Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Item ID', '${widget.menu.id ?? 'N/A'}'),
                          _buildDetailRow('Category ID', '${widget.menu.category ?? 'N/A'}'),
                          if (widget.menu.created != null)
                            _buildDetailRow('Created', _formatDate(widget.menu.created!)),
                          if (widget.menu.modified != null)
                            _buildDetailRow('Modified', _formatDate(widget.menu.modified!)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Status update section with improved design
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryMain.withOpacity(0.03),
                            AppColors.primaryMain.withOpacity(0.01),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryMain.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.sync_alt,
                                color: AppColors.primaryMain,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Update Status',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _currentStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    prefixIcon: Icon(
                                      _getStatusIconForDropdown(_currentStatus),
                                      color: _getStatusColor(),
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryMain,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'available',
                                      child: Text('Available'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'unavailable',
                                      child: Text('Unavailable'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'sold_out',
                                      child: Text('Sold Out'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _currentStatus = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: _isUpdatingStatus ? null : _updateStatus,
                                icon: _isUpdatingStatus
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.update, size: 18),
                                label: Text(_isUpdatingStatus ? 'Updating...' : 'Update'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryMain,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryMain.withOpacity(0.3),
            AppColors.primaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Icon(
        Icons.restaurant,
        size: 64,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case 'available':
        return Icons.check_circle;
      case 'unavailable':
        return Icons.pause_circle;
      case 'sold_out':
        return Icons.remove_circle;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getStatusIconForDropdown(String status) {
    switch (status) {
      case 'available':
        return Icons.check_circle;
      case 'unavailable':
        return Icons.pause_circle;
      case 'sold_out':
        return Icons.remove_circle;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case 'available':
        return AppColors.success;
      case 'unavailable':
        return AppColors.error;
      case 'sold_out':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case 'available':
        return 'Available';
      case 'unavailable':
        return 'Unavailable';
      case 'sold_out':
        return 'Sold Out';
      default:
        return 'Unknown';
    }
  }

  Future<void> _updateStatus() async {
    if (widget.menu.id == null) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _menuApiService.updateMenuStatus(widget.menu.id!, _currentStatus);
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Status updated successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        // Close dialog and refresh menu list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to update status: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }
}
