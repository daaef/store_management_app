import 'dart:io';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';
import '../models/store_data.dart';
import '../services/fainzy_api_client.dart';
import '../services/currency_service.dart';

enum StoreSetupStatus { initial, editing, validating, submitting, success, failed }
enum StoreSetupStep { basicInfo, contactDetails, location, schedule, review }

class StoreSetupProvider with ChangeNotifier {
  final FainzyApiClient _apiClient = FainzyApiClient();
  StoreSetupStatus _status = StoreSetupStatus.initial;
  String? _error;
  StoreSetupStep _currentStep = StoreSetupStep.basicInfo;
  int _stepIndex = 0;
  bool _isInitialized = false;

  // Form fields
  String _storeName = '';
  String _storeDescription = '';
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  String _selectedCurrency = 'JPY'; // Default to Yen
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 18, minute: 0);
  Set<int> _workingDays = {1, 2, 3, 4, 5}; // Monday to Friday
  Location? _location;
  File? _storeImage;
  String? _imageUrl;
  
  // Carousel images from server
  List<String> _carouselImages = [];

  // Multiple images support (for carousel picker)
  final List<File> _images = [];

  // Additional address fields that are actually used
  String _houseDetails = '';

  // Available options - now using CurrencyService
  List<String> get supportedCurrencies => CurrencyService.supportedCurrencies.map((c) => c['code'] as String).toList();
  final List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  // Getters
  StoreSetupStatus get status => _status;
  String? get error => _error;
  StoreSetupStep get currentStep => _currentStep;
  int get stepIndex => _stepIndex;
  bool get isInitialized => _isInitialized;

  String get storeName => _storeName;
  String get storeDescription => _storeDescription;
  String get description => _storeDescription; // Alias for consistency
  PhoneNumber get phoneNumber => _phoneNumber;
  String get selectedCurrency => _selectedCurrency;
  TimeOfDay get openTime => _openTime;
  TimeOfDay get closeTime => _closeTime;
  Set<int> get workingDays => _workingDays;
  Set<int> get selectedWorkingDays => _workingDays.map((day) => day - 1).toSet(); // Convert 1-based to 0-based for screen
  Location? get location => _location;
  File? get storeImage => _storeImage;
  String? get imageUrl => _imageUrl;
  List<String> get carouselImages => _carouselImages;
  List<File> get images => _images;
  String get houseDetails => _houseDetails;

  List<String> get dayNames => _dayNames;

  // Computed getters
  String get openTimeString => _formatTime(_openTime);
  String get closeTimeString => _formatTime(_closeTime);
  String get phoneNumberString => _phoneNumber.phoneNumber ?? '';
  List<String> get workingDayNames => _workingDays.map((day) => _dayNames[day - 1]).toList();

  // Validation getters
  bool get isBasicInfoValid => _storeName.isNotEmpty && _storeDescription.isNotEmpty;
  bool get isContactValid => _phoneNumber.phoneNumber?.isNotEmpty == true;
  bool get isLocationValid => _location != null;
  bool get isScheduleValid => _workingDays.isNotEmpty;

  bool get isCurrentStepValid {
    switch (_currentStep) {
      case StoreSetupStep.basicInfo:
        return isBasicInfoValid;
      case StoreSetupStep.contactDetails:
        return isContactValid;
      case StoreSetupStep.location:
        return isLocationValid;
      case StoreSetupStep.schedule:
        return isScheduleValid;
      case StoreSetupStep.review:
        return isBasicInfoValid && isContactValid && isLocationValid && isScheduleValid;
    }
  }

  bool get canSubmit {
    return _storeName.isNotEmpty &&
          _storeDescription.isNotEmpty &&
          _phoneNumber.phoneNumber != null &&
          _location != null &&
          _workingDays.isNotEmpty;
  }

  // Constructor with automatic initialization (like last_mile_store)
  StoreSetupProvider() {
    _initializeFromStoredData();
  }

  // Public method to refresh data from storage (for use in settings screen)
  Future<void> refreshFromStoredData() async {
    await _initializeFromStoredData();
  }

  // Initialize provider and load existing data (similar to last_mile_store pattern)
  Future<void> _initializeFromStoredData() async {
    try {
      dev.log('🔄 StoreSetupProvider: Starting initialization...');
      _status = StoreSetupStatus.editing;

      await _loadDataFromLogin();

      _isInitialized = true;
      dev.log('✅ StoreSetupProvider: Initialization completed successfully');
      notifyListeners();
    } catch (e) {
      dev.log('❌ StoreSetupProvider: Initialization failed: $e');
      _error = 'Failed to initialize: $e';
      _status = StoreSetupStatus.failed;
      notifyListeners();
    }
  }

  // Load data from SharedPreferences using the new StoreData model
  Future<void> _loadDataFromLogin() async {
    try {
      dev.log('🔍 StoreSetupProvider: Loading data from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();

      // Log all keys in SharedPreferences for debugging
      final allKeys = prefs.getKeys();
      dev.log('📋 Available SharedPreferences keys: ${allKeys.toList()}');

      // First try to load structured StoreData object from auth provider
      final storeDataJson = prefs.getString('storeData');
      if (storeDataJson != null) {
        try {
          final jsonMap = json.decode(storeDataJson) as Map<String, dynamic>;
          final storeData = StoreData.fromJson(jsonMap);
          dev.log('✅ Found structured StoreData');
          _populateFromStoreData(storeData);
          return;
        } catch (e) {
          dev.log('⚠️ Failed to parse structured StoreData: $e');
        }
      }

      // Fallback: Check for different possible keys that might contain store data
      final possibleKeys = [
        'User', // This is what last_mile_store uses
        'user',
        'store',
        'storeData',
        'fainzyStore',
        'authenticatedStore',
        'loginData',
        'currentUser'
      ];

      Map<String, dynamic>? rawStoreData;
      String? foundKey;

      for (String key in possibleKeys) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          try {
            rawStoreData = json.decode(jsonString);
            foundKey = key;
            dev.log('✅ Found store data in key "$key"');
            break;
          } catch (e) {
            dev.log('⚠️ Failed to parse JSON from key "$key": $e');
          }
        }
      }

      if (rawStoreData != null && foundKey != null) {
        dev.log('📄 Raw store data from "$foundKey": ${json.encode(rawStoreData)}');
        _populateFieldsFromStoreData(rawStoreData);
      } else {
        dev.log('⚠️ No store data found in SharedPreferences - creating sample data for testing');
        // Create sample login response data for testing
        await _createSampleLoginData();
        // Try to load any saved form data
        await _loadSavedFormData();
      }

    } catch (e) {
      dev.log('❌ Error loading from login data: $e');
    }
  }

  // New method to populate from structured StoreData object
  void _populateFromStoreData(StoreData storeData) {
    try {
      dev.log('🔍 Populating form from StoreData object...');
      
      // Store name 
      if (storeData.name != null) {
        _storeName = storeData.name!;
        dev.log('📝 Loaded store name: $_storeName');
        dev.log('storedata ${storeData.toString()}');
      }
      
      // Store description
      if (storeData.description != null) {
        _storeDescription = storeData.description!;
        dev.log('📝 Loaded store description: $_storeDescription');
      }
      
      // Phone number
      if (storeData.phoneNumber != null && storeData.phoneNumber!.isNotEmpty) {
        try {
          String phoneNumber = storeData.phoneNumber!;
          String isoCode = 'US'; // Default
          
          if (phoneNumber.startsWith('+81')) {
            isoCode = 'JP';
            phoneNumber = phoneNumber.substring(3);
          } else if (phoneNumber.startsWith('+234')) {
            isoCode = 'NG';
            phoneNumber = phoneNumber.substring(4);
          } else if (phoneNumber.startsWith('+1')) {
            isoCode = 'US';
            phoneNumber = phoneNumber.substring(2);
          } else if (phoneNumber.startsWith('+44')) {
            isoCode = 'GB';
            phoneNumber = phoneNumber.substring(3);
          }
          
          _phoneNumber = PhoneNumber(phoneNumber: phoneNumber, isoCode: isoCode);
          dev.log('📞 Loaded phone number: ${storeData.phoneNumber} (country: $isoCode, number: $phoneNumber)');
        } catch (e) {
          dev.log('⚠️ Failed to parse phone number: $e');
        }
      }
      
      // Working days - use the helper property from StoreData model and convert to Set
      _workingDays = storeData.workingDays.toSet();
      dev.log('📅 Loaded working days: ${_workingDays.map((d) => _dayNames[d-1]).join(', ')}');
      
      // Start time
      if (storeData.startTime != null) {
        _openTime = _parseTimeString(storeData.startTime!) ?? _openTime;
        dev.log('🕘 Loaded open time: ${_formatTime(_openTime)}');
      }
      
      // Closing time
      if (storeData.closingTime != null) {
        _closeTime = _parseTimeString(storeData.closingTime!) ?? _closeTime;
        dev.log('🕕 Loaded close time: ${_formatTime(_closeTime)}');
      }
      
      // Currency
      if (storeData.currency != null) {
        final upperCurrency = storeData.currency!.toUpperCase();
        if (supportedCurrencies.contains(upperCurrency)) {
          _selectedCurrency = upperCurrency;
          dev.log('💰 Loaded currency: $_selectedCurrency');
        } else {
          dev.log('⚠️ Unsupported currency: ${storeData.currency}, keeping default');
        }
      }
      
      // Images - use helper properties from StoreData model
      if (storeData.imagePath != null) {
        _imageUrl = storeData.imagePath;
        dev.log('🖼️ Loaded main image URL: $_imageUrl');
      }
      
      // Carousel images - use helper property from StoreData model
      _carouselImages = storeData.carouselImageUrls;
      if (_carouselImages.isNotEmpty) {
        dev.log('🖼️ Loaded ${_carouselImages.length} carousel images: $_carouselImages');
        // If no main image is set, use the first carousel image
        if (_imageUrl == null && _carouselImages.isNotEmpty) {
          _imageUrl = _carouselImages.first;
          dev.log('🖼️ Set first carousel image as main image: $_imageUrl');
        }
      } else {
        dev.log('📷 No carousel images found in StoreData');
      }
      
      // Location
      if (storeData.location != null) {
        _location = storeData.location;
        dev.log('📍 Loaded location: ${storeData.location!.name}');
      }
      
      // Address from StoreData.address
      if (storeData.address != null) {
        _parseAddressFromStoreData(storeData.address!);
      }
      
      // GPS coordinates
      if (storeData.gpsCoordinates != null) {
        _parseGpsCoordinatesFromStoreData(storeData.gpsCoordinates!);
      }
      
      dev.log('✅ StoreData population completed');
      
    } catch (e) {
      dev.log('❌ Error populating from StoreData: $e');
    }
  }

  void _parseAddressFromStoreData(AddressData address) {
    _houseDetails = address.houseDetails ?? address.addressDetails ?? '';
    
    dev.log('🏙️ Loaded address - City: ${address.city}, State: ${address.state}, Country: ${address.country}');
    dev.log('🏠 Address name: ${address.name}');
    dev.log('🏠 House details: $_houseDetails');
    
    // Create location object if we have address info
    if (address.city.isNotEmpty || 
        address.state.isNotEmpty || 
        address.country.isNotEmpty) {
      _location = Location(
        name: address.name,
        addressDetails: _houseDetails,
        city: address.city,
        state: address.state,
        country: address.country,
      );
    }
  }

  void _parseGpsCoordinatesFromStoreData(GpsCoordinatesData coords) {
    if (coords.coordinates.length >= 2) {
      final latitude = coords.coordinates[1]; // GPS format is [longitude, latitude]
      final longitude = coords.coordinates[0];
      
      dev.log('🌍 Loaded GPS coordinates: $latitude, $longitude');
      
      // Update location with GPS coordinates
      if (_location != null) {
        _location = _location!.copyWith(
          gpsCoordinates: GpsCoordinates.fromLatLng(
            latitude,
            longitude,
          ),
        );
      } else {
        _location = Location(
          gpsCoordinates: GpsCoordinates.fromLatLng(
            latitude,
            longitude,
          ),
        );
      }
    }
  }

  // Create sample login response data for testing (based on real API response format)
  Future<void> _createSampleLoginData() async {
    try {
      final sampleLoginResponse = {
        "status": "success",
        "message": "Store successfully logged in",
        "data": {
          "token": "3b5b1b84dfde193a9cf1a89fd68a1664393b8012bacb0b9b5780aee429e41e2b",
          "subentity": {
            "id": 4,
            "name": "Fainzy Cafe JP - Family Mart Nagoya Uni - ファミリーマート名古屋大学店",
            "setup": true,
            "branch": "Nagoya Uni 名古屋大学",
            "store_type": "convenience_store",
            "mobile_number": "+819081811937",
            "currency": "jpy",
            "store_category": "lastmile",
            "description": "コンビニ Convenient Store",
            "image": {
              "id": null,
              "subentity": 4,
              "upload": "https://res.cloudinary.com/fainzy-technologies/image/upload/v1/media/users/logoBlack_jayvwl_rgkhgp.png"
            },
            "rating": 3.6666666666666665,
            "total_reviews": 6,
            "status": 3,
            "start_time": "08:00",
            "opening_days": "mon,tue,wed,thu,fri,sat",
            "closing_time": "22:00",
            "notification_id": "f45d6822-7b90-4be4-88cc-67fe60337895",
            "carousel_uploads": [
              {
                "id": 21,
                "menu": null,
                "upload": "https://res.cloudinary.com/fainzy-technologies/image/upload/v1/media/menu/sample1.jpg",
                "created": "2024-04-25T05:43:23.226173+09:00",
                "modified": "2024-04-25T05:43:23.226208+09:00",
                "subentity": 4
              },
              {
                "id": 23,
                "menu": null,
                "upload": "https://res.cloudinary.com/fainzy-technologies/image/upload/v1/media/menu/sample2.jpg",
                "created": "2024-04-25T05:43:54.332184+09:00",
                "modified": "2024-04-25T05:43:54.332238+09:00",
                "subentity": 4
              }
            ],
            "gps_coordinates": {
              "type": "Point",
              "coordinates": [136.9061, 35.1547]
            },
            "address": {
              "id": 10,
              "name": "Fainzy Cafe JP - Family Mart Nagoya Uni - ファミリーマート名古屋大学店",
              "subentity": 4,
              "floor_number": "1",
              "country": "Japan",
              "post_code": "",
              "state": "Aichi",
              "city": "Nagoya",
              "ward": "",
              "village": "",
              "service_area": 1,
              "location_type": "pick_up",
              "gps_coordinates": {
                "type": "Point",
                "coordinates": [136.9061, 35.1547]
              },
              "house_details": "gazebo_campus",
              "address_details": "Japan, 〒464-0000 Aichi, Nagoya, Chikusa Ward, Furōchō, 宮東町1番 ファミリーマート名古屋大学店",
              "operation_mode": "outdoor_indoor",
              "position_location": "outdoor",
              "is_default": true,
              "is_active": true
            }
          }
        }
      };

      final prefs = await SharedPreferences.getInstance();
      final dataMap = sampleLoginResponse['data'] as Map<String, dynamic>?;
      final subentityMap = dataMap?['subentity'] as Map<String, dynamic>?;
      final token = dataMap?['token'] as String?;
      
      if (subentityMap != null) {
        await prefs.setString('User', json.encode(subentityMap));
        dev.log('✅ Created sample login data for testing');
        // Now load the sample data
        _populateFieldsFromStoreData(subentityMap);
      }
      
      if (token != null) {
        await prefs.setString('FainzyApiToken', token);
      }
      
      final subentityId = subentityMap?['id']?.toString();
      if (subentityId != null) {
        await prefs.setString('subEntityId', subentityId);
      }
      
    } catch (e) {
      dev.log('❌ Error creating sample login data: $e');
    }
  }

  // Populate form fields from store data (based on real API response format)
  void _populateFieldsFromStoreData(Map<String, dynamic> data) {
    try {
      dev.log('🔍 Parsing store data structure...');
      
      // Store name 
      if (data.containsKey('name')) {
        _storeName = data['name']?.toString() ?? '';
        dev.log('📝 Loaded store name: $data');
      }
      
      // Store description
      if (data.containsKey('description')) {
        _storeDescription = data['description']?.toString() ?? '';
        dev.log('📝 Loaded store description: $_storeDescription');
      }
      
      // Phone number from response.subentity.mobile_number
      if (data.containsKey('mobile_number')) {
        final mobile = data['mobile_number']?.toString();
        if (mobile != null && mobile.isNotEmpty) {
          try {
            // Parse country code if it's in the format +819081811937
            String phoneNumber = mobile;
            String isoCode = 'US'; // Default
            
            if (mobile.startsWith('+81')) {
              isoCode = 'JP';
              phoneNumber = mobile.substring(3); // Remove +81
            } else if (mobile.startsWith('+234')) {
              isoCode = 'NG';
              phoneNumber = mobile.substring(4); // Remove +234
            } else if (mobile.startsWith('+1')) {
              isoCode = 'US';
              phoneNumber = mobile.substring(2); // Remove +1
            } else if (mobile.startsWith('+44')) {
              isoCode = 'GB';
              phoneNumber = mobile.substring(3); // Remove +44
            }
            
            _phoneNumber = PhoneNumber(phoneNumber: phoneNumber, isoCode: isoCode);
            dev.log('📞 Loaded phone number: $mobile (country: $isoCode, number: $phoneNumber)');
          } catch (e) {
            dev.log('⚠️ Failed to parse phone number: $e');
          }
        }
      }
      
      // Working days from opening_days string (mon,tue)
      if (data.containsKey('opening_days')) {
        final openingDays = data['opening_days']?.toString();
        if (openingDays != null && openingDays.isNotEmpty) {
          _workingDays = _convertStringToWorkingDays(openingDays);
          dev.log('📅 Loaded working days: ${_workingDays.map((d) => _dayNames[d-1]).join(', ')}');
        }
      }
      
      // Start time
      if (data.containsKey('start_time')) {
        final startTime = data['start_time']?.toString();
        if (startTime != null && startTime.isNotEmpty) {
          _openTime = _parseTimeString(startTime) ?? _openTime;
          dev.log('🕘 Loaded open time: ${_formatTime(_openTime)}');
        }
      }
      
      // Closing time
      if (data.containsKey('closing_time')) {
        final closingTime = data['closing_time']?.toString();
        if (closingTime != null && closingTime.isNotEmpty) {
          _closeTime = _parseTimeString(closingTime) ?? _closeTime;
          dev.log('🕕 Loaded close time: ${_formatTime(_closeTime)}');
        }
      }
      
      // Currency
      if (data.containsKey('currency')) {
        final currency = data['currency']?.toString();
        if (currency != null) {
          // Convert to uppercase for our supported currencies
          final upperCurrency = currency.toUpperCase();
          if (supportedCurrencies.contains(upperCurrency)) {
            _selectedCurrency = upperCurrency;
            dev.log('💰 Loaded currency: $_selectedCurrency');
          } else {
            dev.log('⚠️ Unsupported currency: $currency, keeping default');
          }
        }
      }
      
      
      // Handle carousel_uploads for images
      if (data.containsKey('carousel_uploads') && data['carousel_uploads'] is List) {
        final carouselUploads = data['carousel_uploads'] as List;
        if (carouselUploads.isNotEmpty) {
          dev.log('🖼️ Found ${carouselUploads.length} carousel images');
          
          // Store carousel images for display
          _carouselImages.clear();
          
          // Process all carousel images
          for (int i = 0; i < carouselUploads.length; i++) {
            final upload = carouselUploads[i];
            if (upload is Map<String, dynamic> && upload.containsKey('upload')) {
              final imageUrl = upload['upload']?.toString();
              if (imageUrl != null) {
                _carouselImages.add(imageUrl);
                if (i == 0) {
                  // Set first image as main image
                  _imageUrl = imageUrl;
                  dev.log('🖼️ Set main image from carousel: $imageUrl');
                }
                dev.log('🖼️ Carousel image ${i + 1}: $imageUrl');
              }
            }
          }
        } else {
          dev.log('📷 No carousel images found');
        }
      }
      
      // Handle main image from response.subentity.image.upload
      if (data.containsKey('image')) {
        final image = data['image'];
        if (image is Map<String, dynamic> && image.containsKey('upload')) {
          _imageUrl = image['upload']?.toString();
          dev.log('🖼️ Loaded main image URL: $_imageUrl');
        }
      }
      
      // Handle address data from response.subentity.address
      if (data.containsKey('address')) {
        final address = data['address'];
        if (address is Map<String, dynamic>) {
          dev.log('🏠 Processing address data: ${json.encode(address)}');
          _parseAddressData(address);
        }
      }
      
      // Handle GPS coordinates
      if (data.containsKey('gps_coordinates')) {
        final coords = data['gps_coordinates'];
        final gpsCoordinates = _parseGpsCoordinatesData(coords);
        
        if (gpsCoordinates != null) {
          // If we already have a location, update it with GPS coordinates
          if (_location != null) {
            _location = _location!.copyWith(gpsCoordinates: gpsCoordinates);
            dev.log('📍 Updated existing location with GPS coordinates: ${gpsCoordinates.latitude}, ${gpsCoordinates.longitude}');
          } else {
            // Create new location with just GPS coordinates
            _location = Location(gpsCoordinates: gpsCoordinates);
            dev.log('📍 Created new location with GPS coordinates: ${gpsCoordinates.latitude}, ${gpsCoordinates.longitude}');
          }
        }
      }
      
      dev.log('✅ Store data parsing completed');
      
    } catch (e) {
      dev.log('❌ Error parsing store data: $e');
    }
  }

  void _parseAddressData(Map<String, dynamic> address) {
    // Parse according to the new API response format:
    // city: response.subentity.address.city
    // state: response.subentity.address.state  
    // country: response.subentity.address.country
    // address: response.subentity.address.name
    final city = address['city']?.toString() ?? '';
    final state = address['state']?.toString() ?? '';
    final country = address['country']?.toString() ?? '';
    final addressName = address['name']?.toString() ?? '';
    final addressDetails = address['address_details']?.toString() ?? '';
    final houseDetails = address['house_details']?.toString() ?? '';
    final ward = address['ward']?.toString() ?? '';
    final village = address['village']?.toString() ?? '';
    final postCode = address['post_code']?.toString() ?? '';
    final locationType = address['location_type']?.toString() ?? '';
    final serviceArea = address['service_area'] as int?;
    
    _houseDetails = houseDetails.isNotEmpty ? houseDetails : addressDetails;
    
    dev.log('🏙️ Loaded address data:');
    dev.log('   City: $city');
    dev.log('   State: $state'); 
    dev.log('   Country: $country');
    dev.log('   Ward: $ward');
    dev.log('   Village: $village');
    dev.log('   Post Code: $postCode');
    dev.log('   Location Type: $locationType');
    dev.log('   Service Area: $serviceArea');
    dev.log('🏠 Address name: $addressName');
    dev.log('🏠 House details: $_houseDetails');
    
    // Handle GPS coordinates within address
    GpsCoordinates? gpsCoordinates;
    if (address.containsKey('gps_coordinates')) {
      final gpsData = address['gps_coordinates'];
      gpsCoordinates = _parseGpsCoordinatesData(gpsData);
    }
    
    // Create location object with all available data
    _location = Location(
      name: addressName.isNotEmpty ? addressName : null,
      addressDetails: _houseDetails.isNotEmpty ? _houseDetails : null,
      city: city.isNotEmpty ? city : null,
      state: state.isNotEmpty ? state : null,
      country: country.isNotEmpty ? country : null,
      ward: ward.isNotEmpty ? ward : null,
      village: village.isNotEmpty ? village : null,
      postCode: postCode.isNotEmpty ? postCode : null,
      locationType: locationType.isNotEmpty ? locationType : null,
      serviceArea: serviceArea,
      gpsCoordinates: gpsCoordinates,
    );
    
    dev.log('📍 Created location object: ${_location.toString()}');
  }

  void _parseLocationData(Map<String, dynamic> locationData) {
    final city = locationData['city']?.toString() ?? '';
    final state = locationData['state']?.toString() ?? '';
    final country = locationData['country']?.toString() ?? '';
    final addressDetails = locationData['address_details']?.toString() ?? locationData['addressDetails']?.toString() ?? '';
    
    _houseDetails = addressDetails;
    
    dev.log('📍 Location - City: $city, State: $state, Country: $country');
    dev.log('🏠 Address details: $addressDetails');
    
    // Handle GPS coordinates within location
    if (locationData.containsKey('gps_coordinates')) {
      final gpsCoords = locationData['gps_coordinates'];
      final coordinates = _parseGpsCoordinates(gpsCoords);
      
      _location = Location(
        addressDetails: addressDetails,
        city: city,
        state: state,
        country: country,
        gpsCoordinates: coordinates['latitude'] != null && coordinates['longitude'] != null
            ? GpsCoordinates.fromLatLng(
                coordinates['latitude']!,
                coordinates['longitude']!,
              )
            : null,
      );
    } else {
      _location = Location(
        addressDetails: addressDetails,
        city: city,
        state: state,
        country: country,
      );
    }
  }

  Map<String, double?> _parseGpsCoordinates(dynamic coords) {
    double? latitude;
    double? longitude;
    
    if (coords is Map<String, dynamic>) {
      try {
        // Try different coordinate formats
        if (coords.containsKey('coordinates') && coords['coordinates'] is List) {
          final coordinatesList = coords['coordinates'] as List;
          if (coordinatesList.length >= 2) {
            // GPS format is [longitude, latitude] in some APIs
            longitude = double.tryParse(coordinatesList[0].toString());
            latitude = double.tryParse(coordinatesList[1].toString());
            dev.log('📍 GPS coordinates from nested coordinates array: lat=$latitude, lng=$longitude');
          }
        } else {
          // Direct latitude/longitude properties
          latitude = double.tryParse(coords['latitude']?.toString() ?? '');
          longitude = double.tryParse(coords['longitude']?.toString() ?? '');
          dev.log('📍 GPS coordinates from direct properties: lat=$latitude, lng=$longitude');
        }
      } catch (e) {
        dev.log('⚠️ Failed to parse GPS coordinates from map: $e');
      }
    } else if (coords is List && coords.length >= 2) {
      try {
        // Direct coordinate array [longitude, latitude]
        longitude = double.tryParse(coords[0].toString());
        latitude = double.tryParse(coords[1].toString());
        dev.log('📍 GPS coordinates from direct array: lat=$latitude, lng=$longitude');
      } catch (e) {
        dev.log('⚠️ Failed to parse GPS coordinates from list: $e');
      }
    }
    
    return {'latitude': latitude, 'longitude': longitude};
  }

  // Helper method to parse GPS coordinates and return GpsCoordinates object
  GpsCoordinates? _parseGpsCoordinatesData(dynamic coords) {
    final parsed = _parseGpsCoordinates(coords);
    final latitude = parsed['latitude'];
    final longitude = parsed['longitude'];
    
    if (latitude != null && longitude != null && latitude != 0.0 && longitude != 0.0) {
      return GpsCoordinates.fromLatLng(latitude, longitude);
    }
    
    dev.log('⚠️ Invalid or missing GPS coordinates: lat=$latitude, lng=$longitude');
    return null;
  }

  // Convert working days string to Set<int> (similar to last_mile_store)
  Set<int> _convertStringToWorkingDays(String openingDays) {
    final daysMap = {
      'mon': 1, 'monday': 1,
      'tue': 2, 'tuesday': 2,
      'wed': 3, 'wednesday': 3,
      'thu': 4, 'thursday': 4,
      'fri': 5, 'friday': 5,
      'sat': 6, 'saturday': 6,
      'sun': 7, 'sunday': 7,
    };
    
    final Set<int> workingDays = {};
    final days = openingDays.toLowerCase().split(',');
    
    for (final day in days) {
      final trimmedDay = day.trim();
      if (daysMap.containsKey(trimmedDay)) {
        workingDays.add(daysMap[trimmedDay]!);
      }
    }
    
    return workingDays.isNotEmpty ? workingDays : {1, 2, 3, 4, 5}; // Default to weekdays
  }

  // Parse time string to TimeOfDay
  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      dev.log('⚠️ Failed to parse time string "$timeString": $e');
    }
    return null;
  }

  // Load any previously saved form data
  Future<void> _loadSavedFormData() async {
    try {
      dev.log('💾 Loading saved form data...');
      final prefs = await SharedPreferences.getInstance();
      
      final savedName = prefs.getString('draft_store_name');
      final savedDescription = prefs.getString('draft_store_description');
      final savedCurrency = prefs.getString('draft_currency');
      
      if (savedName != null) {
        _storeName = savedName;
        dev.log('📝 Loaded draft store name: $savedName');
      }
      
      if (savedDescription != null) {
        _storeDescription = savedDescription;
        dev.log('📝 Loaded draft description: $savedDescription');
      }
      
      if (savedCurrency != null && supportedCurrencies.contains(savedCurrency)) {
        _selectedCurrency = savedCurrency;
        dev.log('💰 Loaded draft currency: $savedCurrency');
      }
      
    } catch (e) {
      dev.log('❌ Error loading saved form data: $e');
    }
  }

  // Update methods
  void updateStoreName(String name) {
    _storeName = name;
    _saveFormData();
    notifyListeners();
  }

  void updateStoreDescription(String description) {
    _storeDescription = description;
    _saveFormData();
    notifyListeners();
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void updateCurrency(String currency) {
    if (supportedCurrencies.contains(currency)) {
      _selectedCurrency = currency;
      // Also save to currency service
      CurrencyService.setCurrency(currency);
      _saveFormData();
      notifyListeners();
    }
  }

  void updateOpenTime(TimeOfDay time) {
    _openTime = time;
    notifyListeners();
  }

  void updateCloseTime(TimeOfDay time) {
    _closeTime = time;
    notifyListeners();
  }

  void updateWorkingDays(Set<int> days) {
    _workingDays = days;
    dev.log('📅 Updated working days: ${days.map((d) => _dayNames[d-1]).join(', ')}');
    notifyListeners();
  }

  void toggleWorkingDay(int day) {
    if (_workingDays.contains(day)) {
      _workingDays.remove(day);
    } else {
      _workingDays.add(day);
    }
    dev.log('📅 Toggled working day ${_dayNames[day-1]}. Current: ${_workingDays.map((d) => _dayNames[d-1]).join(', ')}');
    notifyListeners();
  }

  void updateLocation(Location location) {
    _location = location;
    dev.log('📍 Updated location: ${location.name} - ${location.addressDetails}');
    notifyListeners();
  }
  
  void updateHouseDetails(String details) {
    _houseDetails = details;
    dev.log('🏠 Updated house details: $details');
    notifyListeners();
  }
  
  void setLocation(Location? location) {
    _location = location;
    dev.log('📍 Set location: ${location?.name}');
    notifyListeners();
  }

  // Address callback for map picker (fixed to match Location model structure)
  void updateAddressFromMap(String address, Map<String, dynamic> coordinates) {
    dev.log('🗺️ Address updated from map picker:');
    dev.log('   Address: $address');
    dev.log('   Coordinates: $coordinates');
    
    _houseDetails = address;
    
    // Create or update location with proper GpsCoordinates object
    _location = Location(
      gpsCoordinates: GpsCoordinates.fromLatLng(
        coordinates['latitude'] as double,
        coordinates['longitude'] as double,
      ),
      addressDetails: address,
      city: _location?.city,
      state: _location?.state,
      country: _location?.country,
    );
    
    final lat = _location?.gpsCoordinates?.latitude;
    final lng = _location?.gpsCoordinates?.longitude;
    dev.log('📍 Updated location: $lat, $lng - ${_location?.addressDetails}');
    
    notifyListeners();
  }

  // Additional method for updating address details from address picker
  void updateAddressDetails(String city, String state, String country) {
    dev.log('🏙️ Address details updated:');
    dev.log('   City: $city');
    dev.log('   State: $state');
    dev.log('   Country: $country');
    
    // Update location if we have one
    if (_location != null) {
      _location = _location!.copyWith(
        city: city,
        state: state,
        country: country,
      );
    } else {
      _location = Location(
        city: city,
        state: state,
        country: country,
      );
    }
    
    notifyListeners();
  }

  void updateAddressField(String field, String value) {
    dev.log('🏠 Updating address field $field: $value');
    
    // Initialize location if null
    if (_location == null) {
      _location = Location();
    }
    
    switch (field) {
      case 'address':
        _location = _location!.copyWith(name: value);
        break;
      case 'city':
        _location = _location!.copyWith(city: value);
        break;
      case 'state':
        _location = _location!.copyWith(state: value);
        break;
      case 'country':
        _location = _location!.copyWith(country: value);
        break;
    }
    
    notifyListeners();
  }

  Future<void> updateStoreImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        _storeImage = File(image.path);
        dev.log('📸 Store image updated: ${image.path}');
        notifyListeners();
      }
    } catch (e) {
      dev.log('❌ Error picking store image: $e');
    }
  }

  Future<void> addCarouselImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        _images.add(File(image.path));
        dev.log('📸 Added carousel image: ${image.path}. Total images: ${_images.length}');
        notifyListeners();
      }
    } catch (e) {
      dev.log('❌ Error adding carousel image: $e');
    }
  }

  void removeCarouselImage(int index) {
    if (index >= 0 && index < _images.length) {
      final removedPath = _images[index].path;
      _images.removeAt(index);
      dev.log('🗑️ Removed carousel image: $removedPath. Remaining: ${_images.length}');
      notifyListeners();
    }
  }

  // Navigation methods
  void nextStep() {
    if (_stepIndex < StoreSetupStep.values.length - 1) {
      _stepIndex++;
      _currentStep = StoreSetupStep.values[_stepIndex];
      dev.log('➡️ Moved to step: ${_currentStep.name}');
      notifyListeners();
    }
  }

  void previousStep() {
    if (_stepIndex > 0) {
      _stepIndex--;
      _currentStep = StoreSetupStep.values[_stepIndex];
      dev.log('⬅️ Moved to step: ${_currentStep.name}');
      notifyListeners();
    }
  }

  void goToStep(StoreSetupStep step) {
    _currentStep = step;
    _stepIndex = StoreSetupStep.values.indexOf(step);
    dev.log('🎯 Jumped to step: ${_currentStep.name}');
    notifyListeners();
  }

  // Save current form data as draft
  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('draft_store_name', _storeName);
      await prefs.setString('draft_store_description', _storeDescription);
      await prefs.setString('draft_currency', _selectedCurrency);
    } catch (e) {
      dev.log('❌ Error saving form data: $e');
    }
  }

  // Submit store data - Fixed to use updateStore instead of createStore
  Future<void> submitStoreData() async {
    try {
      _status = StoreSetupStatus.submitting;
      _error = null;
      notifyListeners();

      dev.log('🚀 Submitting store data...');

      // Get stored token and subEntityId from login
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('FainzyApiToken') ?? prefs.getString('token') ?? prefs.getString('apiToken');
      final subEntityIdStr = prefs.getString('storeID') ?? prefs.getString('StoreId') ?? prefs.getString('storeId');
      

      dev.log('🔑 Retrieved token: $token');
      dev.log('🏪 Retrieved subEntityId: $subEntityIdStr');

      dev.log('📦 Preparing store data for submission...');
      if (token == null) {
        throw 'No authentication token found';
      }
      
      if (subEntityIdStr == null) {
        throw 'No store ID found';
      }

      // Extract numeric ID from string like "FZY_586940" -> 586940
      int subEntityId;
      if (subEntityIdStr.contains('_')) {
        // Extract the numeric part after the underscore
        final parts = subEntityIdStr.split('_');
        if (parts.length >= 2) {
          subEntityId = int.parse(parts[1]);
        } else {
          throw 'Invalid store ID format: $subEntityIdStr';
        }
      } else {
        // If it's already numeric, parse it directly
        subEntityId = int.parse(subEntityIdStr);
      }

      // Prepare store data for API
      final storeData = <String, dynamic>{
        'name': _storeName,
        'branch': _storeName,
        'description': _storeDescription,
        'mobile_number': _phoneNumber.phoneNumber ?? '',
        'currency': _selectedCurrency.toLowerCase(),
        'start_time': _formatTime(_openTime),
        'closing_time': _formatTime(_closeTime),
        'opening_days': _formatWorkingDays(),
        'setup': true,
      };

      // Add location data if available
      if (_location != null) {
        final Map<String, dynamic> location = {
          'name': _storeName,
          'country': _location!.country,
          'state': _location!.state,
          'city': _location!.city,
          'village': _location!.village ?? '',
          'ward': _location!.ward ?? '',
          'post_code': _location!.postCode ?? '',
          'address_details': _location!.addressDetails,
          'location_type': _location!.locationType ?? 'pick_up',
        };
        
        // Add service_area as simple ID (API expects pk value, not dict)
        location['service_area'] = _location!.serviceArea ?? 1;
        
        // Add GPS coordinates at location level if available
        if (_location!.gpsCoordinates != null) {
          location['gps_coordinates'] = {
            'latitude': _location!.gpsCoordinates!.latitude,
            'longitude': _location!.gpsCoordinates!.longitude
          };
        }
        
        storeData['location'] = [location];
      }


      dev.log('Store Data before api: ($storeData)');
      
      // Debug log the location data specifically
      if (storeData['location'] != null) {
        dev.log('📍 Location data being sent to API:');
        dev.log('   service_area: ${storeData['location'][0]['service_area']}');
        dev.log('   gps_coordinates: ${storeData['location'][0]['gps_coordinates']}');
        
        // Log the GPS coordinates format specifically
        if (storeData['location'][0]['gps_coordinates'] != null) {
          final gpsCoords = storeData['location'][0]['gps_coordinates'];
          dev.log('   GPS coordinates type: ${gpsCoords['type']}');
          dev.log('   GPS coordinates array: ${gpsCoords['coordinates']}');
        }
      }

      final response = await _apiClient.updateStore(
        subEntityId: subEntityId,
        store: storeData,
        apiToken: token,
      );

      // Check if response is successful (status code 200/201 means success)
      if (response.status == 'success' || response.data != null) {
        _status = StoreSetupStatus.success;
        dev.log('✅ Store updated successfully');
        
        // Clear draft data
        await prefs.remove('draft_store_name');
        await prefs.remove('draft_store_description');
        await prefs.remove('draft_currency');
      } else {
        _status = StoreSetupStatus.failed;
        _error = response.message ?? 'Failed to update store';
        dev.log('❌ Store update failed: $_error');
      }
    } catch (e) {
      _status = StoreSetupStatus.failed;
      _error = 'Error updating store: $e';
      dev.log('❌ Error submitting store data: $e');
    }

    notifyListeners();
  }

  // Reset form
  void reset() {
    _status = StoreSetupStatus.initial;
    _error = null;
    _currentStep = StoreSetupStep.basicInfo;
    _stepIndex = 0;
    _isInitialized = false;
    
    _storeName = '';
    _storeDescription = '';
    _phoneNumber = PhoneNumber(isoCode: 'US');
    _selectedCurrency = 'JPY';
    _openTime = const TimeOfDay(hour: 9, minute: 0);
    _closeTime = const TimeOfDay(hour: 18, minute: 0);
    _workingDays = {1, 2, 3, 4, 5};
    _location = null;
    _storeImage = null;
    _imageUrl = null;
    _carouselImages.clear();
    _images.clear();
    
    _houseDetails = '';
    
    dev.log('🔄 Store setup provider reset');
    notifyListeners();
  }

  // Screen compatibility methods (aliases for existing methods)
  void setStoreName(String value) => updateStoreName(value);
  void setStoreDescription(String value) => updateStoreDescription(value);
  void setDescription(String value) => updateStoreDescription(value); // Alternate name for consistency
  void setCurrency(String value) => updateCurrency(value);
  void setPhoneNumber(PhoneNumber number) => updatePhoneNumber(number);
  void setOpenTime(TimeOfDay time) => updateOpenTime(time);
  void setCloseTime(TimeOfDay time) => updateCloseTime(time);
  
  // Submit store setup with proper return type for screen
  Future<bool> submitStoreSetup() async {
    await submitStoreData();
    return _status == StoreSetupStatus.success;
  }
  
  // Phone number method
  void setPhoneNumberFromString(String phoneNumberString) {
    try {
      final phoneNumber = PhoneNumber(phoneNumber: phoneNumberString);
      updatePhoneNumber(phoneNumber);
    } catch (e) {
      dev.log('❌ Error setting phone number from string: $e');
    }
  }
  
  // Time methods
  void setOpenTimeFromString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final time = TimeOfDay(hour: hour, minute: minute);
        updateOpenTime(time);
      }
    } catch (e) {
      dev.log('❌ Error setting open time from string: $e');
    }
  }
  
  void setCloseTimeFromString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final time = TimeOfDay(hour: hour, minute: minute);
        updateCloseTime(time);
      }
    } catch (e) {
      dev.log('❌ Error setting close time from string: $e');
    }
  }
  
  // Working days methods
  void addWorkingDay(int day) {
    if (day >= 1 && day <= 7 && !_workingDays.contains(day)) {
      _workingDays.add(day);
      dev.log('✅ Added working day: ${_dayNames[day-1]} (index: $day)');
      notifyListeners();
    }
  }
  
  void removeWorkingDay(int day) {
    if (_workingDays.contains(day)) {
      _workingDays.remove(day);
      dev.log('✅ Removed working day: ${_dayNames[day-1]} (index: $day)');
      notifyListeners();
    }
  }
  
  // Step navigation methods - using the ones defined above
  
  void _updateCurrentStep() {
    switch (_stepIndex) {
      case 0:
        _currentStep = StoreSetupStep.basicInfo;
        break;
      case 1:
        _currentStep = StoreSetupStep.contactDetails;
        break;
      case 2:
        _currentStep = StoreSetupStep.location;
        break;
      case 3:
        _currentStep = StoreSetupStep.schedule;
        break;
      case 4:
        _currentStep = StoreSetupStep.review;
        break;
    }
  }
  
  // Email and website fields
  String _email = '';
  String _website = '';
  
  String get email => _email;
  String get website => _website;
  
  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }
  
  void setWebsite(String value) {
    _website = value;
    notifyListeners();
  }
  
  // Working days as formatted string
  String get workingDaysString {
    final List<String> days = _workingDays.map((day) => _dayNames[day-1]).toList()..sort();
    return days.join(', ');
  }
  
  // Image methods
  void addImage(File image) {
    if (_images.length < 5) {
      _images.add(image);
      dev.log('📸 Added image: ${image.path}. Total images: ${_images.length}');
      notifyListeners();
    }
  }
  
  void removeImage(File image) {
    final index = _images.indexWhere((img) => img.path == image.path);
    if (index != -1) {
      _images.removeAt(index);
      dev.log('🗑️ Removed image: ${image.path}. Remaining: ${_images.length}');
      notifyListeners();
    }
  }

  // Helper methods
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Convert working days to comma-separated string format
  String _formatWorkingDays() {
    final List<String> dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final buffer = StringBuffer();
    final separatedDays = _workingDays.map((day) => dayNames[day-1]).toList();
    buffer.writeAll(separatedDays, ',');
    return buffer.toString();
  }

  @override
  void dispose() {
    dev.log('🗑️ StoreSetupProvider disposed');
    super.dispose();
  }

  // Set a carousel image as the main image
  void setMainImageFromCarousel(String imageUrl) {
    _imageUrl = imageUrl;
    dev.log('🖼️ Set main image from carousel: $imageUrl');
    notifyListeners();
  }
}
