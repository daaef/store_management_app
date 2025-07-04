import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:store_management_app/providers/auth_provider.dart';
import 'package:store_management_app/providers/navigation_provider.dart';
import 'package:store_management_app/providers/order_provider.dart';
import 'package:store_management_app/providers/store_provider.dart';
import 'package:store_management_app/providers/menu_provider.dart';
import 'package:store_management_app/providers/store_setup_provider.dart';
import 'package:store_management_app/services/api_service.dart';
import 'package:store_management_app/services/fainzy_api_client.dart';
import 'package:store_management_app/routing/app_router.dart';
import 'package:store_management_app/screens/splash_screen.dart';
import 'package:store_management_app/helpers/notification_helper.dart';
import 'package:store_management_app/helpers/app_lifecycle_manager.dart';
import 'package:store_management_app/helpers/token_validation_helper.dart';
import 'package:store_management_app/services/currency_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize OneSignal notifications
  await NotificationHelper.initialize();
  
  // Initialize currency service
  await CurrencyService.initialize();
  
  log('🚀 Store Management App starting...');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint(details.stack.toString());
  };

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<FainzyApiClient>(
          create: (_) => FainzyApiClient(),
        ),
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        
        // Providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => StoreSetupProvider()),
      ],
      child: AppLifecycleManager(
        child: const AppWithWebsocketListener(),
      ),
    ),
  );
}

/// Wrapper widget that listens to authentication changes and initializes websocket
class AppWithWebsocketListener extends StatefulWidget {
  const AppWithWebsocketListener({super.key});

  @override
  State<AppWithWebsocketListener> createState() => _AppWithWebsocketListenerState();
}

class _AppWithWebsocketListenerState extends State<AppWithWebsocketListener> {
  @override
  void initState() {
    super.initState();
    // Set up the post-authentication callback to initialize websocket
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      // Set up callback for authentication changes
      authProvider.setPostAuthCallback((storeID) {
        if (storeID.isNotEmpty) {
          orderProvider.initializeWebsocket(storeID);
          // Start periodic token validation when user is authenticated
          TokenValidationHelper.instance.startPeriodicValidation(context);
        }
      });
      
      // Set up callback for logout to clear order data
      authProvider.setLogoutCallback(() {
        orderProvider.clearData();
        // Stop token validation when user logs out
        TokenValidationHelper.instance.stopPeriodicValidation();
      });
      
      // Initialize websocket if already authenticated
      if (authProvider.isLoggedIn && authProvider.storeID.isNotEmpty) {
        orderProvider.initializeWebsocket(authProvider.storeID);
        // Start token validation for already authenticated users
        TokenValidationHelper.instance.startPeriodicValidation(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Listen to authentication state changes
        return Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            return const StoreManagementApp();
          },
        );
      },
    );
  }
}

class StoreManagementApp extends StatelessWidget {
  const StoreManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fainzy Store Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: AppRouter.navigatorKey,
      initialRoute: '/',
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      },
    );
  }
}
