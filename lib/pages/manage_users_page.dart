import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => loading = true);

    final result = await AuthService.getUsers(role: widget.role);

    if (result['success'] == true && result['data'] != null) {
      final usersRaw = result['data']['users'] ?? [];
      users = usersRaw is List
          ? usersRaw.map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e)).toList()
          : [];
    } else {
      showModernSnack(
        message: result['message'] ?? 'Gagal mengambil data user',
        type: SnackType.error,
      );
    }

    setState(() => loading = false);
  }

  Future<void> resetPassword(String username) async {
    setState(() => actionLoading = true);

    final result = await AuthService.resetPassword(
      adminRole: widget.role,
      username: username,
    );

    showModernSnack(
      message: result['success'] == true
          ? 'Password berhasil direset'
          : result['message'] ?? 'Gagal reset password',
      type: result['success'] == true
          ? SnackType.success
          : SnackType.error,
    );

    setState(() => actionLoading = false);
  }

  Future<void> deleteUser(String username) async {
    setState(() => actionLoading = true);

    final result = await AuthService.deleteUser(
      adminRole: widget.role,
      username: username,
    );

    if (result['success'] == true) {
      showModernSnack(
        message: 'User berhasil dihapus',
        type: SnackType.success,
      );
      fetchUsers();
    } else {
      showModernSnack(
        message: result['message'] ?? 'Gagal menghapus user',
        type: SnackType.error,
      );
    }

    setState(() => actionLoading = false);
  }

  void onAddUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddUserPage()),
    );

    if (result == true) fetchUsers();
  }

  bool get isAdmin => widget.role.toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Kelola Pengguna',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onAddUser,
                        icon: const Icon(Icons.person_add),
                        label: const Text(
                          'Tambah User',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : users.isEmpty
                    ? Center(
                  child: Text(
                    'Belum ada user',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _userCard(context, users[index]);
                  },
                ),
              ),
            ],
          ),

          if (actionLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),

      bottomNavigationBar: BottomNav(
        activeIndex: 0,
        role: widget.role,
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
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'] ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: ${user['role'] ?? '-'}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _actionIcon(
                icon: Icons.refresh,
                color: Colors.orange,
                onTap: () => _confirmResetPassword(user['username']),
              ),
              const SizedBox(width: 8),
              _actionIcon(
                icon: Icons.delete,
                color: Colors.red,
                onTap: () => _confirmDelete(user['username']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ================= CONFIRM SHEET =================
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
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(32)),
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
            const SizedBox(height: 20),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.85)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  void _confirmResetPassword(String username) {
    _showConfirmSheet(
      icon: Icons.refresh,
      color: Colors.orange,
      title: 'Reset Password',
      description:
      'Password user "$username" akan direset ke default.',
      confirmText: 'Reset',
      onConfirm: () => resetPassword(username),
    );
  }

  void _confirmDelete(String username) {
    _showConfirmSheet(
      icon: Icons.delete_outline,
      color: Colors.red,
      title: 'Hapus User',
      description:
      'User "$username" akan dihapus permanen.',
      confirmText: 'Hapus',
      onConfirm: () => deleteUser(username),
    );
  }

  // ================= SNACKBAR =================
  void showModernSnack({
    required String message,
    required SnackType type,
  }) {
    final color =
    type == SnackType.success ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).cardColor,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Icon(
              type == SnackType.success
                  ? Icons.check_circle
                  : Icons.error,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SnackType { success, error }
