// lib/pages/Geofisika/geofisika_page.dart
import 'package:flutter/material.dart';
import '../bottom_nav.dart';
import 'list_alat_gf_page.dart';

class GeofisikaPage extends StatelessWidget {
  final String role;

  const GeofisikaPage({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              /// HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset('assets/logo.png'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laboratorium',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Geofisika',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              /// TITLE
              Text(
                'Dashboard',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// DASHBOARD MENU
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _menuCard(
                            context,
                            title: 'List Alat',
                            subtitle: 'Data inventaris',
                            image: 'assets/inventory.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ListAlatGFPage(role: role),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          _menuCard(
                            context,
                            title: 'Pinjam Alat',
                            subtitle: 'Peminjaman',
                            image: 'assets/handshake.png',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _menuCard(
                            context,
                            title: 'Status Alat',
                            subtitle: 'Proses & kondisi',
                            image: 'assets/loading-bar.png',
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _menuCard(
                            context,
                            title: 'Log Aktivitas',
                            subtitle: 'Riwayat penggunaan',
                            image: 'assets/file.png',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _menuCard(
                            context,
                            title: 'Pemeliharaan',
                            subtitle: 'Maintenance',
                            image: 'assets/optimizing.png',
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _menuCard(
                            context,
                            title: 'Pencarian',
                            subtitle: 'Pencarian Alat',
                            image: 'assets/search.png',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomNav(
        activeIndex: 0,
        role: role,
      ),
    );
  }

  /// MENU CARD (SEMUA UKURAN SAMA)
  Widget _menuCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String image,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 170,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
