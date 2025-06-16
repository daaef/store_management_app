import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddMenuItemDialog(context);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 44, 105, 196),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Menu Items Grid
              Expanded(
                child: Consumer<MenuProvider>(
                  builder: (context, menuProvider, child) {
                    if (menuProvider.menuItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No menu items yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first menu item to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: menuProvider.menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuProvider.menuItems[index];
                        return _buildMenuItemCard(context, item, menuProvider);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(
      BuildContext context, MenuItem item, MenuProvider menuProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menu item icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fastfood,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),

            // Menu item name
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Menu item price
            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    _showEditMenuItemDialog(context, item);
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.blue,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmation(context, item, menuProvider);
                  },
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context) {
    _showMenuItemDialog(context, null);
  }

  void _showEditMenuItemDialog(BuildContext context, MenuItem item) {
    _showMenuItemDialog(context, item);
  }

  void _showMenuItemDialog(BuildContext context, MenuItem? item) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController =
        TextEditingController(text: item?.price.toString() ?? '');
    final isEditing = item != null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(isEditing ? 'Update' : 'Add'),
              onPressed: () {
                final name = nameController.text.trim();
                final priceText = priceController.text.trim();

                if (name.isNotEmpty && priceText.isNotEmpty) {
                  final price = double.tryParse(priceText);
                  if (price != null && price > 0) {
                    final menuProvider =
                        Provider.of<MenuProvider>(context, listen: false);

                    if (isEditing) {
                      // For editing, remove old item and add new one (simple approach)
                      menuProvider.deleteMenuItem(item.name);
                      menuProvider
                          .addMenuItem(MenuItem(name: name, price: price));
                    } else {
                      menuProvider
                          .addMenuItem(MenuItem(name: name, price: price));
                    }

                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, MenuItem item, MenuProvider menuProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Menu Item'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                menuProvider.deleteMenuItem(item.name);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
