import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fainzy_menu.dart';
import '../providers/menu_provider.dart';

class CreateSideDialog extends StatefulWidget {
  final Side? side; // For editing existing sides

  const CreateSideDialog({super.key, this.side});

  @override
  State<CreateSideDialog> createState() => _CreateSideDialogState();
}

class _CreateSideDialogState extends State<CreateSideDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.side?.name ?? '');
    _priceController = TextEditingController(
      text: widget.side?.price?.toString() ?? '',
    );
    _isDefault = widget.side?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final menuProvider = context.read<MenuProvider>();
      
      final side = Side(
        id: widget.side?.id ?? -DateTime.now().millisecondsSinceEpoch, // Use negative IDs for new sides
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        isDefault: _isDefault,
        created: widget.side?.created ?? DateTime.now(),
        modified: DateTime.now(),
      );

      if (widget.side != null) {
        // Update existing side
        menuProvider.updateSide(side);
      } else {
        // Add new side
        menuProvider.addSide(side);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.side != null 
                ? 'Side updated successfully!' 
                : 'Side created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.side != null ? 'Edit Side' : 'Add Side'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Side Name *',
                  hintText: 'e.g., Large Size, Extra Cheese',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a side name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: '¥',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Default option checkbox
              CheckboxListTile(
                title: const Text('Default Option'),
                subtitle: const Text('This side will be selected by default'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.side != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}

class SidesManagementWidget extends StatelessWidget {
  const SidesManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final sides = menuProvider.currentMenuSides;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Menu Sides & Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateSideDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Side'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (sides.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No sides added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add sides like sizes, extras, or customizations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
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
                        fontSize: 16,
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
                            fontSize: 10,
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
                    fontSize: 14,
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
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Edit Side',
              ),
              IconButton(
                onPressed: () => _confirmDeleteSide(context, side, menuProvider),
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                tooltip: 'Delete Side',
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
                  backgroundColor: Colors.green,
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
