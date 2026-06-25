import 'dart:convert';
import 'package:http/http.dart' as http;
import 'access_token_manager.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiMethods {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> authorizedGet(String endpoint) async {
    return _authorizedRequest(endpoint, 'GET');
  }

  static Future<Map<String, dynamic>> authorizedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _authorizedRequest(endpoint, 'POST', body: body);
  }

  static Future<Map<String, dynamic>> authorizedPut(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _authorizedRequest(endpoint, 'PUT', body: body);
  }

  static Future<Map<String, dynamic>> authorizedPatch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _authorizedRequest(endpoint, 'PATCH', body: body);
  }

  static Future<Map<String, dynamic>> authorizedDelete(String endpoint) async {
    return _authorizedRequest(endpoint, 'DELETE');
  }

  static Future<Map<String, dynamic>> unauthorizedGet(String endpoint) async {
    return _unauthorizedRequest(endpoint, 'GET');
  }

  static Future<Map<String, dynamic>> unauthorizedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _unauthorizedRequest(endpoint, 'POST', body: body);
  }

  static Future<Map<String, dynamic>> unauthorizedPut(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _unauthorizedRequest(endpoint, 'PUT', body: body);
  }

  static Future<Map<String, dynamic>> unauthorizedDelete(String endpoint) async {
    return _unauthorizedRequest(endpoint, 'DELETE');
  }

  static Future<Map<String, dynamic>> _authorizedRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    String? token = await AccessTokenManager.getValidToken();

    if (token == null) {
      throw ApiException('Auth failed', 401);
    }

    final response = await _sendRequest(
      endpoint,
      method,
      headers: _headers(token),
      body: body,
    );

    if (response.statusCode == 401) {
      final newToken = await AccessTokenManager.getValidToken();

      if (newToken == null) {
        throw ApiException('Session expired', 401);
      }

      final retry = await _sendRequest(
        endpoint,
        method,
        headers: _headers(newToken),
        body: body,
      );

      return _processResponse(retry);
    }

    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> _unauthorizedRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _sendRequest(
      endpoint,
      method,
      headers: const {'Content-Type': 'application/json'},
      body: body,
    );

    return _processResponse(response);
  }

  static Future<http.Response> _sendRequest(
    String endpoint,
    String method, {
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      switch (method) {
        case 'GET':
          return await http.get(url, headers: headers);
        case 'POST':
          return await http.post(
            url,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
        case 'PUT':
          return await http.put(
            url,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
        case 'PATCH':
          return await http.patch(
            url,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
        case 'DELETE':
          return await http.delete(url, headers: headers);
        default:
          throw ApiException('Invalid method');
      }
    } on http.ClientException {
      throw ApiException(
        'Cannot connect to API at $baseUrl. Start backend: cd backend && npm run dev',
      );
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    Map<String, dynamic>? decoded;

    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded?['message']?.toString() ??
          'Request failed (${response.statusCode})';
      throw ApiException(message, response.statusCode);
    }

    return decoded ?? {'success': true};
  }

  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}
