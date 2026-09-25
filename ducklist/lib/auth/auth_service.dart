import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user yang sedang aktif
  User? get currentUser => _auth.currentUser;

  // 1. REGISTER (Daftar dengan Email & Password)
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Error Register: $e");
      return null;
    }
  }

  // 2. LOGIN (Masuk dengan Email & Password)
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  // 3. CEK APAKAH SUDAH LOGIN (Untuk Auto-Login / Cek Sesi)
  // Firebase otomatis menyimpan sesi, jadi kita tinggal cek _auth.currentUser
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // 4. LOGOUT (Keluar dari sesi)
  Future<void> logout() async {
    await _auth.signOut();
  }
}