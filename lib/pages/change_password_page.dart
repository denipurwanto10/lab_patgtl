import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'bottom_nav.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _oldVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  bool _isLoading = false;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // ======================
  // CHANGE PASSWORD
  // ======================
  Future<void> _changePassword() async {
    final oldPass = _oldController.text.trim();
    final newPass = _newController.text.trim();
    final confirmPass = _confirmController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showResult(false, 'Semua field wajib diisi');
      return;
    }

    if (newPass != confirmPass) {
      _showResult(false, 'Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        _showResult(false, 'User tidak ditemukan, silakan login ulang');
        return;
      }

      final result = await AuthService.changePassword(
        username: username,
        oldPassword: oldPass,
        newPassword: newPass,
      );

      if (result['success'] == true) {
        _showResult(true, 'Password berhasil diubah');
      } else {
        _showResult(false, result['message'] ?? 'Gagal mengubah password');
      }
    } catch (_) {
      _showResult(false, 'Terjadi kesalahan koneksi');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ======================
  // RESULT BOTTOM SHEET
  // ======================
  void _showResult(bool success, String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: !success,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 22),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: success
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: success ? Colors.green : Colors.red,
                size: 34,
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
                color: isDark ? Colors.white70 : Colors.grey,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: IgnorePointer(
                ignoring: success,
                child: Opacity(
                  opacity: success ? 0.0 : 1.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (success) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ubah Password',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Password Lama'),
                  _passwordField(
                    controller: _oldController,
                    hint: 'Masukkan password lama',
                    visible: _oldVisible,
                    onToggle: () =>
                        setState(() => _oldVisible = !_oldVisible),
                  ),
                  const SizedBox(height: 20),
                  _label('Password Baru'),
                  _passwordField(
                    controller: _newController,
                    hint: 'Masukkan password baru',
                    visible: _newVisible,
                    onToggle: () =>
                        setState(() => _newVisible = !_newVisible),
                  ),
                  const SizedBox(height: 20),
                  _label('Konfirmasi Password Baru'),
                  _passwordField(
                    controller: _confirmController,
                    hint: 'Ulangi password baru',
                    visible: _confirmVisible,
                    onToggle: () =>
                        setState(() => _confirmVisible = !_confirmVisible),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNav(
        activeIndex: 3,
        role: '',
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        filled: true,
        fillColor:
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F6F8),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility : Icons.visibility_off,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
