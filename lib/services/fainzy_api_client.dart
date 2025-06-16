// ignore_for_file: only_throw_errors

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:store_management_app/models/api_response.dart';

class FainzyApiClient {
  FainzyApiClient({
    http.Client? httpClient,
    this.baseUrl = 'fainzy.tech',
  }) : httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Future<ApiResponse> fetchFainzyConfig() async {
    final uri = Uri.https(
      baseUrl,
      '/v1/entities/configs/',
    );

    log('Visiting ($uri)');

    final response = await httpClient.get(
      uri,
      headers: {...headers},
    );

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchLastMileToken() async {
    final uri = Uri.https(
      baseUrl,
      '/v1/biz/product/authentication/',
      {'product': 'rds'},
    );

    log('Visiting ($uri)');

    final response = await httpClient.post(
      uri,
      headers: {...headers},
      encoding: Encoding.getByName('utf-8'),
    );
    log('fetchLastMileToken Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> authenticateStore({
    required String storeId,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/entities/store/login',
    );

    log('Visiting (${uri.toString()})');

    final body = <String, dynamic>{
      'store_id': storeId,
    };

    final response = await httpClient.post(
      uri,
      headers: {...headers, 'Store-Request': storeId},
      body: jsonEncode(body),
      encoding: Encoding.getByName('utf-8'),
    );

    log('Response (${response.body})');

    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> createMenu({
    required int subEntityId,
    required Map<String, dynamic> data,
    required String apiToken,
    int? categoryId,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/menu',
    );

    log('Visiting (${uri.toString()}) with $data');

    final response = await httpClient.post(
      uri,
      body: jsonEncode(data),
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> updateMenu({
    required int subEntityId,
    required Map<String, dynamic> data,
    required String apiToken,
    required int menuId,
    int? categoryId,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/menu/$menuId',
    );

    log('Visiting (${uri.toString()}) with $data');

    final response = await httpClient.patch(
      uri,
      body: jsonEncode(data),
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> openOrCloseStore({
    required int subEntityId,
    required bool isOpen,
    required String apiToken,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/entities/subentities/$subEntityId',
    );

    log('Visiting (${uri.toString()})');

    final response = await httpClient.patch(
      uri,
      body: jsonEncode({'status': isOpen ? 1 : 3}),
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> logoutStore({
    required int subEntityId,
    required String apiToken,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/entities/subentities/$subEntityId',
    );

    log('Visiting (${uri.toString()})');

    final response = await httpClient.patch(
      uri,
      body: jsonEncode({'status': 2}),
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> deleteMenu({
    required int subEntityId,
    required String apiToken,
    required int menuId,
    int? categoryId,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/menu/$menuId',
    );

    log('Visiting (${uri.toString()})');

    final response = await httpClient.delete(
      uri,
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchMenus({
    required int subEntityId,
    required String apiToken,
    int? categoryId,
  }) async {
    final uri = Uri.https(
        baseUrl, '/v1/core/subentities/$subEntityId/menu', <String, String>{
      if (categoryId != null) 'categoryId': '$categoryId',
    });

    log('Visiting (${uri.toString()}) with $apiToken');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> createSide({
    required int subEntityId,
    required Map<String, dynamic> data,
    required String apiToken,
    int? categoryId,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/sides',
    );

    log('Visiting (${uri.toString()}) with $data');

    final response = await httpClient.post(
      uri,
      body: jsonEncode(data),
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchSidesByMenu({
    required int subEntityId,
    required int menuId,
    required String apiToken,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/menu/$menuId/sides',
    );

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> updateSide({
    required int subEntityId,
    required int sideId,
    required Map<String, dynamic> data,
    required String apiToken,
    int? categoryId,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/sides/$sideId',
    );

    log('Visiting (${uri.toString()}) with $data');

    final response = await httpClient.patch(
      uri,
      body: jsonEncode(data),
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> deleteSide({
    required int subEntityId,
    required int sideId,
    required String apiToken,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/sides/$sideId',
    );

    log('Visiting (${uri.toString()})');

    final response = await httpClient.delete(
      uri,
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> createCategory({
    required int subEntityId,
    required Map<String, dynamic> data,
    required String apiToken,
    int? categoryId,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/categories',
    );

    log('Visiting (${uri.toString()}) with $data');

    final response = await httpClient.post(
      uri,
      body: jsonEncode(data),
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> fetchCategoriesBySubentity({
    required int subEntityId,
    required String apiToken,
  }) async {
    final uri =
        Uri.https(baseUrl, '/v1/core/subentities/$subEntityId/categories');

    log('Visiting (${uri.toString()})');

    final response = await httpClient.get(
      uri,
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> uploadImage({
    required int subentityId,
    required File image,
    required String apiToken,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.https(baseUrl, '/v1/core/subentities/$subentityId/images'),
    );

    request.files.add(await http.MultipartFile.fromPath('upload', image.path));
    request.headers.addAll({...headers, 'Authorization': 'Token $apiToken'});

    final res = await request.send();

    if (!(res.statusCode <= 201)) {
      log(res.statusCode.toString());
      throw await res.stream.bytesToString();
    }

    return ApiResponse.fromJson(json.decode(await res.stream.bytesToString()));
  }

  Future<ApiResponse> deleteImage({
    required int subEntityId,
    required int imageId,
    required String apiToken,
    int? categoryId,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/core/subentities/$subEntityId/images/$imageId',
    );

    log('Visiting (${uri.toString()})');

    final response = await httpClient.delete(
      uri,
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }

  Future<ApiResponse> updateStore({
    required int subEntityId,
    required Map<String, dynamic> store,
    required String apiToken,
  }) async {
    final uri = Uri.https(
      baseUrl,
      '/v1/entities/subentities/$subEntityId',
    );

    log('Visiting (${uri.toString()})');
    log('With (${store})');

    final response = await httpClient.patch(
      uri,
      body: jsonEncode(store),
      headers: {...headers, 'Authorization': 'Token $apiToken'},
    );
    log('Response (${response.body})');
    return ApiResponse.handleResponse(response);
  }
}
