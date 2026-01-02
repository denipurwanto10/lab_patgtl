import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedRole;
  bool _isLoading = false;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (username.isEmpty || password.isEmpty || role == null) {
      _showSnackBar('Semua kolom harus diisi', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.register(
        username: username,
        password: password,
        role: role,
      );

      if (result['success'] == true) {
        _showSnackBar('Pengguna berhasil ditambahkan', Colors.green);
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pop(context, true);
        });
      } else {
        _showSnackBar(result['message'] ?? 'Terjadi kesalahan', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
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
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Tambah Pengguna',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ================= FORM CARD =================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// USERNAME
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: _inputDecoration(
                        label: 'Username',
                        hint: 'Masukkan username',
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 18),

                    /// PASSWORD
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: _inputDecoration(
                        label: 'Password',
                        hint: 'Masukkan password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    /// ROLE
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      dropdownColor:
                      isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                      onChanged: (value) {
                        setState(() => _selectedRole = value);
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: _inputDecoration(
                        label: 'Role',
                        hint: 'Pilih role pengguna',
                        icon: Icons.groups_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INPUT DECORATION =================
  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor:
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F6),
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : Colors.black87,
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 14,
      ),
    );
  }
}
