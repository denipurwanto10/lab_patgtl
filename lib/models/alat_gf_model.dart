class AlatGF {
  final int id;
  final String namaAlat;
  final String metode;
  final int jumlah;
  final String? foto;

  AlatGF({
    required this.id,
    required this.namaAlat,
    required this.metode,
    required this.jumlah,
    this.foto,
  });

  factory AlatGF.fromJson(Map<String, dynamic> json) {
    return AlatGF(
      id: json['id'] is int
          ? json['id']
          : int.parse(json['id'].toString()),

      namaAlat: json['nama_alat']?.toString() ?? '',

      // Pastikan trim untuk filter enum
      metode: json['metode']?.toString().trim() ?? '',

      jumlah: json['jumlah'] is int
          ? json['jumlah']
          : int.parse(json['jumlah'].toString()),

      // Replace backslash (\) dengan forward slash (/) untuk URL
      foto: json['foto'] != null
          ? json['foto'].toString().replaceAll('\\', '/')
          : null,
    );
  }
}
