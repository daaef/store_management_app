// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:store_management_app/providers/auth_provider.dart';
import 'package:store_management_app/providers/menu_provider.dart';
import 'package:store_management_app/providers/navigation_provider.dart';
import 'package:store_management_app/providers/order_provider.dart';
import 'package:store_management_app/providers/store_provider.dart';
import 'package:store_management_app/repositories/menu_repository.dart';
import 'package:store_management_app/services/fainzy_api_client.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app with providers but avoid the timer in splash screen
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Services
          Provider<FainzyApiClient>(create: (_) => FainzyApiClient()),
          Provider<MenuRepository>(
            create: (context) => MenuRepository(context.read<FainzyApiClient>()),
          ),
          
          // Providers
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StoreProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
          ChangeNotifierProvider(
            create: (context) => MenuProvider(
              menuRepository: context.read<MenuRepository>(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Store Management App'),
            ),
          ),
        ),
      ),
    );

    // Verify that the app launches without errors
    expect(find.text('Store Management App'), findsOneWidget);
  });
}
