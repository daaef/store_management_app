import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/fainzy_menu.dart';
import '../models/fainzy_category.dart';
import '../colors/app_colors.dart';
import '../services/menu_api_service.dart';
import '../services/currency_service.dart';
import '../providers/menu_provider.dart';
import '../widgets/sides_management_widget.dart';

class EditMenuPage extends StatefulWidget {
  final FainzyMenu menu;
  final VoidCallback onMenuUpdated;
  final List<FainzyCategory> categories;

  const EditMenuPage({
    super.key,
    required this.menu,
    required this.onMenuUpdated,
    required this.categories,
  });

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final MenuApiService _menuApiService = MenuApiService();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _ingredientsController;
  late TextEditingController _discountController;
  
  // Form state
  FainzyCategory? _selectedCategory;
  late String _status;
  late String _discountType;
  bool _isLoading = false;
  String _currentCurrency = 'JPY'; // Default currency
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing menu data
    _nameController = TextEditingController(text: widget.menu.name ?? '');
    _descriptionController = TextEditingController(text: widget.menu.description ?? '');
    _priceController = TextEditingController(text: widget.menu.price?.toString() ?? '');
    _ingredientsController = TextEditingController(text: widget.menu.ingredients ?? '');
    
    // Initialize discount fields
    _discountController = TextEditingController();
    _discountType = 'percentage';
    
    // Load current currency
    _loadCurrentCurrency();
    
