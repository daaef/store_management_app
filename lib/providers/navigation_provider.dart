import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentPageIndex = 0;

  int get currentPageIndex => _currentPageIndex;

  void onPageChanged(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }

  // Navigation keys for each tab
  final List<GlobalKey<NavigatorState>> navigators = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Handle back button press
  Future<bool> onWillPop() async {
    final navigator = navigators[_currentPageIndex].currentState;
    if (navigator != null && await navigator.maybePop()) {
      return false;
    }
    return true;
  }
}
