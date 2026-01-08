import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.141.100.238:3000/api';

  static Map<String, String> headers({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ================= JSON REQUEST =================
  static Future<Map<String, dynamic>> request(
      String endpoint, {
        String method = 'GET',
        Map<String, dynamic>? body,
        String? token,
      }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            url,
            headers: headers(token: token),
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers(token: token),
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers(token: token));
          break;
        default:
          response = await http.get(url, headers: headers(token: token));
      }

      final decoded =
      response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': decoded,
        'message': decoded['message'] ?? 'OK',
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {},
        'message': e.toString(),
      };
    }
  }

  // ================= MULTIPART (UPLOAD FOTO) =================
  static Future<Map<String, dynamic>> multipart(
      String endpoint, {
        required Map<String, String> fields,
        File? file,
        String fileField = 'foto',
        String method = 'POST',
        String? token,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final request = http.MultipartRequest(method, uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final decoded =
      response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': decoded,
        'message': decoded['message'] ?? 'OK',
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {},
        'message': e.toString(),
      };
    }
  }
}
