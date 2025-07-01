import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;
import '../providers/auth_provider.dart';
import '../routing/app_router.dart';
import '../routing/routes.dart';

/// Manages app lifecycle events and token validation
class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    dev.log('🔄 AppLifecycleManager: Initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    dev.log('📱 App lifecycle state changed: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        // App is transitioning between states
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        dev.log('👁️ App hidden');
        break;
    }
  }

  /// Handle app resumed from background
  Future<void> _handleAppResumed() async {
    dev.log('🔄 App resumed - checking token validity...');
    
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    // Only validate if user was previously logged in
    if (authProvider.isLoggedIn) {
      final isValid = await authProvider.revalidateTokenOnResume();
      
      if (!isValid && mounted) {
        dev.log('❌ Token invalid on resume - redirecting to login');
        
        // Show user-friendly message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please log in again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Navigate to login after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
              Routes.routeLogin,
              (route) => false,
            );
          }
        });
      } else if (isValid) {
        dev.log('✅ Token validated successfully on resume');
      }
    }
  }

  /// Handle app paused (going to background)
  void _handleAppPaused() {
    dev.log('⏸️ App paused - going to background');
    // Could implement additional security measures here like:
    // - Clear sensitive data from memory
    // - Blur/hide screen content for security
  }

  /// Handle app detached (being terminated)
  void _handleAppDetached() {
    dev.log('🛑 App detached - being terminated');
    // Could implement cleanup here if needed
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
