import 'dart:convert';
import 'api_service.dart';

class Auth {
  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final result = await ApiService.request(
        'auth/login',
        method: 'POST',
        body: {'username': username, 'password': password},
      );

      final Map<String, dynamic> data = _toMap(result);
      if (!data.containsKey('success')) data['success'] = true;
      if (!data.containsKey('message')) data['message'] = '';
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register({
    required String username,
    required String fullname,
    required String password,
    required String role,
  }) async {
    try {
      final result = await ApiService.request(
        'auth/register',
        method: 'POST',
        body: {
          'username': username,
          'fullname': fullname,
          'password': password,
          'role': role
        },
      );

      final Map<String, dynamic> data = _toMap(result);
      if (!data.containsKey('success')) data['success'] = true;
      if (!data.containsKey('message')) data['message'] = '';
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ================= CHANGE PASSWORD =================
  static Future<Map<String, dynamic>> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final result = await ApiService.request(
        'auth/change-password',
        method: 'PUT',
        body: {
          'username': username,
          'oldPassword': oldPassword,
          'newPassword': newPassword
        },
      );

      final Map<String, dynamic> data = _toMap(result);
      if (!data.containsKey('success')) data['success'] = true;
      if (!data.containsKey('message')) data['message'] = '';
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ================= GET USERS =================
  static Future<Map<String, dynamic>> getUsers({required bool isAdmin}) async {
    if (!isAdmin) return {'success': false, 'message': 'Hanya admin'};

    try {
      final result = await ApiService.request('auth');
      final Map<String, dynamic> data = _toMap(result);
      if (!data.containsKey('success')) data['success'] = true;
      if (!data.containsKey('message')) data['message'] = '';
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ================= RESET PASSWORD =================
  static Future<Map<String, dynamic>> resetPassword({
    required bool isAdmin,
    required String username,
  }) async {
    if (!isAdmin) return {'success': false, 'message': 'Hanya admin'};

    try {
      final result = await ApiService.request(
        'auth/reset-password/$username',
        method: 'PUT',
      );
      final Map<String, dynamic> data = _toMap(result);

      // Jika backend tidak mengirim success, set default true
      if (!data.containsKey('success')) data['success'] = true;

      // Jika backend tidak mengirim message, set default sesuai username
      if (!data.containsKey('message')) {
        data['message'] = 'Password user "$username" berhasil direset';
      }

      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ================= DELETE USER =================
  static Future<Map<String, dynamic>> deleteUser({
    required bool isAdmin,
    required String username,
  }) async {
    if (!isAdmin) return {'success': false, 'message': 'Hanya admin'};

    try {
      final result = await ApiService.request(
        'auth/$username',
        method: 'DELETE',
      );
      final Map<String, dynamic> data = _toMap(result);
      if (!data.containsKey('success')) data['success'] = true;
      if (!data.containsKey('message')) data['message'] = 'User "$username" berhasil dihapus';
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== HELPER ===================
  static Map<String, dynamic> _toMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    try {
      final decoded = jsonDecode(response.toString()) as Map<String, dynamic>;
      return decoded;
    } catch (_) {
      return {'success': false, 'message': response?.toString() ?? 'Tidak diketahui'};
    }
  }
}
