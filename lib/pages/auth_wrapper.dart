import 'package:material_ui/material_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:certame3_angel_salinas/pages/home_page.dart';
import 'package:certame3_angel_salinas/pages/login_page.dart';

// Este es la validacion para entrar en el homePage o el LoginPage
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomePage();
        }
        return LoginPage();
      }),
    );
  }
}
