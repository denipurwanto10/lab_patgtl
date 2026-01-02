import 'package:flutter/material.dart';
import '../bottom_nav.dart';

class ListAlatGFPage extends StatelessWidget {
  final String role;

  const ListAlatGFPage({
    super.key,
    required this.role,
  });

  bool get isAdmin => role.trim().toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'List Alat Geofisika',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ===== BUTTON TAMBAH =====
            if (isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('ADMIN: Tambah Alat GF');
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

            if (isAdmin) const SizedBox(height: 16),

            /// ===== GRID =====
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _menuItem(
                    context,
                    image: 'assets/geolistrik.png',
                    title: 'Geolistrik',
                    subtitle: 'Metode resistivitas',
                    onTap: () {},
                  ),
                  _menuItem(
                    context,
                    image: 'assets/seismik.png',
                    title: 'Seismik',
                    subtitle: 'Gelombang bumi',
                    onTap: () {},
                  ),
                  _menuItem(
                    context,
                    image: 'assets/gravity.png',
                    title: 'Gravity',
                    subtitle: 'Gaya berat',
                    onTap: () {},
                  ),
                  _menuItem(
                    context,
                    image: 'assets/elektro.png',
                    title: 'Elektromagnetik',
                    subtitle: 'Medan EM',
                    onTap: () {},
                  ),
                  _menuItem(
                    context,
                    image: 'assets/bor.png',
                    title: 'Lubang Bor',
                    subtitle: 'Data pengeboran',
                    onTap: () {},
                  ),
                  _menuItem(
                    context,
                    image: 'assets/perlengkapan.png',
                    title: 'Perlengkapan',
                    subtitle: 'Alat pendukung',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNav(
        activeIndex: 0,
        role: role,
      ),
    );
  }

  // ================= GRID ITEM =================
  Widget _menuItem(
      BuildContext context, {
        required String image,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 60, height: 60),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
