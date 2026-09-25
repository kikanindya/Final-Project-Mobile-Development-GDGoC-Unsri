import 'package:flutter/material.dart';
import 'focus_page.dart'; // Pastikan import halaman tujuannya benar

class HomeFocusMode extends StatelessWidget {
  const HomeFocusMode({super.key});

  void _navigateToFocusPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FocusPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Seluruh kotak widget di home dibungkus GestureDetector
    return GestureDetector(
      onTap: () => _navigateToFocusPage(context),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FOCUS MODE", 
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "25:00",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // Tombol-tombol di dalam kartu ikut mengarahkan ke FocusPage jika ditekan
                  IconButton(
                    onPressed: () => _navigateToFocusPage(context),
                    icon: const Icon(Icons.refresh),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToFocusPage(context),
                    child: Icon(Icons.play_circle, size: 45, color: theme.colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: 0.0, // Statis di awal, timer aslinya berjalan di FocusPage
                backgroundColor: theme.colorScheme.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}