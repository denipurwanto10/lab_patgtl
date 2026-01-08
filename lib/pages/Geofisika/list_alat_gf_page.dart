import 'package:flutter/material.dart';
import 'package:lab_patgtl/pages/Geofisika/tambah_alat_gf_page.dart';
import 'package:lab_patgtl/pages/Geofisika/list_alat_kategori_page.dart';
import '../bottom_nav.dart';
import '../../services/alatgf.dart';
import '../../models/alat_gf_model.dart';

class ListAlatGFPage extends StatelessWidget {
  final String role;

  const ListAlatGFPage({super.key, required this.role});

  // Cek apakah user admin
  bool get isAdmin => role.trim().toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ===== Menu Items =====
    final List<_MenuItemData> menuItems = [
      _MenuItemData(
        image: 'assets/geolistrik.png',
        title: 'Geolistrik',
        subtitle: 'Metode resistivitas',
      ),
      _MenuItemData(
        image: 'assets/seismik.png',
        title: 'Seismik',
        subtitle: 'Gelombang bumi',
      ),
      _MenuItemData(
        image: 'assets/gravity.png',
        title: 'Gravity',
        subtitle: 'Gaya berat',
      ),
      _MenuItemData(
        image: 'assets/elektro.png',
        title: 'Elektromagnetik',
        subtitle: 'Medan EM',
      ),
      _MenuItemData(
        image: 'assets/bor.png',
        title: 'Lubang Bor',
        subtitle: 'Data pengeboran',
      ),
      _MenuItemData(
        image: 'assets/perlengkapan.png',
        title: 'Perlengkapan',
        subtitle: 'Alat pendukung',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'List Alat Geofisika',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== Tombol Tambah untuk Admin =====
            if (isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _elevatedButton(
                    context,
                    icon: Icons.add,
                    label: 'Tambah',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TambahAlatGFPage(role: role),
                        ),
                      );
                    },
                  ),
                ],
              ),
            if (isAdmin) const SizedBox(height: 16),

            // ===== Grid Menu =====
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 170,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return _menuItem(
                    context,
                    image: item.image,
                    title: item.title,
                    subtitle: item.subtitle,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        activeIndex: 0,
        role: role,
      ),
    );
  }

  // ===== Menu Item Widget =====
  Widget _menuItem(
      BuildContext context, {
        required String image,
        required String title,
        required String subtitle,
      }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        // Navigasi ke halaman kategori sesuai metode
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListAlatKategoriPage(
              kategori: title,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 52, height: 52),
            const SizedBox(height: 14),
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
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Elevated Button Widget =====
  Widget _elevatedButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Model Menu Item Internal =====
class _MenuItemData {
  final String image;
  final String title;
  final String subtitle;

  _MenuItemData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
