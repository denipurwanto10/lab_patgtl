import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';

class BottomNav extends StatelessWidget {
  final int activeIndex;
  final String role;

  const BottomNav({
    super.key,
    required this.activeIndex,
    required this.role,
  });

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _item(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                active: activeIndex == 0,
                onTap: () => _navigate(context, HomePage()),
              ),
              _item(
                context,
                icon: Icons.access_time_rounded,
                label: 'Belum Digunakan',
                active: activeIndex == 1,
                onTap: () {},
              ),
              _item(
                context,
                icon: Icons.build_rounded,
                label: 'Perlu Pemeliharaan',
                active: activeIndex == 2,
                onTap: () {},
              ),
              _item(
                context,
                icon: Icons.person_rounded,
                label: 'Profil',
                active: activeIndex == 3,
                onTap: () => _navigate(context, const ProfilePage()),
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: active ? Colors.yellow : Colors.white,
              ),

              const SizedBox(height: 4),

              /// ===== TEXT RESPONSIVE =====
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                    active ? FontWeight.w600 : FontWeight.normal,
                    color: active ? Colors.yellow : Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              /// ===== INDICATOR =====
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 3,
                width: active ? 18 : 0,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
