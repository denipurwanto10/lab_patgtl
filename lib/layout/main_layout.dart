import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(
                context,
                icon: Icons.home,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => _go(context, 0),
              ),
              _item(
                context,
                icon: Icons.access_time,
                label: 'Belum\nDigunakan',
                active: currentIndex == 1,
                onTap: () => _go(context, 1),
              ),
              _item(
                context,
                icon: Icons.build,
                label: 'Perlu\nPemeliharaan',
                active: currentIndex == 2,
                onTap: () => _go(context, 2),
              ),
              _item(
                context,
                icon: Icons.person,
                label: 'Profil',
                active: currentIndex == 3,
                onTap: () => _go(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool active,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.yellow : Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.yellow : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, int index) {
    // routing nanti
  }
}
