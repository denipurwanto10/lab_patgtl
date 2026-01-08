import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'add_user_page.dart';
import 'bottom_nav.dart';

class ManageUsersPage extends StatefulWidget {
  final String role;

  const ManageUsersPage({super.key, required this.role});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  bool actionLoading = false;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool get isAdmin => widget.role.toLowerCase() == 'admin';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ================= FETCH USERS =================
  Future<void> fetchUsers() async {
    setState(() => loading = true);

    try {
      final result = await Auth.getUsers(isAdmin: isAdmin);
      if (result['success'] == true) {
        final usersRaw = result['users'] ?? result['data']?['users'] ?? [];
        users = usersRaw is List
            ? usersRaw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList()
            : [];
      } else {
        _showResult(success: false, message: result['message'] ?? 'Gagal mengambil data user');
      }
    } catch (e) {
      _showResult(success: false, message: 'Terjadi kesalahan koneksi: $e');
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // ================= RESET & DELETE =================
  Future<void> resetPassword(String username) async {
    setState(() => actionLoading = true);

    try {
      final result = await Auth.resetPassword(isAdmin: isAdmin, username: username);
      _showResult(
        success: result['success'] == true,
        message: result['success'] == true
            ? 'Password berhasil direset sesuai role'
            : result['message'] ?? 'Gagal reset password',
      );
    } catch (e) {
      _showResult(success: false, message: 'Terjadi kesalahan koneksi: $e');
    } finally {
      if (!mounted) return;
      setState(() => actionLoading = false);
    }
  }

  Future<void> deleteUser(String username) async {
    setState(() => actionLoading = true);

    try {
      final result = await Auth.deleteUser(isAdmin: isAdmin, username: username);
      if (result['success'] == true) await fetchUsers();
      _showResult(
        success: result['success'] == true,
        message: result['success'] == true
            ? 'User berhasil dihapus'
            : result['message'] ?? 'Gagal menghapus user',
      );
    } catch (e) {
      _showResult(success: false, message: 'Terjadi kesalahan koneksi: $e');
    } finally {
      if (!mounted) return;
      setState(() => actionLoading = false);
    }
  }

  // ================= ADD USER =================
  void onAddUser() async {
    if (!isAdmin) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddUserPage(currentUserRole: widget.role)),
    );

    if (result == true) fetchUsers();
  }

  // ================= NOTIFICATION =================
  void _showResult({required bool success, required String message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _ResultModal(success: success, message: message, isDark: isDark),
    );

    if (success) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
            onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: Text('Kelola Pengguna',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onAddUser,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Tambah User',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: loading
                    ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (context, index) => _skeletonCard(theme),
                )
                    : users.isEmpty
                    ? Center(
                  child: Text('Belum ada user',
                      style: theme.textTheme.bodyMedium),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) =>
                      _userCard(context, users[index]),
                ),
              ),
            ],
          ),
          if (actionLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child:
              const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
      bottomNavigationBar: BottomNav(activeIndex: 0, role: widget.role),
    );
  }

  // ================= SKELETON CARD =================
  Widget _skeletonCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration:
      BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 100, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Container(height: 14, width: 60, color: Colors.grey.shade300),
              ],
            ),
          ),
          Row(
            children: [
              Container(width: 36, height: 36, color: Colors.grey.shade300),
              const SizedBox(width: 8),
              Container(width: 36, height: 36, color: Colors.grey.shade300),
            ],
          ),
        ],
      ),
    );
  }

  // ================= USER CARD =================
  Widget _userCard(BuildContext context, Map<String, dynamic> user) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['username'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Role: ${user['role'] ?? '-'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          Row(
            children: [
              _actionIcon(
                  icon: Icons.refresh,
                  color: Colors.orange,
                  onTap: () => _confirmResetPassword(user['username'])),
              const SizedBox(width: 8),
              _actionIcon(
                  icon: Icons.delete,
                  color: Colors.red,
                  onTap: () => _confirmDelete(user['username'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(
      {required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration:
        BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ================= CONFIRM SHEET =================
  void _confirmResetPassword(String username) {
    _showConfirmSheet(
      icon: Icons.refresh,
      color: Colors.orange,
      title: 'Reset Password',
      description: 'Password user "$username" akan direset ke default sesuai role.',
      confirmText: 'Reset',
      onConfirm: () => resetPassword(username),
    );
  }

  void _confirmDelete(String username) {
    _showConfirmSheet(
      icon: Icons.delete_outline,
      color: Colors.red,
      title: 'Hapus User',
      description: 'User "$username" akan dihapus permanen.',
      confirmText: 'Hapus',
      onConfirm: () => deleteUser(username),
    );
  }

  void _showConfirmSheet({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient:
                LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Text('Batal',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color, color.withOpacity(0.85)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(confirmText,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== RESULT MODAL WIDGET =====================
class _ResultModal extends StatelessWidget {
  final bool success;
  final String message;
  final bool isDark;

  const _ResultModal(
      {required this.success, required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  borderRadius: BorderRadius.circular(10))),
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
                fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, height: 1.4)),
          const SizedBox(height: 28),
          // ================= BUTTON “TIDAK TERLIHAT” =================
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: success ? Colors.transparent : Colors.red,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: success ? () {} : null, // ada tapi tidak melakukan apa-apa
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
    );
  }
}
