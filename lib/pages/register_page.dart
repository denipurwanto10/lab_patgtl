import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedRole;
  bool _isLoading = false;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ======================
  // REGISTER
  // ======================
  Future<void> _registerUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (username.isEmpty || password.isEmpty || role == null) {
      _showRegisterResult(
        success: false,
        message: 'Semua kolom harus diisi',
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      username: username,
      password: password,
      role: role,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showRegisterResult(
        success: true,
        message: 'Registrasi berhasil!\nAkun siap digunakan.',
      );
    } else {
      _showRegisterResult(
        success: false,
        message: result['message'] ?? 'Registrasi gagal',
      );
    }
  }

  // ======================
  // MODERN REGISTER RESULT
  // ======================
  void _showRegisterResult({
    required bool success,
    required String message,
  }) {
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
                      ? [
                    Colors.green.withOpacity(0.2),
                    Colors.green.withOpacity(0.05),
                  ]
                      : [
                    Colors.red.withOpacity(0.2),
                    Colors.red.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
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
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pop(context);
                  if (success) Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: success
                        ? const LinearGradient(
                      colors: [
                        Color(0xFF2E7D32),
                        Color(0xFF1B5E20),
                      ],
                    )
                        : const LinearGradient(
                      colors: [
                        Color(0xFFD32F2F),
                        Color(0xFFB71C1C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (success ? Colors.green : Colors.red)
                            .withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    success ? 'OK' : 'Tutup',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // UI REGISTER
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),
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
                      Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buat akun baru',
                        style: TextStyle(
                          color:
                          isDark ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildInput(
                        controller: _usernameController,
                        hint: 'Username',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      _buildInput(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        hint: Text(
                          'Tipe Pengguna',
                          style: TextStyle(
                            color:
                            isDark ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'petugas',
                            child: Text('Petugas'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedRole = value),
                        decoration: _dropdownDecoration(
                          prefix: const Icon(Icons.people_outline),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed:
                          _isLoading ? null : _registerUser,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            'Daftar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey,
        ),
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor:
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration({Widget? prefix}) {
    return InputDecoration(
      prefixIcon: prefix,
      filled: true,
      fillColor:
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
