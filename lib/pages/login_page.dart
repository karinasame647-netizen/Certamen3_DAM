import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/services/google_service.dart'
    as google_auth;
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

//Aqui se coloca el formulario de inicio de sesión
class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String mensajeError = '';
  bool hayError = false;
  bool iniciandoConGoogle = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaColores.blanco,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [PaletaColores.grisClaro, PaletaColores.gris],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 80, color: PaletaColores.primario),
                    Text(
                      'Objetos Perdidos USM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PaletaColores.primarioOscuro,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Encuentra o reporta objetos perdidos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PaletaColores.secundario,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 48),
                    Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 420),
                        decoration: BoxDecoration(
                          color: PaletaColores.blanco,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: PaletaColores.sombra,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: PaletaColores.accion,
                                  child: Icon(
                                    MdiIcons.accountOutline,
                                    color: PaletaColores.primario,
                                  ),
                                ),
                                title: Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    color: PaletaColores.primarioOscuro,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('Ingresa con tu correo'),
                              ),
                              SizedBox(height: 12),
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: emailCtrl,
                                      decoration: InputDecoration(
                                        labelText: 'Correo electrónico',
                                        prefixIcon: Icon(MdiIcons.emailOutline),
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        final correo = value?.trim() ?? '';
                                        if (correo.isEmpty) {
                                          return 'Ingresa tu correo electrónico';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    TextFormField(
                                      controller: passwordCtrl,
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        prefixIcon: Icon(MdiIcons.lockOutline),
                                        border: OutlineInputBorder(),
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingresa tu contraseña';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (hayError) ...[
                                SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: PaletaColores.errorFondo,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    mensajeError,
                                    style: TextStyle(
                                      color: PaletaColores.error,
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: iniciarSesion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PaletaColores.primario,
                                    foregroundColor: PaletaColores.blanco,
                                  ),
                                  child: Text(
                                    'Continuar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: iniciandoConGoogle
                                      ? null
                                      : iniciarSesionGoogle,
                                  icon: Icon(MdiIcons.google),
                                  label: Text(
                                    iniciandoConGoogle
                                        ? 'Conectando con Google...'
                                        : 'Iniciar con Google',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //iniciar sesion con correo y contraseña (valido)
  Future<void> iniciarSesion() async {
    if (hayError) {
      setState(() {
        hayError = false;
      });
    }
    if (!formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );
    } on FirebaseAuthException catch (ex) {
      switch (ex.code) {
        case 'channel-error':
          mensajeError = 'Ingrese sus credenciales';
          break;
        case 'invalid-email':
          mensajeError = 'Email no válido';
          break;
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          mensajeError = 'Credenciales no válidas';
          break;
        case 'user-disabled':
          mensajeError = 'Cuenta desactivada';
          break;
        case 'too-many-requests':
          mensajeError = 'Demasiados intentos. Inténtalo más tarde';
          break;
        default:
          mensajeError = 'No se pudo iniciar sesión';
      }
      if (mounted) {
        setState(() {
          hayError = true;
        });
      }
    }
  }

  //iniciar sesion con google (fallido)
  Future<void> iniciarSesionGoogle() async {
    setState(() {
      iniciandoConGoogle = true;
      hayError = false;
    });

    final credencial = await google_auth.AuthService().signInWithGoogle();

    if (!mounted) return;
    setState(() {
      iniciandoConGoogle = false;
      if (credencial == null) {
        mensajeError = 'No se pudo iniciar sesión con Google';
        hayError = true;
      }
    });
  }
}
