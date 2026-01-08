import 'package:flutter/material.dart';
import '../../services/alatgf.dart';
import '../../models/alat_gf_model.dart';

class ListAlatKategoriPage extends StatefulWidget {
  final String kategori;

  const ListAlatKategoriPage({super.key, required this.kategori});

  @override
  State<ListAlatKategoriPage> createState() => _ListAlatKategoriPageState();
}

class _ListAlatKategoriPageState extends State<ListAlatKategoriPage> {
  late Future<List<AlatGF>> futureAlat;

  @override
  void initState() {
    super.initState();
    futureAlat = _loadAlat();
  }

  // ========================
  // Load data dari API
  // ========================
  Future<List<AlatGF>> _loadAlat() async {
    try {
      final res = await AlatGFService.getAll(metode: widget.kategori);

      print('API response: $res');

      if (res['success'] == true && res['data'] != null) {
        final List rawList = res['data'] is List ? res['data'] : [];
        final alatList = rawList
            .map((e) => AlatGF.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        for (var alat in alatList) {
          print('${alat.namaAlat} | ${alat.metode} | ${alat.foto}');
        }

        return alatList;
      } else {
        print('API response gagal atau data kosong: ${res['message']}');
        return <AlatGF>[];
      }
    } catch (e) {
      print('Error load data alat GF: $e');
      return <AlatGF>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          widget.kategori,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<AlatGF>>(
        future: futureAlat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data tidak tersedia'));
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final alat = data[index];
              return _alatCard(context, alat);
            },
          );
        },
      ),
    );
  }

  // ========================
  // Card Alat - Modern UI
  // ========================
  Widget _alatCard(BuildContext context, AlatGF alat) {
    final theme = Theme.of(context);

    String? fotoUrl = (alat.foto != null && alat.foto!.isNotEmpty)
        ? alat.foto
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // FOTO
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            child: fotoUrl != null
                ? Image.network(
              fotoUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _placeholderFoto();
              },
            )
                : _placeholderFoto(),
          ),
          const SizedBox(width: 16),
          // INFO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alat.namaAlat,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stock: ${alat.jumlah} Unit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Metode: ${alat.metode}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderFoto() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
