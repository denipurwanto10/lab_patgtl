import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'manage_users_page.dart';

class AddUserPage extends StatefulWidget {
  final String currentUserRole;

  const AddUserPage({super.key, required this.currentUserRole});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedRole;
  bool _isLoading = false;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    final fullname = _fullnameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (fullname.isEmpty || username.isEmpty || password.isEmpty || role == null) {
      _showResult(success: false, message: 'Semua kolom harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await Auth.register(
        fullname: fullname,
        username: username,
        password: password,
        role: role,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Tampilkan BottomSheet sukses dengan struktur button sama, tapi otomatis navigasi
        _showResult(success: true, message: 'Pengguna berhasil ditambahkan');

        // Otomatis pindah halaman setelah 1 detik
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ManageUsersPage(role: widget.currentUserRole),
          ),
        );
      } else {
        _showResult(success: false, message: result['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      if (!mounted) return;
      _showResult(success: false, message: 'Terjadi kesalahan koneksi');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showResult({required bool success, required String message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: !success, // kalau sukses, tidak bisa dismiss
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
                onPressed: success ? () {} : () => Navigator.pop(context), // tombol ada tapi tidak melakukan apa-apa kalau sukses
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: success ? Colors.transparent : Colors.white, // tetap “tidak terlihat” tapi layout ada
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _field(_textField(
                      controller: _fullnameController,
                      label: 'Nama Lengkap',
                      icon: Icons.badge_outlined,
                    )),
                    _field(_textField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.person_outline,
                    )),
                    _field(_textField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    )),
                    _field(_dropdown()),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(Widget child) => Padding(padding: const EdgeInsets.only(bottom: 18), child: child);

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFDFDFD),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.6),
        ),
      ),
    );
  }

  Widget _dropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      hint: const Text('Pilih Role'),
      items: const [
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
        DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
      ],
      onChanged: (value) => setState(() => _selectedRole = value),
      decoration: InputDecoration(
        labelText: 'Role',
        prefixIcon: const Icon(Icons.groups_outlined),
        filled: true,
        fillColor: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFDFDFD),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.6),
        ),
      ),
    );
  }
}
