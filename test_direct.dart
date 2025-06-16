import 'lib/utils/extensions.dart';

void main() {
  // Test directly calling the extension
  double testValue = 2500.0;
  try {
    String result = testValue.formatAmount();
    print('Success: $result');
  } catch (e) {
    print('Error: $e');
  }
}
