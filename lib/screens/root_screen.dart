import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../screens/home_feed_screen.dart';
import '../screens/order_management_screen.dart';
import '../screens/menu_screen_beautiful.dart';
import '../screens/profile_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NavigationProvider(),
      child: const _RootView(),
    );
  }
}

class _RootView extends StatelessWidget {
  const _RootView();

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    final destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: Text('Orders'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.restaurant_menu_outlined),
        selectedIcon: Icon(Icons.restaurant_menu),
        label: Text('Menu'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.more_horiz_outlined),
        selectedIcon: Icon(Icons.more_horiz),
        label: Text('More'),
      ),
    ];

    final pages = [
      const HomeFeedScreen(),
      const OrderManagementScreen(),
      const MenuScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          final shouldPop = await navigationProvider.onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                destinations: destinations,
                selectedIndex: navigationProvider.currentPageIndex,
                onDestinationSelected: navigationProvider.onPageChanged,
                labelType: NavigationRailLabelType.all,
                useIndicator: true,
                indicatorColor: Colors.blue.withOpacity(0.2),
                backgroundColor: const Color.fromARGB(255, 44, 105, 196),
                selectedIconTheme: const IconThemeData(
                  color: Colors.white,
                  size: 24,
                ),
                unselectedIconTheme: IconThemeData(
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: navigationProvider.currentPageIndex,
                  children: pages,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
