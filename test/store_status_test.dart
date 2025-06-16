import 'package:flutter_test/flutter_test.dart';
import 'package:store_management_app/providers/store_provider.dart';

void main() {
  group('StoreStatus Tests', () {
    test('StoreStatus mapping works correctly', () {
      // Test numeric values mapping
      expect(StoreStatus.fromValue(1).isOpen, true);
      expect(StoreStatus.fromValue(2).isLoggedOut, true);
      expect(StoreStatus.fromValue(3).isClosed, true);
      
      // Test default values
      expect(StoreStatus.opened, 1);
      expect(StoreStatus.loggedOut, 2);
      expect(StoreStatus.closed, 3);
      
      // Test helper methods
      expect(StoreStatus.open.isOpen, true);
      expect(StoreStatus.open.isLoggedOut, false);
      expect(StoreStatus.open.isClosed, false);
      
      expect(StoreStatus.logout.isOpen, false);
      expect(StoreStatus.logout.isLoggedOut, true);
      expect(StoreStatus.logout.isClosed, false);
      
      expect(StoreStatus.close.isOpen, false);
      expect(StoreStatus.close.isLoggedOut, false);
      expect(StoreStatus.close.isClosed, true);
    });
    
    test('Invalid StoreStatus value defaults to closed', () {
      final invalidStatus = StoreStatus.fromValue(999);
      expect(invalidStatus.isClosed, true);
      expect(invalidStatus.value, 3);
    });
  });
}
