import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:store_management_app/models/api_response.dart';

class LastMileApiClient {
  LastMileApiClient({
    http.Client? httpClient,
    this.baseUrl = 'lastmile.fainzy.tech',
  }) : httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Future<ApiResponse> fetchOrders({
    required int subentityId,
    required String apiToken,
    String? filter,
  }) async {
    final uri = Uri.https(baseUrl, '/v1/core/orders/', <String, dynamic>{
      'subentity_id': '$subentityId',
    });

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Fainzy-Token': apiToken},
    );

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> updateOrder({
    required int orderId,
    required String status,
    required String apiToken,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/orders/',
      <String, dynamic>{
        'order_id': '$orderId',
      },
    );

    log('Visiting (${uri.toString()}) with status: $status');

    final response = await httpClient.patch(
      uri,
      body: jsonEncode({'status': status}),
      headers: {...headers, 'Fainzy-Token': apiToken},
    );

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchOrderById({
    required int orderId,
    required String apiToken,
  }) async {
    final uri = Uri.https(baseUrl, '/v1/core/orders/', <String, dynamic>{
      'order_id': '$orderId',
    });

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Fainzy-Token': apiToken},
    );

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchNotifications({
    required String apiToken,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/notifications/',
    );

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Fainzy-Token': apiToken},
    );

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchOrderStatistics({
    required int subEntityId,
    required String apiToken,
  }) async {
    final uri = Uri.https(baseUrl, '/v1/statistics/subentities/$subEntityId/');

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Fainzy-Token': apiToken},
    );

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchRevenueStatistics({
    required int subEntityId,
    required String apiToken,
  }) async {
    final uri =
        Uri.https(baseUrl, '/v1/statistics/subentities/$subEntityId/revenue/');

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Fainzy-Token': apiToken},
    );

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchTopCustomers({
    required int subEntityId,
    required String apiToken,
  }) async {
    final uri = Uri.https(
        baseUrl, '/v1/statistics/subentities/$subEntityId/top-customers/');

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Fainzy-Token': apiToken},
    );

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchReviews({
    required int subEntityId,
    required String apiToken,
  }) async {
    final uri =
        Uri.https(baseUrl, '/v1/core/reviews/subentities/$subEntityId/');

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Fainzy-Token': apiToken},
    );

    return ApiResponse.handleResponse(response);
  }
}
