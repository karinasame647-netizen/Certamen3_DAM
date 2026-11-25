import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<User?> currentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  static String nombreVisible(User? usuario) {
    final nombre = usuario?.displayName?.trim();
    return nombre == null || nombre.isEmpty ? 'Usuario' : nombre;
  }
}
