import 'package:flutter/material.dart';
import '../models/api_response.dart';

class ErrorHandlingService {
  static void handleApiError(BuildContext context, dynamic error) {
    String userMessage = 'An unexpected error occurred';
    
    if (error is ApiException) {
      userMessage = error.message;
    } else if (error is NetworkException) {
      userMessage = 'Network connection error. Please check your internet connection.';
    } else if (error is UnauthorizedException) {
      userMessage = 'Your session has expired. Please log in again.';
      _showLogoutDialog(context);
      return;
    } else if (error.toString().contains('timeout')) {
      userMessage = 'Request timed out. Please try again.';
    } else if (error.toString().contains('connection')) {
      userMessage = 'Unable to connect to server. Please check your internet connection.';
    }
    
    _showErrorSnackBar(context, userMessage);
  }
  
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has expired. Please log in again to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  static void showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
