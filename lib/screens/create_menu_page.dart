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

class CreateMenuPage extends StatefulWidget {
  final VoidCallback onMenuCreated;
  final List<FainzyCategory> categories;

  const CreateMenuPage({
    super.key,
    required this.onMenuCreated,
    required this.categories,
  });

  @override
  State<CreateMenuPage> createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final MenuApiService _menuApiService = MenuApiService();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _discountController = TextEditingController();
  
  // Form state
  FainzyCategory? _selectedCategory;
  String _status = 'available';
  String _discountType = 'percentage'; // 'percentage' or 'value'
  bool _isLoading = false;
  String _currentCurrency = 'JPY'; // Default currency
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form for new menu creation but preserve any existing sides
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dev.log('🆕 CREATE MENU: Initializing create menu page');
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      
      // Clear form fields but NOT sides - user might have added sides before navigating here
      menuProvider.clearFormFieldsOnly();
      dev.log('✅ CREATE MENU: Form fields cleared, sides preserved');
    });
    
    // Only select categories with valid IDs (> 0)
    final validCategories = widget.categories.where((c) => c.id != null && c.id! > 0).toList();
    _selectedCategory = validCategories.isNotEmpty ? validCategories.first : null;
    
    print('Valid categories: ${validCategories.map((c) => '${c.id}: ${c.name}').join(', ')}');
    print('Selected category: ${_selectedCategory?.id}: ${_selectedCategory?.name}');
    
    // Load current currency
    _loadCurrentCurrency();
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
        child: Row(
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
                    'Create New Menu Item',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Add a delicious new item to your menu',
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
                Icons.add_circle,
                size: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
            _buildImagePicker(),
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
            color: AppColors.primaryMain.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryMain, size: 20),
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
            prefixIcon: prefixWidget ?? (icon != null ? Icon(icon, color: AppColors.primaryMain) : null),
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
              borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
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
            prefixIcon: const Icon(Icons.category, color: AppColors.primaryMain),
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
              borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: widget.categories
              .where((category) => category.id != null && category.id! > 0) // Filter valid categories
              .map((category) {
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
            if (value.id == null || value.id! <= 0) {
              return 'Please select a valid category';
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
              _status == 'available' ? Icons.check_circle : Icons.pause_circle,
              color: _status == 'available' ? AppColors.success : AppColors.error,
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
              borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: const [
            DropdownMenuItem(value: 'available', child: Text('Available')),
            DropdownMenuItem(value: 'unavailable', child: Text('Unavailable')),
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
            onPressed: _isLoading ? null : _createMenu,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            label: Text(_isLoading ? 'Creating...' : 'Create Menu Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
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
                ? const Icon(Icons.percent, color: AppColors.primaryMain)
                : CurrencyService.getFormFieldCurrencyIcon(
                    currencyCode: _currentCurrency,
                    color: AppColors.primaryMain,
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
              borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
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
                ? const Icon(Icons.percent, color: AppColors.primaryMain)
                : CurrencyService.getFormFieldCurrencyIcon(
                    currencyCode: _currentCurrency,
                    color: AppColors.primaryMain,
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
              borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
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
        color: AppColors.primaryMain.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryMain.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.preview, color: AppColors.primaryMain),
              const SizedBox(width: 12),
              const Text(
                'Price Preview:',
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
                      color: AppColors.primaryMain,
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
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                const SizedBox(width: 6),
                Text(
                  'API will receive: ${CurrencyService.formatPriceWithSymbol(CurrencyService.formatPriceForApi(discountPrice, _currentCurrency), _currentCurrency)} as discount_price',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
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

  Widget _buildImagePicker() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final uploadedImages = menuProvider.uploadedImageData;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New uploaded images section
            if (uploadedImages.isNotEmpty) ...[
              const Text(
                'Uploaded Images',
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
                        color: AppColors.primaryMain.withOpacity(0.3),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      color: AppColors.primaryMain.withOpacity(0.05),
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
                                const Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: AppColors.primaryMain,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  uploadedImages.isNotEmpty ? 'Add More Images' : 'Add Menu Images',
                                  style: const TextStyle(
                                    color: AppColors.primaryMain,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
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
            
            if (uploadedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.info_outline, 
                       size: 16, 
                       color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Images uploaded successfully! They will be attached to your menu item.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.info_outline, 
                       size: 16, 
                       color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add high-quality images to make your menu item more appealing',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(MenuProvider menuProvider) async {
    try {
      dev.log('📷 CREATE MENU - Starting image pick and upload...');
      final success = await menuProvider.pickAndUploadImage();
      
      if (success) {
        dev.log('✅ CREATE MENU - Image uploaded successfully');
      } else {
        dev.log('❌ CREATE MENU - Image upload failed');
      }
    } catch (e) {
      dev.log('❌ CREATE MENU - Error picking/uploading image: $e');
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

  void _createMenu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      final rawPrice = double.parse(_priceController.text);
      
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

      // Validate category selection
      if (_selectedCategory == null || _selectedCategory!.id == null || _selectedCategory!.id! <= 0) {
        throw Exception('Please select a valid category');
      }

      // Get uploaded image data from MenuProvider
      final uploadedImages = menuProvider.uploadedImageData;
      
      // Get the sides from MenuProvider
      final sides = menuProvider.currentMenuSides;
      
      // Debug: Log sides information
      dev.log('🍽️ Sides data from MenuProvider:');
      dev.log('  - Number of sides: ${sides.length}');
      for (int i = 0; i < sides.length; i++) {
        final side = sides[i];
        dev.log('  📦 Side ${i + 1}: "${side.name}" - \$${side.price} (Default: ${side.isDefault}) [ID: ${side.id}]');
      }
      
      // Convert uploaded image data to ImageElement objects
      final imageElements = uploadedImages.map((imageData) => ImageElement(
        id: imageData['id'],
        upload: imageData['upload'],
      )).toList();

      dev.log('📝 CREATE MENU: Starting menu creation process');
      dev.log('📋 Menu data:');
      dev.log('  - Name: "${_nameController.text.trim()}"');
      dev.log('  - Category ID: ${_selectedCategory!.id}');
      dev.log('  - Category Name: "${_selectedCategory!.name}"');
      dev.log('  - Price: ${CurrencyService.formatPriceWithSymbol(price, _currentCurrency)}');
      dev.log('  - Discount Price: ${discountPrice != null ? CurrencyService.formatPriceWithSymbol(discountPrice, _currentCurrency) : 'none'}');
      dev.log('  - API Price: $price (formatted for API)');
      dev.log('  - API Discount Price: ${discountPrice ?? 'none'} (formatted for API)');
      dev.log('  - Discount Type: $_discountType');
      dev.log('  - Discount Value: ${_discountController.text.isEmpty ? 'none' : _discountController.text}');
      dev.log('  - Description: "${_descriptionController.text.trim()}"');
      dev.log('  - Ingredients: "${_ingredientsController.text.trim()}"');
      dev.log('  - Status: $_status');
      dev.log('  - Uploaded Images: ${uploadedImages.length} image(s)');
      dev.log('  - Sides: ${sides.length} side(s)');
      
      // Log uploaded image details
      for (int i = 0; i < uploadedImages.length; i++) {
        final imageData = uploadedImages[i];
        dev.log('    📷 Image ${i + 1}: ID=${imageData['id']}, URL=${imageData['upload']}');
      }
      
      // Log sides details
      for (int i = 0; i < sides.length; i++) {
        final side = sides[i];
        dev.log('    🍽️ Side ${i + 1}: "${side.name}" - \$${side.price} (Default: ${side.isDefault})');
      }

      final menu = FainzyMenu(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        ingredients: _ingredientsController.text.trim().isEmpty 
            ? null 
            : _ingredientsController.text.trim(),
        category: _selectedCategory!.id,
        status: _status,
        discount: 0, // Always set discount to 0 by default
        discountPrice: discountPrice, // Send calculated discount_price to discountPrice field
        images: imageElements, // Include uploaded images directly
        // NOTE: sides are NOT included in menu payload - they will be created separately
      );

      // 📝 LOG: JSON payload being sent to API (without sides)
      final menuJson = menu.toJson();
      dev.log('📤 API Payload (JSON - without sides):');
      dev.log(jsonEncode(menuJson));
      
      // Validate payload structure
      if (menuJson.containsKey('discount_price') && menuJson['discount_price'] != null) {
        dev.log('✅ CORRECT: discount_price field contains calculated value: \$${menuJson['discount_price']}');
      }
      if (menuJson.containsKey('discount') && menuJson['discount'] != null) {
        dev.log('✅ CORRECT: discount field contains default value: ${menuJson['discount']}');
      }
      if (menuJson['images'] == null) {
        dev.log('⚠️ WARNING: images field is null (should be array)');
      } else {
        dev.log('✅ CORRECT: images field contains ${(menuJson['images'] as List).length} image(s)');
      }
      if (menuJson.containsKey('sides')) {
        dev.log('⚠️ WARNING: sides field found in menu payload (should not be included)');
      } else {
        dev.log('✅ CORRECT: sides field not included in menu payload (will be created separately)');
      }
      if (menuJson['category'] == null || menuJson['category'] == -1) {
        dev.log('⚠️ WARNING: category is null or invalid (-1)');
      }

      // Create the menu without sides
      dev.log('🚀 Calling API: createMenu (without sides)');
      final createdMenu = await _menuApiService.createMenu(menu);
      dev.log('✅ Menu creation API call successful');
      
      dev.log('📋 Created Menu Result:');
      dev.log('  - Created menu ID: ${createdMenu.id}');
      dev.log('  - Created menu images: ${createdMenu.images?.length ?? 0} image(s)');
      if (createdMenu.images != null && createdMenu.images!.isNotEmpty) {
        for (int i = 0; i < createdMenu.images!.length; i++) {
          final img = createdMenu.images![i];
          dev.log('    📷 Result Image ${i + 1}: ID=${img.id}, URL=${img.upload}');
        }
      }
      
      // Now create sides separately if the menu was created successfully
      if (createdMenu.id != null && sides.isNotEmpty) {
        dev.log('🍽️ Creating ${sides.length} sides for menu ${createdMenu.id}');
        
        // Log each side being created
        for (int i = 0; i < sides.length; i++) {
          final side = sides[i];
          dev.log('  📦 Side ${i + 1} to create: "${side.name}" - \$${side.price} (Default: ${side.isDefault})');
        }
        
        try {
          await _menuApiService.syncMenuSides(createdMenu.id!, sides, []);
          dev.log('✅ Side creation completed successfully');
          
          // Add a small delay to ensure sides are committed to database
          await Future.delayed(const Duration(milliseconds: 500));
          dev.log('⏱️ Waited for sides to be committed to database');
        } catch (e) {
          dev.log('❌ Failed to create sides: $e');
          // Note: We don't rethrow here because the menu was created successfully
          // The user can manually manage sides later if needed
        }
      } else if (sides.isEmpty) {
        dev.log('ℹ️ No sides to create for menu ${createdMenu.id}');
      }
      
      // Clear uploaded images after successful creation
      menuProvider.clearForm();
      dev.log('✅ MenuProvider form state cleared');
      
      dev.log('🎉 Menu creation process completed successfully');
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onMenuCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(uploadedImages.isNotEmpty 
                    ? 'Menu item created with ${uploadedImages.length} image(s)!'
                    : 'Menu item created successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      dev.log('❌ CREATE MENU ERROR: $e');
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
                Expanded(child: Text('Error creating menu item: $e')),
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
                  const Text(
                    'Sides & Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateSideDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Side'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMain,
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
