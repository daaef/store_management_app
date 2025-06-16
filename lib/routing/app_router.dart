import 'package:flutter/material.dart';
import 'package:store_management_app/screens/login_screen.dart';
import 'package:store_management_app/screens/onboarding_screen.dart';
import 'package:store_management_app/screens/splash_screen.dart';
import 'package:store_management_app/screens/root_screen.dart';
import 'package:store_management_app/screens/store_setup_screen.dart';
import 'package:store_management_app/screens/store_settings_screen.dart';
import 'package:store_management_app/screens/order_details_screen.dart';
import 'package:store_management_app/screens/order_management_screen.dart';
import 'package:store_management_app/routing/routes.dart';

class AppRouter {
  AppRouter._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.routeSplash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.routeOnboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Routes.routeLogin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.routeStoreSetup:
        return MaterialPageRoute(builder: (_) => const StoreSetupScreen());
      case Routes.routeStoreSettings:
        return MaterialPageRoute(builder: (_) => const StoreSettingsScreen());
      case Routes.routeRoot:
        return MaterialPageRoute(builder: (_) => const RootScreen());
      case Routes.routeOrderManagement:
        return OrderManagementScreen.route();
      case Routes.routeOrderDetails:
        final orderId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(orderId: orderId ?? 0),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Unknown route: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
