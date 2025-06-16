import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../providers/store_setup_provider.dart';
import '../colors/app_colors.dart';
import '../text_styles/app_text_style.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_text_button.dart';
import '../routing/routes.dart';
import '../helpers/map_picker_helper_new.dart';

class StoreSetupScreen extends StatelessWidget {
  const StoreSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StoreSetupProvider(),
      child: const _StoreSetupView(),
    );
  }
}

class _StoreSetupView extends StatefulWidget {
  const _StoreSetupView();

  @override
  State<_StoreSetupView> createState() => _StoreSetupViewState();
}

class _StoreSetupViewState extends State<_StoreSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  
  // Address field controllers
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _houseDetailsController = TextEditingController();

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _houseDetailsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Store Setup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<StoreSetupProvider>(
        builder: (context, provider, child) {
          // Update controllers when provider data changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_storeNameController.text != provider.storeName) {
              _storeNameController.text = provider.storeName;
            }
            if (_storeDescriptionController.text != provider.storeDescription) {
              _storeDescriptionController.text = provider.storeDescription;
            }
            
            // Update address controllers
            if (_streetAddressController.text != (provider.location?.name ?? '')) {
              _streetAddressController.text = provider.location?.name ?? '';
            }
            if (_cityController.text != (provider.location?.city ?? '')) {
              _cityController.text = provider.location?.city ?? '';
            }
            if (_stateController.text != (provider.location?.state ?? '')) {
              _stateController.text = provider.location?.state ?? '';
            }
            if (_countryController.text != (provider.location?.country ?? '')) {
              _countryController.text = provider.location?.country ?? '';
            }
            if (_houseDetailsController.text != provider.houseDetails) {
              _houseDetailsController.text = provider.houseDetails;
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set up your store',
                        style: AppTextStyle.h1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Fill in the details to get your store ready for orders',
                        style: AppTextStyle.body1.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Gap(32),

                      // Store Image Upload
                      const _StoreImageSection(),
                      const Gap(24),

                      // Store Name Input
                      _StoreNameInput(controller: _storeNameController),
                      const Gap(24),

                      // Store Description Input
                      _StoreDescriptionInput(controller: _storeDescriptionController),
                      const Gap(24),

                      // Phone Number Input
                      const _PhoneNumberInput(),
                      const Gap(24),

                      // Opening Hours (placeholder for now)
                      const _OpeningHoursSection(),
                      const Gap(24),

                      // Store Location
                      _StoreLocationSection(
                        streetAddressController: _streetAddressController,
                        cityController: _cityController,
                        stateController: _stateController,
                        countryController: _countryController,
                        houseDetailsController: _houseDetailsController,
                      ),
                      const Gap(24),

                      // Currency Selection (placeholder for now)
                      const _CurrencySelection(),
                      const Gap(24),

                      // Working Days (placeholder for now)
                      const _WorkingDaysSection(),
                      const Gap(32),

                      // Submit Button - This will be the working API connection
                      const _SubmitButton(),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Store Name Input Widget
class _StoreNameInput extends StatelessWidget {
  const _StoreNameInput({required this.controller});
  
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return CustomTextField(
          labelText: 'Store Name',
          hintText: 'Enter your store name',
          controller: controller,
          onChanged: (value) => provider.updateStoreName(value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Store name is required';
            }
            return null;
          },
        );
      },
    );
  }
}

// Store Description Input Widget
class _StoreDescriptionInput extends StatelessWidget {
  const _StoreDescriptionInput({required this.controller});
  
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return CustomTextField(
          labelText: 'Store Description',
          hintText: 'Describe what your store offers',
          controller: controller,
          maxLines: 3,
          onChanged: (value) => provider.updateStoreDescription(value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Store description is required';
            }
            return null;
          },
        );
      },
    );
  }
}

// Phone Number Input - Working implementation
class _PhoneNumberInput extends StatelessWidget {
  const _PhoneNumberInput();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number',
              style: AppTextStyle.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                provider.updatePhoneNumber(number);
              },
              selectorConfig: const SelectorConfig(
                setSelectorButtonAsPrefixIcon: true,
                showFlags: true,
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              initialValue: provider.phoneNumber,
              spaceBetweenSelectorAndTextField: 0,
              inputDecoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, 
                  horizontal: 16,
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter your store phone number',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Enter your business phone number for customer contact',
                helperMaxLines: 2,
                helperStyle: AppTextStyle.caption.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              selectorTextStyle: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
              // Support multiple countries - you can customize this list
              countries: const ['US', 'NG', 'GH', 'GB', 'CA', 'JP'],
            ),
          ],
        );
      },
    );
  }
}

