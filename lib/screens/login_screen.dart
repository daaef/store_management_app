// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routing/app_router.dart';
import '../routing/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storeIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isCheckingExistingToken = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  @override
  void dispose() {
    _storeIdController.dispose();
    super.dispose();
  }

  /// Check if user already has a valid token before showing login form
  Future<void> _checkExistingToken() async {
    setState(() {
      _isCheckingExistingToken = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      print('🔍 LOGIN: Checking for existing valid token...');
      
      // Validate stored token
      final hasValidToken = await authProvider.validateStoredToken();
      
      if (!mounted) return;
      
      if (hasValidToken) {
        print('✅ LOGIN: Found valid token - redirecting to appropriate screen');
        
        // User already has valid token, redirect based on setup status
        if (authProvider.storeData?.isSetup == true) {
          print('🏪 LOGIN: Store setup complete - going to home feed');
          AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
            Routes.routeRoot,
            (route) => false,
          );
        } else {
          print('⚙️ LOGIN: Store setup incomplete - going to setup');
          AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
            Routes.routeStoreSetup,
            (route) => false,
          );
        }
        return;
      }
      
      print('❌ LOGIN: No valid token found - showing login form');
    } catch (e) {
      print('⚠️ LOGIN: Error checking existing token: $e');
      // Continue to show login form on error
    }
    
    setState(() {
      _isCheckingExistingToken = false;
    });
  }

  void _handleLogin() async {
    // Clear any previous errors
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final storeId = _storeIdController.text.trim();
    
    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      print('🔄 LOGIN: Starting login process for store: $storeId');
      
      // Double-check if we already have a valid token for this store
      final hasExistingValidToken = await authProvider.validateStoredToken();
      
      if (!mounted) return;
      
      if (hasExistingValidToken && authProvider.storeId == storeId) {
        print('✅ LOGIN: Already authenticated for this store - redirecting');
        _redirectBasedOnSetupStatus(authProvider);
        return;
      }
      
      // Proceed with login
      final success = await authProvider.login(storeId);

      // If widget is no longer mounted, stop
      if (!mounted) return;

      if (success) {
        print('🎉 LOGIN: Login successful - redirecting user');
        _redirectBasedOnSetupStatus(authProvider);
      } else {
        // Show error from provider
        setState(() {
          _errorMessage = authProvider.error ?? 'Login failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Show error
      print('❌ LOGIN: Login error: $e');
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Redirect user based on store setup status
  void _redirectBasedOnSetupStatus(AuthProvider authProvider) {
    if (authProvider.storeData?.isSetup == true) {
      print('🏪 LOGIN: Store setup complete - going to home feed');
      // Store is set up, go to main app
      AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
        Routes.routeRoot,
        (route) => false,
      );
    } else {
      print('⚙️ LOGIN: Store setup incomplete - going to setup');
      // Store is not set up, go to store setup
      AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
        Routes.routeStoreSetup,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking for existing token
    if (_isCheckingExistingToken) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 33, 82, 155),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Checking authentication...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Please enter your store ID issued to you by Fainzy Technologies',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 26),
                            TextFormField(
                              controller: _storeIdController,
                              decoration: const InputDecoration(
                                labelText: 'Store ID',
                                hintText: 'Enter your 7-digit Store ID',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                prefixIcon: Icon(Icons.store),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Store ID';
                                }
                                // You can add more validation as needed
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              autofocus: true,
                            ),
                            const SizedBox(height: 8),
                            // Show error if exists
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 44,
                                      105, 196), // Dark blue background color
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _handleLogin,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : const Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/robos.png',
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
