import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routing/app_router.dart';
import '../routing/routes.dart';

/// Helper class to periodically validate authentication tokens
class TokenValidationHelper {
  static TokenValidationHelper? _instance;
  static TokenValidationHelper get instance => _instance ??= TokenValidationHelper._();
  
  TokenValidationHelper._();
  
  Timer? _validationTimer;
  static const Duration _validationInterval = Duration(minutes: 30); // Check every 30 minutes
  
  /// Start periodic token validation
  void startPeriodicValidation(BuildContext context) {
    dev.log('🔄 Starting periodic token validation...');
    
    _validationTimer?.cancel();
    _validationTimer = Timer.periodic(_validationInterval, (timer) {
      _validateToken(context);
    });
  }
  
  /// Stop periodic token validation
  void stopPeriodicValidation() {
    dev.log('⏹️ Stopping periodic token validation');
    _validationTimer?.cancel();
    _validationTimer = null;
  }
  
  /// Perform token validation
  Future<void> _validateToken(BuildContext context) async {
    try {
      dev.log('🔍 Performing periodic token validation...');
      
      if (!context.mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      
      if (!authProvider.isLoggedIn) {
        dev.log('ℹ️ User not logged in, skipping validation');
        return;
      }
      
      final isValid = await authProvider.validateStoredToken();
      
      if (!isValid && context.mounted) {
        dev.log('❌ Periodic validation failed - redirecting to login');
        
        // Stop further validations
        stopPeriodicValidation();
        
        // Show session expired message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please log in again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Navigate to login
        AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          Routes.routeLogin,
          (route) => false,
        );
      } else if (isValid) {
        dev.log('✅ Periodic token validation successful');
      }
    } catch (e) {
      dev.log('⚠️ Error during periodic token validation: $e');
    }
  }
  
  /// Manual token validation (can be called from UI)
  Future<bool> validateTokenManually(BuildContext context) async {
    try {
      dev.log('🔄 Manual token validation requested');
      
      if (!context.mounted) return false;
      
      final authProvider = context.read<AuthProvider>();
      
      if (!authProvider.isLoggedIn) {
        dev.log('ℹ️ User not logged in');
        return false;
      }
      
      final isValid = await authProvider.validateStoredToken();
      
      if (context.mounted) {
        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session is valid and active'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session has expired'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      
      return isValid;
    } catch (e) {
      dev.log('⚠️ Error during manual token validation: $e');
      return false;
    }
  }
}