// Opening Hours Section
class _OpeningHoursSection extends StatelessWidget {
  const _OpeningHoursSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opening Hours',
              style: AppTextStyle.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Open Time Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Open Time',
                          style: AppTextStyle.body1.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectTime(context, provider, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const Gap(4),
                              Text(
                                provider.openTimeString,
                                style: AppTextStyle.body1.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  // Close Time Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Close Time',
                          style: AppTextStyle.body1.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectTime(context, provider, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const Gap(4),
                              Text(
                                provider.closeTimeString,
                                style: AppTextStyle.body1.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, StoreSetupProvider provider, bool isOpenTime) async {
    final TimeOfDay initialTime = isOpenTime ? provider.openTime : provider.closeTime;
    
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      if (isOpenTime) {
        provider.updateOpenTime(selectedTime);
      } else {
        provider.updateCloseTime(selectedTime);
      }
    }
  }
}

// Store Location Section
class _StoreLocationSection extends StatelessWidget {
  const _StoreLocationSection({
    required this.streetAddressController,
    required this.cityController,
    required this.stateController,
    required this.countryController,
    required this.houseDetailsController,
  });
  
  final TextEditingController streetAddressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final TextEditingController houseDetailsController;

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Location',
              style: AppTextStyle.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current location display
                  if (provider.location != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 20,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            (provider.location!.addressDetails?.isNotEmpty == true) 
                                ? provider.location!.addressDetails!
                                : (provider.location!.name ?? 'Selected Location'),
                            style: AppTextStyle.body1.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_off,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const Gap(8),
                        Text(
                          'No location selected',
                          style: AppTextStyle.body1.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                  ],
                  
                  // Pick location button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _pickLocation(context, provider),
                      icon: const Icon(
                        Icons.map,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        provider.location != null ? 'Change Location' : 'Pick Location',
                        style: AppTextStyle.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  // Address details input
                  if (provider.location != null) ...[
                    const Gap(16),
                    CustomTextField(
                      labelText: 'Additional Address Details',
                      hintText: 'Suite, apartment, floor, etc. (optional)',
                      controller: houseDetailsController,
                      onChanged: (value) => provider.updateHouseDetails(value),
                      maxLines: 2,
                    ),
                  ],
                  
                  // Address form fields
                  const Gap(16),
                  Text(
                    'Address Information',
                    style: AppTextStyle.h5.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(12),
                  
                  // Address/Street
                  CustomTextField(
                    labelText: 'Street Address',
                    hintText: 'Enter street address',
                    controller: streetAddressController,
                    onChanged: (value) => provider.updateAddressField('address', value),
                  ),
                  const Gap(12),
                  
                  // City
                  CustomTextField(
                    labelText: 'City',
                    hintText: 'Enter city',
                    controller: cityController,
                    onChanged: (value) => provider.updateAddressField('city', value),
                  ),
                  const Gap(12),
                  
                  // State
                  CustomTextField(
                    labelText: 'State/Province',
                    hintText: 'Enter state or province',
                    controller: stateController,
                    onChanged: (value) => provider.updateAddressField('state', value),
                  ),
                  const Gap(12),
                  
                  // Country
                  CustomTextField(
                    labelText: 'Country',
                    hintText: 'Enter country',
                    controller: countryController,
                    onChanged: (value) => provider.updateAddressField('country', value),
                  ),
                  
                  // Show location data status
                  if (provider.location != null) ...[
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              const Gap(8),
                              Text(
                                'Location Data Status',
                                style: AppTextStyle.body2.copyWith(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          if (provider.location?.gpsCoordinates != null) ...[
                            Text(
                              '📍 GPS: ${provider.location!.gpsCoordinates!.latitude.toStringAsFixed(4)}, ${provider.location!.gpsCoordinates!.longitude.toStringAsFixed(4)}',
                              style: AppTextStyle.caption.copyWith(
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                          if (provider.location?.city?.isNotEmpty == true ||
                              provider.location?.state?.isNotEmpty == true ||
                              provider.location?.country?.isNotEmpty == true) ...[
                            Text(
                              '🌍 Address components loaded from map selection',
                              style: AppTextStyle.caption.copyWith(
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickLocation(BuildContext context, StoreSetupProvider provider) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Gap(16),
                Text(
                  'Opening map picker...',
                  style: AppTextStyle.body1,
                ),
              ],
            ),
          ),
        ),
      );

      // Use the existing MapPickerHelper
      final selectedLocation = await MapPickerHelper.showMapPicker(
        context,
        initialLocation: provider.location,
      );

      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (selectedLocation != null) {
        provider.updateLocation(selectedLocation);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location selected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Currency Selection
class _CurrencySelection extends StatelessWidget {
  const _CurrencySelection();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency',
              style: AppTextStyle.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: provider.selectedCurrency?.toLowerCase(), // Convert to lowercase for dropdown
                  hint: Text(
                    'Select Currency',
                    style: AppTextStyle.body1.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  isExpanded: true,
                  items: provider.supportedCurrencies.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency.toLowerCase(), // Keep lowercase for consistency
                      child: Row(
                        children: [
                          Text(
                            _getCurrencySymbol(currency),
                            style: AppTextStyle.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            currency,
                            style: AppTextStyle.body1,
                          ),
                          const Gap(8),
                          Text(
                            '(${_getCurrencyName(currency)})',
                            style: AppTextStyle.body2.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Convert back to uppercase before storing
                      provider.updateCurrency(newValue.toUpperCase()); 
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'NGN':
        return '₦';
      case 'GHS':
        return '₵';
      case 'JPY':
        return '¥';
      default:
        return currency;
    }
  }

  String _getCurrencyName(String currency) {
    switch (currency) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'NGN':
        return 'Nigerian Naira';
      case 'GHS':
        return 'Ghanaian Cedi';
      case 'JPY':
        return 'Japanese Yen';
      default:
        return currency;
    }
  }
}

// Working Days Section
class _WorkingDaysSection extends StatelessWidget {
  const _WorkingDaysSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Working Days',
              style: AppTextStyle.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the days your store is open:',
                    style: AppTextStyle.body2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Gap(12),
                  // Days grid
                  ...List.generate(provider.dayNames.length, (index) {
                    final dayIndex = index + 1; // Convert to 1-based index for provider
                    final dayName = provider.dayNames[index];
                    final isSelected = provider.workingDays.contains(dayIndex);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => provider.toggleWorkingDay(dayIndex),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primary
                                        : Colors.grey[400]!,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const Gap(12),
                              Text(
                                dayName,
                                style: AppTextStyle.body1.copyWith(
                                  fontWeight: isSelected 
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected 
                                      ? AppColors.primary
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  if (provider.workingDays.isEmpty) ...[
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              'Please select at least one working day',
                              style: AppTextStyle.body2.copyWith(
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Store Image Upload Section with Carousel Support
class _StoreImageSection extends StatelessWidget {
  const _StoreImageSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Images',
              style: AppTextStyle.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            
            // Main Image Display
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: provider.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(
                            provider.imageUrl!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.photo,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Main Image',
                                style: AppTextStyle.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildImagePlaceholder(),
            ),
            
            // Horizontal carousel list
            if (provider.carouselImages.isNotEmpty) ...[
              const Gap(12),
              Text(
                'Additional Images',
                style: AppTextStyle.body2.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const Gap(8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.carouselImages.length,
                  itemBuilder: (context, index) {
                    final imageUrl = provider.carouselImages[index];
                    return Container(
                      margin: EdgeInsets.only(right: index < provider.carouselImages.length - 1 ? 8 : 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          onTap: () {
                            // Set this image as the main image
                            provider.setMainImageFromCarousel(imageUrl);
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: provider.imageUrl == imageUrl 
                                    ? AppColors.primary 
                                    : Colors.grey[300]!,
                                width: provider.imageUrl == imageUrl ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Show status of loaded images
            if (provider.imageUrl != null) ...[
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store images loaded successfully',
                            style: AppTextStyle.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Images are automatically loaded from your store data',
                            style: AppTextStyle.caption.copyWith(
                              color: AppColors.primary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Image picker button (for adding new images)
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => provider.updateStoreImage(),
                icon: const Icon(
                  Icons.add_photo_alternate,
                  color: AppColors.primary,
                ),
                label: Text(
                  provider.imageUrl != null ? 'Change Main Image' : 'Add Store Image',
                  style: AppTextStyle.body1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return InkWell(
      onTap: () {
        // TODO: Implement image picker
      },
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 32,
              color: Colors.grey[400],
            ),
            const Gap(8),
            Text(
              'Add Store Image',
              style: AppTextStyle.body2.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              '(Optional)',
              style: AppTextStyle.caption.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Submit Button - This will have the working API connection
class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: CustomTextButton(
            label: 'Setup Store',
            isLoading: provider.status == StoreSetupStatus.submitting,
            onPressed: provider.status == StoreSetupStatus.submitting 
                ? null 
                : () => _handleSubmit(context, provider),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context, StoreSetupProvider provider) async {
    // Validate form
    final form = Form.of(context);
    if (!form.validate()) {
      return;
    }

    // Additional validation for phone number
    if (provider.phoneNumber.phoneNumber == null || 
        provider.phoneNumber.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading state and call API
      final success = await provider.submitStoreSetup();
      
      if (success && context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store setup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to root/dashboard
        Navigator.of(context).pushReplacementNamed(Routes.routeRoot);
      } else if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Store setup failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}