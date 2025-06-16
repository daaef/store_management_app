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
        initialPosition = LatLng(
          initialLocation!.gpsCoordinates!.latitude.toDouble(), // latitude
          initialLocation.gpsCoordinates!.longitude.toDouble(), // longitude
        );
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlacePicker(
            apiKey: apiKey,
            onPlacePicked: (result) {
              double lat = 0.0;
              double lng = 0.0;
              
              if (result.geometry?.location != null) {
                lat = result.geometry!.location.lat;
                lng = result.geometry!.location.lng;
              }
              
              selectedLocation = Location(
                name: result.formattedAddress ?? '',
                country: '',
                state: '',
                city: '',
                ward: '',
                village: '',
                postCode: '',
                addressDetails: result.formattedAddress ?? '',
                gpsCoordinates: GpsCoordinates.fromLatLng(lat, lng),
              );
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
  
  static Future<Location?> pickLocation(BuildContext context) async {
    return await showMapPicker(context);
  }
}