    // Initialize menu provider with current menu for editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      menuProvider.initializeForm(menu: widget.menu);
    });
    
    // If there's existing discount data, calculate the discount value from discount price
    if (widget.menu.discountPrice != null && widget.menu.price != null && widget.menu.discountPrice! < widget.menu.price!) {
      final originalPrice = widget.menu.price!;
      final discountPrice = widget.menu.discountPrice!;
      final discountAmount = originalPrice - discountPrice;
      final discountPercentage = (discountAmount / originalPrice) * 100;
      
      // Default to percentage representation
      _discountController.text = discountPercentage.toStringAsFixed(1);
      _discountType = 'percentage';
    }
    
    // Set initial status
    _status = widget.menu.status ?? 'available';
    
    // Find matching category
    try {
      _selectedCategory = widget.categories.firstWhere(
        (cat) => cat.id == widget.menu.category,
      );
      dev.log('📋 EDIT MENU - Category found: ID=${_selectedCategory!.id}, Name="${_selectedCategory!.name}"');
    } catch (e) {
      // If no matching category found, use first available category
      if (widget.categories.isNotEmpty) {
        _selectedCategory = widget.categories.first;
        dev.log('⚠️ EDIT MENU - Original category ID ${widget.menu.category} not found, using first available: ID=${_selectedCategory!.id}, Name="${_selectedCategory!.name}"');
      } else {
        _selectedCategory = null;
        dev.log('❌ EDIT MENU - No categories available!');
      }
    }
    
    // Log initial menu data being edited
    dev.log('📝 EDIT MENU - Initializing with menu data:');
    dev.log('  - Menu ID: ${widget.menu.id}');
    dev.log('  - Name: "${widget.menu.name}"');
    dev.log('  - Original Category ID: ${widget.menu.category}');
    dev.log('  - Selected Category: ${_selectedCategory?.id} (${_selectedCategory?.name})');
    dev.log('  - Price: \$${widget.menu.price}');
    dev.log('  - Discount Price: ${widget.menu.discountPrice != null ? '\$${widget.menu.discountPrice}' : 'none'}');
    dev.log('  - Status: ${widget.menu.status}');
    dev.log('  - Existing Images: ${widget.menu.images?.length ?? 0}');
    dev.log('  - Existing Sides: ${widget.menu.sides.length}');
    dev.log('  - Available Categories: ${widget.categories.length}');
    for (final cat in widget.categories) {
      dev.log('    - Category: ID=${cat.id}, Name="${cat.name}"');
    }
    
    // Log existing sides details
    for (int i = 0; i < widget.menu.sides.length; i++) {
      final side = widget.menu.sides[i];
      dev.log('    🍽️ Original Side ${i + 1}: "${side.name}" - \$${side.price} (Default: ${side.isDefault})');
    }
  }

  Future<void> _loadCurrentCurrency() async {
    final currency = await CurrencyService.getCurrentCurrency();
    setState(() {
      _currentCurrency = currency;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ingredientsController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildForm(),
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
            AppColors.info,
            AppColors.info.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Menu Item',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Update "${widget.menu.name}" details',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            // Menu preview card
            const SizedBox(height: 20),
            _buildMenuPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.menu.images != null && 
                   widget.menu.images!.isNotEmpty && 
                   widget.menu.images![0].upload != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.menu.images![0].upload!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.restaurant, color: Colors.white, size: 30);
                      },
                    ),
                  )
                : const Icon(Icons.restaurant, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.menu.name ?? 'Unnamed Item',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${(widget.menu.price ?? 0).floor()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.menu.status ?? 'unavailable'),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusLabel(widget.menu.status ?? 'unavailable'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu Name
            _buildSectionTitle('Menu Item Details', Icons.restaurant),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Menu Item Name',
              hint: 'Enter the name of your dish',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a menu item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your delicious dish',
              icon: Icons.description,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Price
            _buildTextField(
              controller: _priceController,
              label: 'Price (${CurrencyService.getCurrencySymbol(_currentCurrency)})',
              hint: 'Enter price in ${CurrencyService.getCurrencyName(_currentCurrency)}',
              icon: null, // We'll use custom prefix widget
              prefixWidget: CurrencyService.getFormFieldCurrencyIcon(
                currencyCode: _currentCurrency,
                color: AppColors.primaryMain,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Ingredients
            _buildTextField(
              controller: _ingredientsController,
              label: 'Ingredients',
              hint: 'List the main ingredients',
              icon: Icons.list_alt,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            
            // Image Section
            _buildSectionTitle('Menu Images', Icons.photo_camera),
            const SizedBox(height: 20),
            _buildImageSection(),
            const SizedBox(height: 32),
            
            // Discount Section
            _buildSectionTitle('Discount Settings', Icons.local_offer),
            const SizedBox(height: 20),
            _buildDiscountSection(),
            const SizedBox(height: 32),
            
            // Category and Status
            _buildSectionTitle('Category & Status', Icons.category),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildCategoryDropdown(),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatusDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Sides Section
            _buildSectionTitle('Menu Sides & Options', Icons.add_circle_outline),
            const SizedBox(height: 20),
            _buildSidesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.info, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    Widget? prefixWidget,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixWidget ?? (icon != null ? Icon(icon, color: AppColors.info) : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.info, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<FainzyCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category, color: AppColors.info),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.info, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: widget.categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category.name ?? 'Unknown'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: InputDecoration(
            prefixIcon: Icon(
              _getStatusIcon(_status),
              color: _getStatusColor(_status),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.info, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: const [
            DropdownMenuItem(value: 'available', child: Text('Available')),
            DropdownMenuItem(value: 'unavailable', child: Text('Unavailable')),
            DropdownMenuItem(value: 'sold_out', child: Text('Sold Out')),
          ],
          onChanged: (value) {
            setState(() {
              _status = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDiscountTypeDropdown(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildDiscountValueField(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDiscountPreview(),
      ],
    );
  }

  Widget _buildDiscountTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discount Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _discountType,
          decoration: InputDecoration(
            prefixIcon: _discountType == 'percentage' 
                ? const Icon(Icons.percent, color: AppColors.info)
                : CurrencyService.getFormFieldCurrencyIcon(
                    currencyCode: _currentCurrency,
                    color: AppColors.info,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.info, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: [
            const DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
            DropdownMenuItem(
              value: 'value', 
              child: Text('Fixed Amount (${CurrencyService.getCurrencySymbol(_currentCurrency)})'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _discountType = value!;
              _discountController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDiscountValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discount Value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _discountController,
          decoration: InputDecoration(
            hintText: _discountType == 'percentage' ? 'e.g., 10' : 'e.g., 100',
            prefixIcon: _discountType == 'percentage' 
                ? const Icon(Icons.percent, color: AppColors.info)
                : CurrencyService.getFormFieldCurrencyIcon(
                    currencyCode: _currentCurrency,
                    color: AppColors.info,
                  ),
            suffixText: _discountType == 'percentage' ? '%' : CurrencyService.getCurrencySymbol(_currentCurrency),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.info, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (_) => setState(() {}), // Trigger rebuild for preview
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final discount = double.tryParse(value);
              if (discount == null || discount < 0) {
                return 'Please enter a valid discount';
              }
              if (_discountType == 'percentage' && discount > 100) {
                return 'Percentage cannot exceed 100%';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDiscountPreview() {
    final priceText = _priceController.text;
    final discountText = _discountController.text;
    
    if (priceText.isEmpty || discountText.isEmpty) {
      return const SizedBox.shrink();
    }

    final price = double.tryParse(priceText);
    final discount = double.tryParse(discountText);
    
    if (price == null || discount == null || discount == 0) {
      return const SizedBox.shrink();
    }

    final discountPrice = _calculateDiscountPrice(price, discount, _discountType);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.preview, color: AppColors.info),
              const SizedBox(width: 12),
              const Text(
                'New Price Preview:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyService.formatPriceWithSymbol(price, _currentCurrency),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    CurrencyService.formatPriceWithSymbol(discountPrice, _currentCurrency),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryMain.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryMain.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.primaryMain),
                const SizedBox(width: 6),
                Text(
                  'API will receive: ${CurrencyService.formatPriceWithSymbol(CurrencyService.formatPriceForApi(discountPrice, _currentCurrency), _currentCurrency)} as discount_price',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryMain,
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

  double _calculateDiscountPrice(double price, double discount, String discountType) {
    double calculatedPrice;
    if (discountType == 'percentage') {
      // discount_price = price - (price * percentage_set / 100)
      calculatedPrice = price - (price * discount / 100);
    } else {
      // discount_price = price - value_set
      calculatedPrice = price - discount;
    }
    
    // Ensure non-negative and format according to currency rules
    calculatedPrice = calculatedPrice < 0 ? 0 : calculatedPrice;
    return CurrencyService.formatPriceForApi(calculatedPrice, _currentCurrency);
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _updateMenu,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            label: Text(_isLoading ? 'Updating...' : 'Update Menu Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
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

  IconData _getStatusIcon(String status) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.success;
      case 'unavailable':
        return AppColors.error;
      case 'sold_out':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildImageSection() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final uploadedImages = menuProvider.uploadedImageData;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Existing images from the menu
            if (widget.menu.images != null && widget.menu.images!.isNotEmpty) ...[
              const Text(
                'Current Images',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: widget.menu.images!.length,
                  itemBuilder: (context, index) {
                    final image = widget.menu.images![index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image.upload ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // New uploaded images section
            if (uploadedImages.isNotEmpty) ...[
              const Text(
                'New Images Added',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                  color: Colors.green.shade50,
                ),
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: uploadedImages.length,
                  itemBuilder: (context, index) {
                    final imageData = uploadedImages[index];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageData['upload'] ?? '',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Remove button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => menuProvider.removeUploadedImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Add image button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade50,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: menuProvider.imageStatus == ImageStatus.uploading
                      ? null
                      : () => _pickAndUploadImage(menuProvider),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      color: AppColors.info.withOpacity(0.05),
                    ),
                    child: Center(
                      child: menuProvider.imageStatus == ImageStatus.uploading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 8),
                                Text(
                                  'Uploading image...',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: AppColors.info,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  uploadedImages.isNotEmpty || (widget.menu.images?.isNotEmpty ?? false)
                                      ? 'Add More Images'
                                      : 'Add Images',
                                  style: TextStyle(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to select image from gallery',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
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
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(MenuProvider menuProvider) async {
    try {
      dev.log('📷 EDIT MENU - Starting image pick and upload...');
      final success = await menuProvider.pickAndUploadImage();
      
      if (success) {
        dev.log('✅ EDIT MENU - Image uploaded successfully');
      } else {
        dev.log('❌ EDIT MENU - Image upload failed');
      }
    } catch (e) {
      dev.log('❌ EDIT MENU - Error picking/uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _updateMenu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      final rawPrice = double.tryParse(_priceController.text) ?? 0.0;
      
      // Format price according to currency rules
      final price = CurrencyService.formatPriceForApi(rawPrice, _currentCurrency);
      double? discountPrice;
      
      // Calculate discount_price based on user input
      if (_discountController.text.isNotEmpty) {
        final rawDiscountValue = double.parse(_discountController.text);
        final discountValue = CurrencyService.formatPriceForApi(rawDiscountValue, _currentCurrency);
        
        if (_discountType == 'percentage') {
          // If percentage is selected, discount_price is the percent value set of the price subtracted from the price
          // eg. price is 100. percent is 10. We subtract 10% of 100 from 100 so discount_price is 100 - 10 = 90
          final calculatedDiscountPrice = price - (price * discountValue / 100);
          discountPrice = CurrencyService.formatPriceForApi(calculatedDiscountPrice, _currentCurrency);
        } else {
          // If fixed value is selected, discount_price is the price - the discount value
          // eg. price is 100, fixed value is 12. discount_price is 100 - 12 = 88
          final calculatedDiscountPrice = price - discountValue;
          discountPrice = CurrencyService.formatPriceForApi(calculatedDiscountPrice, _currentCurrency);
        }
        
        // Ensure discount_price doesn't go below 0
        discountPrice = discountPrice < 0 ? 0 : discountPrice;
        
        dev.log('💰 Discount calculation: price=$price, input=$discountValue, type=$_discountType, calculated_discount_price=$discountPrice');
        dev.log('💱 Currency: $_currentCurrency, JPY mode: ${CurrencyService.isYenCurrency(_currentCurrency)}');
      }

      // Get uploaded image IDs from MenuProvider
      final uploadedImages = menuProvider.uploadedImageData;
      
      // Combine existing images with new uploaded images for the update
      final existingImages = widget.menu.images ?? [];
      final allImages = [...existingImages];
      
      // Add newly uploaded images to the list
      for (final imageData in uploadedImages) {
        allImages.add(ImageElement(
          id: imageData['id'],
          upload: imageData['upload'],
        ));
      }

      // Get the current sides from MenuProvider (includes any user modifications)
      final currentSides = menuProvider.currentMenuSides;
      
      // 🔍 DEBUG: Compare original vs current sides
      dev.log('🔍 EDIT MENU DEBUG - Sides comparison:');
      dev.log('  📦 Original menu sides (${widget.menu.sides.length}):');
      for (int i = 0; i < widget.menu.sides.length; i++) {
        final side = widget.menu.sides[i];
        dev.log('    ${i + 1}. "${side.name}" - \$${side.price} (Default: ${side.isDefault}) [ID: ${side.id}]');
      }
      dev.log('  🔄 Current sides from provider (${currentSides.length}):');
      for (int i = 0; i < currentSides.length; i++) {
        final side = currentSides[i];
        dev.log('    ${i + 1}. "${side.name}" - \$${side.price} (Default: ${side.isDefault}) [ID: ${side.id}]');
      }
      
      // Create updated menu object
      final updatedMenu = FainzyMenu(
        id: widget.menu.id,
        category: _selectedCategory?.id,
        subentity: widget.menu.subentity,
        subentityDetails: widget.menu.subentityDetails,
        // NOTE: sides are NOT included in menu payload - they will be managed separately
        name: _nameController.text.trim(),
        price: price,
        description: _descriptionController.text.trim(),
        ingredients: _ingredientsController.text.trim(),
        status: _status,
        discount: 0, // Always set discount to 0 by default
        discountPrice: discountPrice, // Send calculated discount_price to discountPrice field
        images: allImages, // Include existing and new images
        created: widget.menu.created,
        modified: DateTime.now(),
      );

      // 📝 LOG: Menu update data being sent
      dev.log('📝 EDIT MENU: Starting menu update process');
      dev.log('📋 Original menu ID: ${widget.menu.id}');
      dev.log('📋 Updated menu data:');
      dev.log('  - Name: "${updatedMenu.name}"');
      dev.log('  - Category ID: ${updatedMenu.category}');
      dev.log('  - Category Name: "${_selectedCategory?.name ?? 'Unknown'}"');
      dev.log('  - Price: \$${updatedMenu.price}');
      dev.log('  - Discount: ${updatedMenu.discount} (always 0 by default)');
      dev.log('  - Discount Price: ${updatedMenu.discountPrice != null ? '\$${updatedMenu.discountPrice!.toStringAsFixed(2)}' : 'none'}');
      dev.log('  - Discount Type: $_discountType');
      dev.log('  - Discount Value: ${_discountController.text.isEmpty ? 'none' : _discountController.text}');
      dev.log('  - Description: "${updatedMenu.description}"');
      dev.log('  - Ingredients: "${updatedMenu.ingredients}"');
      dev.log('  - Status: ${updatedMenu.status}');
      dev.log('  - Existing Images: ${existingImages.length} image(s)');
      dev.log('  - New Uploaded Images: ${uploadedImages.length} image(s)');
      dev.log('  - Total Images: ${allImages.length} image(s)');
      dev.log('  - Sides: ${currentSides.length} side(s)');
      
      // Log sides details
      for (int i = 0; i < currentSides.length; i++) {
        final side = currentSides[i];
        dev.log('    🍽️ Side ${i + 1}: "${side.name}" - \$${side.price} (Default: ${side.isDefault})');
      }
      
      // 📝 LOG: JSON payload being sent to API (without sides)
      final menuJson = updatedMenu.toJson();
      dev.log('📤 API Payload (JSON - without sides):');
      dev.log(jsonEncode(menuJson));
      
      // Validate payload structure
      if (menuJson.containsKey('discount') && menuJson['discount'] != null) {
        dev.log('✅ CORRECT: discount field contains default value: ${menuJson['discount']}');
      }
      if (menuJson.containsKey('discount_price') && menuJson['discount_price'] != null) {
        dev.log('✅ CORRECT: discount_price field contains calculated value: \$${menuJson['discount_price']}');
      }
      if (menuJson['images'] == null) {
        dev.log('⚠️ WARNING: images field is null (should be array)');
      } else {
        dev.log('✅ CORRECT: images field contains ${(menuJson['images'] as List).length} image(s)');
      }
      if (menuJson.containsKey('sides')) {
        dev.log('⚠️ WARNING: sides field found in menu payload (should not be included)');
      } else {
        dev.log('✅ CORRECT: sides field not included in menu payload (will be managed separately)');
      }
      if (menuJson['category'] == null || menuJson['category'] == -1) {
        dev.log('⚠️ WARNING: category is null or invalid (-1)');
      }

      // Call the update API (without sides)
      dev.log('🚀 Calling API: updateMenu (without sides)');
      await _menuApiService.updateMenu(updatedMenu);
      dev.log('✅ Menu update API call successful');
      
      // Now sync sides separately if the menu was updated successfully
      if (widget.menu.id != null) {
        dev.log('🍽️ Syncing ${currentSides.length} sides for menu ${widget.menu.id}');
        try {
          await _menuApiService.syncMenuSides(widget.menu.id!, currentSides, widget.menu.sides);
          dev.log('✅ Side synchronization completed successfully');
        } catch (e) {
          dev.log('❌ Failed to sync sides: $e');
          // Note: We don't rethrow here because the menu was updated successfully
          // The user can manually manage sides later if needed
        }
      }
      
      // Clear uploaded images after successful update
      menuProvider.clearForm();
      dev.log('✅ MenuProvider form state cleared');
      
      dev.log('🎉 Menu update process completed successfully');
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onMenuUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(uploadedImages.isNotEmpty 
                    ? 'Menu updated with ${uploadedImages.length} new image(s)!'
                    : 'Menu item updated successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      dev.log('❌ EDIT MENU ERROR: $e');
      dev.log('💾 Failed menu data dump:');
      dev.log('  - Name: "${_nameController.text}"');
      dev.log('  - Price: "${_priceController.text}"');
      dev.log('  - Category: ${_selectedCategory?.id} (${_selectedCategory?.name})');
      dev.log('  - Discount: "${_discountController.text}" ($_discountType)');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error updating menu item: $e')),
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
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSidesSection() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final sides = menuProvider.currentMenuSides;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sides & Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Current: ${sides.length} side(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      dev.log('🔘 Add Side button pressed in edit menu');
                      _showCreateSideDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Side'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (sides.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No sides added yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add sides like sizes, extras, or customizations',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sides.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final side = sides[index];
                    return _buildSideCard(context, side, menuProvider);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideCard(BuildContext context, Side side, MenuProvider menuProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: side.isDefault == true ? Colors.blue[50] : Colors.white,
        border: Border.all(
          color: side.isDefault == true ? Colors.blue[200]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      side.name ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (side.isDefault == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${side.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showCreateSideDialog(context, side: side),
                icon: const Icon(Icons.edit, size: 16),
                tooltip: 'Edit Side',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              IconButton(
                onPressed: () => _confirmDeleteSide(context, side, menuProvider),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                tooltip: 'Delete Side',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateSideDialog(BuildContext context, {Side? side}) {
    dev.log('📝 Showing create side dialog - editing: ${side != null ? "existing side ${side.id}" : "new side"}');
    showDialog(
      context: context,
      builder: (context) => CreateSideDialog(side: side),
    );
  }

  void _confirmDeleteSide(BuildContext context, Side side, MenuProvider menuProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Side'),
        content: Text('Are you sure you want to delete "${side.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              menuProvider.removeSide(side);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Side deleted successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
