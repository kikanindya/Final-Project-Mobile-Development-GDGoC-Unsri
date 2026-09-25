import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'presentation/pages/main_page.dart'; 
import 'auth/login_screen.dart';

// Global ValueNotifier untuk tema agar bisa diubah dan didengarkan dari seluruh aplikasi
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Mengaktifkan pengaturan offline Firestore agar aman saat terkendala jaringan
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const DucklistApp());
}

class DucklistApp extends StatelessWidget {
  const DucklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFB86C),
              brightness: Brightness.light,
              surface: const Color(0xFFFFFDF9),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFB86C),
              brightness: Brightness.dark,
              surface: const Color(0xFF121212),
            ),
          ),
          themeMode: currentMode,
          // Pengecekan status login otomatis
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFFFFF9EC),
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD447)),
                  ),
                );
              }
              
              // Jika sudah login, masuk ke MainPage
              if (snapshot.hasData) {
                return const MainPage();
              }
              
              // Jika belum login, tampilkan LoginScreen
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}