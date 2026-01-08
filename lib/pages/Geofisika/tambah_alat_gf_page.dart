import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/alatgf.dart'; // ⬅️ TETAP
import '../bottom_nav.dart';
import 'list_alat_gf_page.dart';

class TambahAlatGFPage extends StatefulWidget {
  final String role;

  const TambahAlatGFPage({
    super.key,
    required this.role,
  });

  @override
  State<TambahAlatGFPage> createState() => _TambahAlatGFPageState();
}

class _TambahAlatGFPageState extends State<TambahAlatGFPage> {
  final _namaController = TextEditingController();
  final _inventarisController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _perlengkapanController = TextEditingController();
  final _keteranganController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _metode;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  final metodeList = [
    'Geolistrik',
    'Seismik',
    'Gravity',
    'Elektromagnetik',
    'Lubang Bor',
    'Perlengkapan',
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _inventarisController.dispose();
    _jumlahController.dispose();
    _perlengkapanController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  // ================= SHOW ALERT =================
  void _showResult({required bool success, required String message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: !success,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: success
                      ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.05)]
                      : [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.05)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                size: 32,
                color: success ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              success ? 'Berhasil' : 'Gagal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.transparent : Colors.red,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: success ? () {} : () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: success ? Colors.transparent : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUBMIT TO BACKEND =================
  Future<void> _submit() async {
    // Validasi input wajib
    if (_namaController.text.isEmpty ||
        _inventarisController.text.isEmpty ||
        _metode == null ||
        _jumlahController.text.isEmpty) {
      _showResult(
          success: false,
          message: 'Nama, Inventaris, Metode, dan Jumlah wajib diisi');
      return;
    }

    // Validasi jumlah harus angka positif
    final jumlahValue = int.tryParse(_jumlahController.text.trim()) ?? -1;
    if (jumlahValue < 0) {
      _showResult(success: false, message: 'Jumlah harus angka positif');
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      // Encode gambar jika ada
      String base64Image = '';
      if (_image != null) {
        base64Image = base64Encode(await _image!.readAsBytes());
      }

      // Tentukan metode
      final metodeValue = _metode == 'Perlengkapan'
          ? _perlengkapanController.text.trim()
          : _metode!.trim();

      final data = {
        'nama_alat': _namaController.text.trim(),
        'no_inventaris': _inventarisController.text.trim(),
        'metode': metodeValue,
        'jumlah': jumlahValue,
        'perlengkapan': _perlengkapanController.text.trim(),
        'keterangan': _keteranganController.text.trim(),
        'foto': base64Image,
      };

      // Kirim data ke backend
      final res = await AlatGFService.add(data).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception("Request timeout, periksa koneksi internet");
        },
      );

      if (res['success'] == true && mounted) {
        // Tampilkan bottom sheet sukses
        _showResult(success: true, message: res['message'] ?? 'Data berhasil disimpan');

        // Tunggu 1 detik agar user bisa lihat pesan sukses
        await Future.delayed(const Duration(seconds: 1));

        // Clear semua field
        _namaController.clear();
        _inventarisController.clear();
        _jumlahController.clear();
        _perlengkapanController.clear();
        _keteranganController.clear();
        setState(() {
          _metode = null;
          _image = null;
        });

        // Redirect ke ListAlatGFPage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ListAlatGFPage(role: widget.role),
            ),
          );
        }
      } else {
        _showResult(success: false, message: res['message'] ?? 'Gagal menyimpan data');
      }
    } catch (e) {
      if (mounted) _showResult(success: false, message: 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _imagePicker(),
                const SizedBox(height: 28),
                _field(_textField(
                  controller: _namaController,
                  label: 'Nama Alat',
                  icon: Icons.handyman_outlined,
                )),
                _field(_textField(
                  controller: _inventarisController,
                  label: 'No. Inventaris',
                  icon: Icons.qr_code_2_rounded,
                )),
                _field(_dropdown()),
                _field(_textField(
                  controller: _jumlahController,
                  label: 'Jumlah',
                  icon: Icons.numbers_outlined,
                  keyboardType: TextInputType.number,
                )),
                _field(_textArea(
                  controller: _perlengkapanController,
                  label: 'Perlengkapan',
                  icon: Icons.inventory_2_outlined,
                )),
                _field(_textArea(
                  controller: _keteranganController,
                  label: 'Keterangan',
                  icon: Icons.notes_outlined,
                )),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isLoading ? null : _submit,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2E7D32),
                            Color(0xFF1B5E20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(activeIndex: 0, role: widget.role),
    );
  }

  // ================= UI COMPONENT =================
  Widget _field(Widget child) =>
      Padding(padding: const EdgeInsets.only(bottom: 18), child: child);

  Widget _imagePicker() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB),
        ),
        child: _image == null
            ? const Center(
          child: Text(
            'Ketuk untuk menambahkan gambar',
            style: TextStyle(color: Colors.grey),
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(_image!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _decoration(label, icon),
    );
  }

  Widget _textArea({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: _decoration(label, icon),
    );
  }

  Widget _dropdown() {
    return DropdownButtonFormField<String>(
      value: _metode,
      isExpanded: true,
      items: metodeList
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => _metode = v),
      decoration: _decoration('Metode / Perlengkapan', Icons.science_outlined),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFDFDFD),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
        BorderSide(color: theme.colorScheme.primary, width: 1.6),
      ),
    );
  }
}
