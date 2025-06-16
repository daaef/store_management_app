import 'lib/repositories/menu_repository.dart';
import 'lib/services/fainzy_api_client.dart';

void main() {
  final apiClient = FainzyApiClient();
  final repo = MenuRepository(apiClient);
  
  // Test that we can call the method
  repo.createMenu(
    name: "Test",
    description: "Test description",
    price: 10.0,
    categoryId: 1,
  );
}
