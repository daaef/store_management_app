import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_management_app/providers/auth_provider.dart';
import 'package:store_management_app/routing/app_router.dart';
import 'package:store_management_app/routing/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // For production, remove this testing code
    // prefs.setBool('seenOnboarding', false);

    final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    print('🔍 SPLASH: Waiting for authentication validation to complete...');
    
    // Wait for the auth provider to finish its initial validation
    // This ensures we have accurate authentication status
    int attempts = 0;
    const maxAttempts = 10; // Max 5 seconds wait
    
    while (authProvider.authState == AuthState.initial && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
      print('🔄 SPLASH: Waiting for auth validation... attempt $attempts');
    }

    print('🔍 SPLASH: Authentication validation completed');
    print('  - Auth provider isLoggedIn: ${authProvider.isLoggedIn}');
    print('  - Auth state: ${authProvider.authState}');
    print('  - Store data available: ${authProvider.storeData != null}');
    print('  - Store setup status: ${authProvider.storeData?.isSetup}');
    print('  - Seen onboarding: $seenOnboarding');

    // Check if user has valid token and is authenticated
    if (authProvider.isLoggedIn && authProvider.authState == AuthState.authenticated) {
      print('✅ SPLASH: User is authenticated with valid token');
      
      // Check if store setup is completed
      if (authProvider.storeData != null && authProvider.storeData!.isSetup == true) {
        print('🏪 SPLASH: Store setup completed - navigating to home feed');
        // Store is set up, go to main app (home feed)
        AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          Routes.routeRoot,
          (route) => false,
        );
      } else {
        print('⚙️ SPLASH: Store setup incomplete - navigating to setup');
        // Store is not set up, go to store setup
        AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          Routes.routeStoreSetup,
          (route) => false,
        );
      }
    } else {
      print('❌ SPLASH: User not authenticated or invalid token');
      
      if (seenOnboarding) {
        print('📱 SPLASH: Onboarding seen - navigating to login');
        // User has seen onboarding but is not logged in
        AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          Routes.routeLogin,
          (route) => false,
        );
      } else {
        print('👋 SPLASH: First time user - navigating to onboarding');
        // First time user, show onboarding
        AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          Routes.routeOnboarding,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 82, 155), // Dark blue background color
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delivery_dining_sharp,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Fainzy Store Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
