import 'package:flutter_test/flutter_test.dart';
import 'package:store_management_app/providers/auth_provider.dart';
import 'package:store_management_app/providers/store_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('StoreStatus Tests', () {
    test('StoreStatus mapping works correctly', () {
      // Test numeric values mapping
      expect(StoreStatus.fromValue(1).isOpen, true);
      expect(StoreStatus.fromValue(1).isLoggedOut, false);
      expect(StoreStatus.fromValue(1).isClosed, false);
      
      expect(StoreStatus.fromValue(2).isOpen, false);
      expect(StoreStatus.fromValue(2).isLoggedOut, true);
      expect(StoreStatus.fromValue(2).isClosed, false);
      
      expect(StoreStatus.fromValue(3).isOpen, false);
      expect(StoreStatus.fromValue(3).isLoggedOut, false);
      expect(StoreStatus.fromValue(3).isClosed, true);
      
      // Test default values
      expect(StoreStatus.open.value, 1);
      expect(StoreStatus.logout.value, 2);
      expect(StoreStatus.close.value, 3);
      
      // Test invalid values default to closed
      expect(StoreStatus.fromValue(999).isClosed, true);
      expect(StoreStatus.fromValue(0).isClosed, true);
    });
    
    test('StoreStatus constants are correct', () {
      expect(StoreStatus.opened, 1);
      expect(StoreStatus.loggedOut, 2);
      expect(StoreStatus.closed, 3);
    });
  });

  group('AuthProvider Tests', () {
    test('AuthProvider initializes correctly', () {
      final authProvider = AuthProvider();
      expect(authProvider.authState, AuthState.initial);
      expect(authProvider.storeId, '');
      expect(authProvider.storeID, '');
      expect(authProvider.token, '');
      expect(authProvider.storeData, null);
    });
    
    test('Logout clears all data', () async {
      final authProvider = AuthProvider();
      
      // Test logout functionality
      await authProvider.logout();
      
      expect(authProvider.authState, AuthState.unauthenticated);
      expect(authProvider.storeId, '');
      expect(authProvider.storeID, '');
      expect(authProvider.token, '');
      expect(authProvider.storeData, null);
    });
  });
}
