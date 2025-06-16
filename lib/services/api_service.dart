import 'package:http/http.dart' as http;

class ApiService {
  Future<dynamic> getOrders() async {
    final response = await http.get(Uri.parse('https://fainzy.tech/orders'));
    return response.body;
  }
}
