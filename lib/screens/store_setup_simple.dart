import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import '../providers/store_setup_provider.dart';
import '../colors/app_colors.dart';
import '../text_styles/app_text_style.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_text_button.dart';
import '../widgets/time_picker_widget.dart';
import '../widgets/checkbox_list_item.dart';

class StoreSetupSimpleScreen extends StatelessWidget {
  const StoreSetupSimpleScreen({
    super.key,
    this.isEdit = false,
    this.storeId,
  });

  final bool isEdit;
  final String? storeId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StoreSetupProvider(),
      child: StoreSetupSimpleView(
        isEdit: isEdit,
        storeId: storeId,
      ),
    );
  }
}

class StoreSetupSimpleView extends StatefulWidget {
  const StoreSetupSimpleView({
    super.key,
    this.isEdit = false,
    this.storeId,
  });

  final bool isEdit;
  final String? storeId;

  @override
  State<StoreSetupSimpleView> createState() => _StoreSetupSimpleViewState();
}

class _StoreSetupSimpleViewState extends State<StoreSetupSimpleView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StoreSetupProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Store Details'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(StoreSetupProvider provider) {
    // Handle status changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.status == StoreSetupStatus.failed && provider.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(provider.error!),
              backgroundColor: Colors.red,
            ),
          );
      } else if (provider.status == StoreSetupStatus.success) {
        if (widget.isEdit) {
          Navigator.pop(context);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/root',
            (route) => false,
          );
        }
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                _buildWelcomeMessage(provider),
                const Gap(24),
                
                // Store Image Picker (Placeholder)
                _buildImagePicker(),
                const Gap(24),
                
                // Store Name
                _buildNameInput(provider),
                const Gap(24),
                
                // Description
                _buildDescriptionInput(provider),
                const Gap(24),
                
                // Phone Number
                _buildPhoneNumberInput(provider),
                const Gap(24),
                
                // Open/Close Times
                _buildTimeInputs(provider),
                const Gap(24),
                
                // Currency Selection
                _buildCurrencySelection(provider),
                const Gap(24),
                
                // Working Days
                _buildWorkingDays(provider),
                const Gap(24),
                
                // Address Section
                _buildAddressSection(provider),
                
                // Submit Button
                _buildSubmitButton(provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage(StoreSetupProvider provider) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Welcome! Set up your branch of ',
          ),
          TextSpan(
            text: provider.storeName.isNotEmpty 
                ? provider.storeName 
                : 'Your Store',
            style: const TextStyle(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      style: AppTextStyle.h4,
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 48,
            color: Colors.grey[400],
          ),
          const Gap(8),
          Text(
            'Store Image (Coming Soon)',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput(StoreSetupProvider provider) {
    return CustomTextField(
      labelText: 'Branch Name',
      initialValue: provider.storeName,
      maxLines: 1,
      isRequired: true,
      onChanged: (value) => provider.setStoreName(value),
    );
  }

  Widget _buildDescriptionInput(StoreSetupProvider provider) {
    return CustomTextField(
      labelText: 'Description',
      initialValue: provider.description,
      maxLines: 4,
      isRequired: true,
      onChanged: (value) => provider.setDescription(value),
    );
  }

  Widget _buildPhoneNumberInput(StoreSetupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Number',
          style: AppTextStyle.body2,
        ),
        const Gap(8),
        SizedBox(
          height: 80,
          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              if (number.phoneNumber != null) {
                provider.setPhoneNumberFromString(number.phoneNumber!);
              }
            },
            selectorConfig: const SelectorConfig(
              setSelectorButtonAsPrefixIcon: true,
              showFlags: false,
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            initialValue: provider.phoneNumber,
            spaceBetweenSelectorAndTextField: 0,
            inputDecoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              filled: true,
              fillColor: Colors.white,
              hintText: 'Phone Number',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'This is how customers will contact you',
              helperMaxLines: 2,
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            selectorTextStyle: const TextStyle(color: Colors.black),
            keyboardType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            countries: const ['NG', 'US', 'GB'],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInputs(StoreSetupProvider provider) {
    return Row(
      children: [
        Expanded(
          child: TimePickerWidget(
            label: 'Open Time',
            initialValue: provider.openTimeString,
            onTimePicked: (time) {
              provider.setOpenTimeFromString(time);
            },
          ),
        ),
        const Gap(12),
        Expanded(
          child: TimePickerWidget(
            label: 'Close Time',
            initialValue: provider.closeTimeString,
            onTimePicked: (time) {
              provider.setCloseTimeFromString(time);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelection(StoreSetupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Store Currency',
          style: AppTextStyle.body2,
        ),
        const Gap(8),
        DropdownButtonFormField<String>(
          value: provider.selectedCurrency,
          items: provider.supportedCurrencies
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              provider.setCurrency(value);
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFE9E5E5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFE9E5E5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFE9E5E5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Select Currency',
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingDays(StoreSetupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opening Days',
          style: AppTextStyle.body1.copyWith(fontWeight: FontWeight.bold),
        ),
        const Gap(16),
        Column(
          children: List.generate(provider.dayNames.length, (index) {
            final dayIndex = index + 1;
            final selected = provider.workingDays.contains(dayIndex);
            return CheckboxListItem(
              label: provider.dayNames[index],
              value: selected,
              onChanged: (value) {
                if (value!) {
                  provider.addWorkingDay(dayIndex);
                } else {
                  provider.removeWorkingDay(dayIndex);
                }
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAddressSection(StoreSetupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Address',
              style: AppTextStyle.body1.copyWith(fontWeight: FontWeight.bold),
            ),
            CustomTextButton(
              label: 'Pick Location (Coming Soon)',
              onPressed: () {
                // TODO: Implement map picker later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Map picker will be implemented next!'),
                  ),
                );
              },
            ),
          ],
        ),
        const Gap(16),
        
        // Manual address inputs for now
        CustomTextField(
          labelText: 'Street Address',
          initialValue: '',
          isRequired: true,
          onChanged: (value) {
            // TODO: Save to provider
          },
        ),
        const Gap(16),
        CustomTextField(
          labelText: 'City',
          initialValue: '',
          isRequired: true,
          onChanged: (value) {
            // TODO: Save to provider
          },
        ),
        const Gap(16),
        CustomTextField(
          labelText: 'State',
          initialValue: '',
          isRequired: true,
          onChanged: (value) {
            // TODO: Save to provider
          },
        ),
        const Gap(16),
        CustomTextField(
          labelText: 'Country',
          initialValue: '',
          isRequired: true,
          onChanged: (value) {
            // TODO: Save to provider
          },
        ),
        const Gap(24),
      ],
    );
  }

  Widget _buildSubmitButton(StoreSetupProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 55),
      child: CustomTextButton(
        isLoading: provider.status == StoreSetupStatus.submitting,
        label: 'Submit',
        onPressed: provider.canSubmit
            ? () {
                provider.submitStoreSetup();
              }
            : null,
      ),
    );
  }
}
