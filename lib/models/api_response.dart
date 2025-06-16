import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiResponse {
  final String? status;
  final String? message;
  final dynamic data;
  final bool success;
  final int statusCode;
  final String? error;

  ApiResponse({
    this.status, 
    this.message, 
    this.data,
    this.success = false,
    this.statusCode = 500,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'],
      success: true,
      statusCode: 200,
    );
  }

  factory ApiResponse.success(dynamic data, {int statusCode = 200}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        log('API Success: ${response.statusCode}');
        return ApiResponse(
          status: responseBody['status'] as String?,
          message: responseBody['message'] as String?,
          data: responseBody['data'] ?? responseBody,
          success: true,
          statusCode: response.statusCode,
        );
      } else {
        // Handle different error status codes with user-friendly messages
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = _extractErrorMessage(responseBody) ?? 'Invalid request. Please check your input.';
            break;
          case 401:
            errorMessage = 'Session expired. Please login again.';
            break;
          case 403:
            errorMessage = 'Access denied. You don\'t have permission for this action.';
            break;
          case 404:
            errorMessage = 'Resource not found.';
            break;
          case 408:
            errorMessage = 'Request timeout. Please try again.';
            break;
          case 422:
            errorMessage = _extractErrorMessage(responseBody) ?? 'Validation failed. Please check your input.';
            break;
          case 429:
            errorMessage = 'Too many requests. Please wait and try again.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          case 502:
            errorMessage = 'Service temporarily unavailable.';
            break;
          case 503:
            errorMessage = 'Service unavailable. Please try again later.';
            break;
          default:
            errorMessage = _extractErrorMessage(responseBody) ?? 
                          'An error occurred. Please try again.';
        }
        
        log('API Error ${response.statusCode}: $errorMessage');
        return ApiResponse.error(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // Handle JSON parsing errors or network errors
      String errorMessage;
      if (response.statusCode == 0) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = 'Failed to process server response.';
      }
      
      log('API Error: $errorMessage - ${e.toString()}');
      return ApiResponse.error(
        errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  static String? _extractErrorMessage(Map<String, dynamic> responseBody) {
    // Try different common error message fields
    if (responseBody.containsKey('message')) {
      return responseBody['message'] as String?;
    }
    if (responseBody.containsKey('error')) {
      final error = responseBody['error'];
      if (error is String) {
        return error;
      } else if (error is Map && error.containsKey('message')) {
        return error['message'] as String?;
      }
    }
    if (responseBody.containsKey('detail')) {
      return responseBody['detail'] as String?;
    }
    if (responseBody.containsKey('errors')) {
      final errors = responseBody['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      } else if (errors is Map) {
        return errors.values.first.toString();
      }
    }
    return null;
  }
}

// Exception classes for better error handling
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode = 500});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}
