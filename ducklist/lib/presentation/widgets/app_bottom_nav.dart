import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddPressed;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: theme.brightness == Brightness.light ? Colors.white : theme.colorScheme.surface,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(Icons.home_filled, "Home", 0, theme),
            _item(Icons.calendar_today, "Plan", 1, theme),
            
            // TOMBOL TENGAH: Dibungkus Material agar tidak error
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddPressed,
                child: const SizedBox(width: 48, height: 48),
              ),
            ),
            
            // Diubah dari Shop ke Progress
            _item(Icons.bar_chart_rounded, "Progress", 2, theme),
            _item(Icons.person_outline, "Me", 3, theme),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, int index, ThemeData theme) {
    final bool active = currentIndex == index;
    final isLight = theme.brightness == Brightness.light;
    final activeYellow = const Color(0xFFFFC107);
    final color = active ? (isLight ? Colors.black : theme.colorScheme.primary) : theme.colorScheme.outline;

    // ITEM MENU: Dibungkus Material agar InkWell di dalamnya bisa bekerja
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active && isLight ? activeYellow.withOpacity(0.4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 22, color: color),
                    const SizedBox(height: 2),
                    Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}