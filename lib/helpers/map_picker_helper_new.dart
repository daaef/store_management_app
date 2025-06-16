import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import '../models/location.dart';

class MapPickerHelper {
  static Future<Location?> showMapPicker(
    BuildContext context, {
    Location? initialLocation,
  }) async {
    try {
      // Check if API key is configured
      String apiKey = '';
      
      // Try to get from dotenv, if not available use fallback
      try {
        apiKey = dotenv.env['MAPSAPIKEY'] ?? '';
      } catch (e) {
        debugPrint('Dotenv not initialized, using fallback API key');
        apiKey = 'AIzaSyDp2HYHXxfnandJWObViW8N_-OG5EJFS9w';
      }
      
      if (apiKey.isEmpty) {
        debugPrint('Error: MAPSAPIKEY not found in .env file');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Maps API key not configured'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
      
      Location? selectedLocation;
      
      // Set initial position (default to a reasonable location if none provided)
      LatLng initialPosition = const LatLng(37.4219983, -122.084);
      
      if (initialLocation?.gpsCoordinates?.latitude != null && 
          initialLocation?.gpsCoordinates?.longitude != null) {
        final coords = initialLocation!.gpsCoordinates!;
        initialPosition = LatLng(
          coords.latitude.toDouble(), // latitude  
          coords.longitude.toDouble(), // longitude
        );
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlacePicker(
            apiKey: apiKey,
            onPlacePicked: (result) {
              final lat = result.geometry!.location.lat;
              final lng = result.geometry!.location.lng;
              
              // Parse address components to extract city, state, country
              String city = '';
              String state = '';
              String country = '';
              String postCode = '';
              
              if (result.addressComponents != null) {
                for (final component in result.addressComponents!) {
                  final types = component.types;
                  
                  if (types.contains('locality') || types.contains('administrative_area_level_2')) {
                    city = component.longName;
                  } else if (types.contains('administrative_area_level_1')) {
                    state = component.longName;
                  } else if (types.contains('country')) {
                    country = component.longName;
                  } else if (types.contains('postal_code')) {
                    postCode = component.longName;
                  }
                }
              }
              
              // If we couldn't get city from locality, try other address components
              if (city.isEmpty && result.addressComponents != null) {
                for (final component in result.addressComponents!) {
                  final types = component.types;
                  if (types.contains('sublocality') || 
                      types.contains('neighborhood') || 
                      types.contains('administrative_area_level_3')) {
                    city = component.longName;
                    break;
                  }
                }
              }
              
              selectedLocation = Location(
                name: result.name ?? result.formattedAddress ?? '',
                country: country,
                state: state,
                city: city,
                postCode: postCode.isNotEmpty ? postCode : null,
                addressDetails: result.formattedAddress ?? '',
                gpsCoordinates: GpsCoordinates.fromLatLng(lat, lng),
              );
              
              debugPrint('📍 Location picked:');
              debugPrint('  Name: ${selectedLocation!.name}');
              debugPrint('  City: ${selectedLocation!.city}');
              debugPrint('  State: ${selectedLocation!.state}');
              debugPrint('  Country: ${selectedLocation!.country}');
              debugPrint('  Address: ${selectedLocation!.addressDetails}');
              debugPrint('  Coordinates: $lat, $lng');
              
              Navigator.of(context).pop();
            },
            initialPosition: initialPosition,
            useCurrentLocation: true,
            selectInitialPosition: true,
            usePlaceDetailSearch: true,
            forceSearchOnZoomChanged: true,
            automaticallyImplyAppBarLeading: false,
            autocompleteLanguage: "en",
            region: 'us',
            selectText: "Select Location",
            outsideOfPickAreaText: "Place not in area",
          ),
        ),
      );
      
      return selectedLocation;
    } catch (e) {
      // Handle any errors gracefully
      debugPrint('Map picker error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
}
