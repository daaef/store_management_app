import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../providers/store_setup_provider.dart';
import '../models/location.dart';
import '../helpers/map_picker_helper.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  // Form keys
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();
  final _locationFormKey = GlobalKey<FormState>();
  final _scheduleFormKey = GlobalKey<FormState>();

  // Controllers
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Refresh store data from stored preferences first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<StoreSetupProvider>(context, listen: false);
      await provider.refreshFromStoredData();
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final provider = Provider.of<StoreSetupProvider>(context, listen: false);
    if (provider.isInitialized) {
      _storeNameController.text = provider.storeName;
      _descriptionController.text = provider.storeDescription;
      
      if (provider.location != null) {
        _streetController.text = provider.location!.addressDetails ?? '';
        _cityController.text = provider.location!.city ?? '';
        _stateController.text = provider.location!.state ?? '';
        _countryController.text = provider.location!.country ?? '';
      }
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Store Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<StoreSetupProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Information Section
                _buildSectionCard(
                  title: 'Store Information',
                  icon: Icons.store,
                  child: _buildBasicInfoForm(),
                ),
                const SizedBox(height: 24),
                
                // Contact Details Section
                _buildSectionCard(
                  title: 'Contact Details',
                  icon: Icons.contact_phone,
                  child: _buildContactForm(),
                ),
                const SizedBox(height: 24),
                
                // Location Section
                _buildSectionCard(
                  title: 'Location',
                  icon: Icons.location_on,
                  child: _buildLocationForm(),
                ),
                const SizedBox(height: 24),
                
                // Schedule Section
                _buildSectionCard(
                  title: 'Operating Schedule',
                  icon: Icons.schedule,
                  child: _buildScheduleForm(),
                ),
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.canSubmit ? _saveSettings : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.status == StoreSetupStatus.submitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return Form(
      key: _basicInfoFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _storeNameController,
            decoration: const InputDecoration(
              labelText: 'Store Name',
              hintText: 'Enter your store name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Store name is required';
              }
              return null;
            },
            onChanged: (value) {
              Provider.of<StoreSetupProvider>(context, listen: false)
                  .setStoreName(value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Store Description',
              hintText: 'Describe your store',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Store description is required';
              }
              return null;
            },
            onChanged: (value) {
              Provider.of<StoreSetupProvider>(context, listen: false)
                  .setStoreDescription(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    final provider = Provider.of<StoreSetupProvider>(context);
    
    return Form(
      key: _contactFormKey,
      child: Column(
        children: [
          InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              Provider.of<StoreSetupProvider>(context, listen: false)
                  .setPhoneNumber(number);
            },
            initialValue: provider.phoneNumber,
            inputDecoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: provider.selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(),
            ),
            items: provider.supportedCurrencies.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                Provider.of<StoreSetupProvider>(context, listen: false)
                    .setCurrency(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationForm() {
    final provider = Provider.of<StoreSetupProvider>(context);
    
    return Form(
      key: _locationFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.map),
                label: const Text('Pick on Map'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(),
            ),
          ),
          if (provider.location != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Location set',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleForm() {
    final provider = Provider.of<StoreSetupProvider>(context);
    
    return Form(
      key: _scheduleFormKey,
      child: Column(
        children: [
          // Operating Hours
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  label: 'Opening Time',
                  time: provider.openTime,
                  onTimeSelected: (time) {
                    Provider.of<StoreSetupProvider>(context, listen: false)
                        .setOpenTime(time);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeSelector(
                  label: 'Closing Time',
                  time: provider.closeTime,
                  onTimeSelected: (time) {
                    Provider.of<StoreSetupProvider>(context, listen: false)
                        .setCloseTime(time);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Working Days
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Working Days',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final isSelected = provider.workingDays.contains(index + 1);
              return FilterChip(
                label: Text(provider.dayNames[index]),
                selected: isSelected,
                onSelected: (selected) {
                  Provider.of<StoreSetupProvider>(context, listen: false)
                      .toggleWorkingDay(index + 1);
                },
                selectedColor: Colors.blue.withOpacity(0.2),
                checkmarkColor: Colors.blue,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selectedTime != null) {
          onTimeSelected(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickLocation() async {
    try {
      final location = await MapPickerHelper.showMapPicker(context);
      if (location != null) {
        Provider.of<StoreSetupProvider>(context, listen: false)
            .setLocation(location);
        
        // Update form fields with picked location
        _streetController.text = location.addressDetails ?? '';
        _cityController.text = location.city ?? '';
        _stateController.text = location.state ?? '';
        _countryController.text = location.country ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveSettings() async {
    // Validate all forms
    bool isValid = true;
    
    if (!_basicInfoFormKey.currentState!.validate()) {
      isValid = false;
    }
    
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<StoreSetupProvider>(context, listen: false);
    
    // Update provider with current form values
    provider.setStoreName(_storeNameController.text);
    provider.setStoreDescription(_descriptionController.text);
    
    // Update location if fields were manually edited
    if (provider.location != null) {
      final updatedLocation = Location(
        name: provider.location!.name,
        country: _countryController.text,
        postCode: provider.location!.postCode,
        state: _stateController.text,
        city: _cityController.text,
        ward: provider.location!.ward,
        village: provider.location!.village,
        locationType: provider.location!.locationType ?? 'pick_up',
        gpsCoordinates: provider.location!.gpsCoordinates,
        addressDetails: _streetController.text,
        serviceArea: provider.location!.serviceArea,
      );
      provider.setLocation(updatedLocation);
    }

    final success = await provider.submitStoreSetup();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store settings updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to update settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
