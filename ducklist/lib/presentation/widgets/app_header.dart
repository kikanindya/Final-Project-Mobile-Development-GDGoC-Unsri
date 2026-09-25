import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/profile.dart'; 

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final random = Random();

    if (hour >= 5 && hour < 12) {
      const greetings = ["Beautiful morning! ☀️", "Rise and shine! 🦆", "Good morning! 🌅"];
      return greetings[random.nextInt(greetings.length)];
    } else if (hour >= 12 && hour < 18) {
      const greetings = ["Good afternoon! 🌤️", "Keep it up! 🦆", "Productive day! 🚀"];
      return greetings[random.nextInt(greetings.length)];
    } else {
      const greetings = ["Good evening! 🌙", "Time to relax! 🦆", "Rest well tonight! 💤"];
      return greetings[random.nextInt(greetings.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Ambil user yang sedang aktif dari Firebase Auth
    final User? user = FirebaseAuth.instance.currentUser;
    
    // Ambil bagian depan email sebagai nama, atau fallback ke "Duck User" jika null
    String displayName = "Duck User";
    if (user != null && user.email != null) {
      displayName = user.email!.split('@')[0];
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }
    
    return Row(
      children: [
        // Foto profil
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MePage(
                  locale: const Locale('en'),
                  onLocaleChanged: (newLocale) {},
                  themeMode: ThemeMode.system,
                  onThemeChanged: (newTheme) {},
                ),
              ),
            );
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Nama dan Status Dinamis
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}