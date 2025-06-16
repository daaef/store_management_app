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
  String? _errorMessage;

  @override
  void dispose() {
    _storeIdController.dispose();
    super.dispose();
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

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt login
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(_storeIdController.text.trim());

      // If widget is no longer mounted, stop
      if (!mounted) return;

      if (success) {
        // Check if store setup is completed
        if (authProvider.storeData?.isSetup == true) {
          // Store is set up, go to main app
          AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
            Routes.routeRoot,
            (route) => false,
          );
        } else {
          // Store is not set up, go to store setup
          AppRouter.navigatorKey.currentState!.pushNamedAndRemoveUntil(
            Routes.routeStoreSetup,
            (route) => false,
          );
        }
      } else {
        // Show error from provider
        setState(() {
          _errorMessage = authProvider.error ?? 'Login failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Show error
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
