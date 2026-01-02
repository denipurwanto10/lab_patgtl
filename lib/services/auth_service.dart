import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.53.193.202:3000/api/auth';

  // ================= HEADER =================
  static Map<String, String> _headers() {
    return const {
      'Content-Type': 'application/json',
    };
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers(),
        body: jsonEncode({'username': username, 'password': password}),
      );
      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String role, // 'admin' atau 'petugas'
  }) async {
    if (role != 'admin' && role != 'petugas') {
      return {
        'success': false,
        'message': "Role tidak valid. Harus 'admin' atau 'petugas'.",
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  // ================= CHANGE PASSWORD =================
  static Future<Map<String, dynamic>> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: _headers(),
        body: jsonEncode({
          'username': username,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e);
    }
  }

// ================= GET USERS =================
  static Future<Map<String, dynamic>> getUsers({required String role}) async {
    if (role.toLowerCase() != 'admin') {
      return {
        'success': false,
        'message': 'Akses ditolak. Hanya admin dapat melihat daftar user.',
      };
    }

    try {
      // Panggil endpoint root karena backend kamu GET '/' yang return users
      final response = await http.get(
        Uri.parse('$baseUrl'), // <- jangan tambah /users
        headers: _headers(),
      );

      // Cek kalau response bukan JSON (misal HTML)
      if (!response.headers['content-type']!.contains('application/json')) {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': 'Response dari server bukan JSON, mungkin salah endpoint',
          'data': {},
        };
      }

      final result = _handleResponse(response);

      // Ambil users dari backend
      if (result['success'] == true && result['data'] != null) {
        final usersRaw = result['data']['users'] ?? [];
        final usersList = <Map<String, dynamic>>[];
        if (usersRaw is List) {
          for (var u in usersRaw) {
            if (u is Map) {
              usersList.add(Map<String, dynamic>.from(u));
            }
          }
        }
        result['data'] = {'users': usersList};
      }

      return result;
    } catch (e) {
      return _errorResponse(e);
    }
  }


  // ================= RESET PASSWORD =================
  static Future<Map<String, dynamic>> resetPassword({
    required String adminRole,
    required String username,
  }) async {
    if (adminRole.toLowerCase() != 'admin') {
      return {
        'success': false,
        'message': 'Akses ditolak. Hanya admin dapat mereset password.',
      };
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reset-password/$username'),
        headers: _headers(),
      );

      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  // ================= DELETE USER =================
  static Future<Map<String, dynamic>> deleteUser({
    required String adminRole,
    required String username,
  }) async {
    if (adminRole.toLowerCase() != 'admin') {
      return {
        'success': false,
        'message': 'Akses ditolak. Hanya admin dapat menghapus user.',
      };
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$username'),
        headers: _headers(),
      );

      return _handleResponse(response);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  // ================= RESPONSE HANDLER =================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Response kosong dari server',
      };
    }

    try {
      final decoded = jsonDecode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': decoded,
        'message': decoded is Map && decoded['message'] != null
            ? decoded['message']
            : 'OK',
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Response tidak valid: ${e.toString()}',
      };
    }
  }

  // ================= ERROR HANDLER =================
  static Map<String, dynamic> _errorResponse(dynamic error) {
    return {
      'success': false,
      'statusCode': 500,
      'message': 'Terjadi kesalahan: ${error.toString()}',
    };
  }
}
