import 'api_service.dart';

class AlatGFService {
  // Base URL server (sesuaikan dengan backend)
  static const String baseUrl = 'http://10.141.100.238:3000/';

  // ============================
  // GET ALL ALAT (Bisa filter kategori/metode)
  // ============================
  static Future<Map<String, dynamic>> getAll({String? metode}) async {
    try {
      // Endpoint dengan query parameter jika ada metode
      final endpoint = metode != null
          ? 'alat_gf?metode=${Uri.encodeComponent(metode)}'
          : 'alat_gf';

      final response = await ApiService.request(endpoint);

      // Perbaikan: ambil list dari response['data']['data']
      final rawData = response['data']?['data'];
      final List<Map<String, dynamic>> list = [];

      if (rawData is List) {
        for (var item in rawData) {
          final Map<String, dynamic> mapItem = Map<String, dynamic>.from(item);

          // Ubah path foto menjadi full URL
          if (mapItem['foto'] != null && mapItem['foto'].toString().isNotEmpty) {
            final fotoPath = mapItem['foto'].toString().replaceAll('\\', '/');
            mapItem['foto'] =
            fotoPath.startsWith('http') ? fotoPath : '$baseUrl$fotoPath';
          }

          list.add(mapItem);
        }
      }

      return {
        'success': response['success'] ?? false,
        'data': list,
        'message': response['data']?['message'] ?? 'Berhasil mengambil data',
      };
    } catch (e) {
      return {
        'success': false,
        'data': <Map<String, dynamic>>[],
        'message': 'Gagal mengambil data: $e',
      };
    }
  }

  // ============================
  // ADD ALAT (JSON + BASE64 FOTO)
  // ============================
  static Future<Map<String, dynamic>> add(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.request(
        'alat_gf/add',
        method: 'POST',
        body: data,
      );

      return {
        'success': response['success'] ?? false,
        'data': response['data'] ?? {},
        'message': response['data']?['message'] ?? 'Gagal menambahkan alat',
      };
    } catch (e) {
      return {
        'success': false,
        'data': {},
        'message': 'Error saat menambah alat: $e',
      };
    }
  }

  // ============================
  // UPDATE ALAT
  // ============================
  static Future<Map<String, dynamic>> update({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await ApiService.request(
        'alat_gf/$id',
        method: 'PUT',
        body: data,
      );

      return {
        'success': response['success'] ?? false,
        'data': response['data'] ?? {},
        'message': response['data']?['message'] ?? 'Gagal mengupdate alat',
      };
    } catch (e) {
      return {
        'success': false,
        'data': {},
        'message': 'Error saat update alat: $e',
      };
    }
  }

  // ============================
  // DELETE ALAT
  // ============================
  static Future<Map<String, dynamic>> delete(int id) async {
    try {
      final response = await ApiService.request(
        'alat_gf/$id',
        method: 'DELETE',
      );

      return {
        'success': response['success'] ?? false,
        'data': response['data'] ?? {},
        'message': response['data']?['message'] ?? 'Gagal menghapus alat',
      };
    } catch (e) {
      return {
        'success': false,
        'data': {},
        'message': 'Error saat hapus alat: $e',
      };
    }
  }
}
