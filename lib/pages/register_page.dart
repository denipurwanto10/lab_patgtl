import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  // ====================== REGISTER ======================
  Future<void> _registerUser() async {
    final fullname = _fullnameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (fullname.isEmpty || username.isEmpty || password.isEmpty || role == null) {
      _showRegisterResult(success: false, message: 'Semua kolom harus diisi');
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
        _showRegisterResult(
            success: true, message: 'Registrasi berhasil!\nAkun siap digunakan.');
      } else {
        _showRegisterResult(
            success: false, message: result['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      if (!mounted) return;
      _showRegisterResult(
          success: false, message: 'Terjadi kesalahan koneksi: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ====================== MODAL REGISTER RESULT ======================
  void _showRegisterResult({required bool success, required String message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
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
              child: IgnorePointer(
                ignoring: success,
                child: Opacity(
                  opacity: success ? 0.0 : 1.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
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
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      });
    }
  }

  // ====================== UI REGISTER ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: 120),
                const SizedBox(height: 20),
                Text(
                  'Laboratorium & Sarana',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
                Text(
                  'Teknik PATGTL',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daftar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Buat akun baru', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
                      const SizedBox(height: 24),
                      _field(_textField(controller: _fullnameController, label: 'Nama Lengkap', icon: Icons.badge_outlined)),
                      _field(_textField(controller: _usernameController, label: 'Username', icon: Icons.person_outline)),
                      _field(_textField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      )),
                      _field(_dropdown()),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isLoading ? null : _registerUser,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Daftar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah punya akun? ', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text('Masuk', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================== COMPONENT TEXTFIELD ======================
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
      hint: const Text('Tipe Pengguna'),
      items: const [
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
        DropdownMenuItem(value: 'petugas', child: Text('Petugas')),
      ],
      onChanged: (value) => setState(() => _selectedRole = value),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.people_outline),
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
