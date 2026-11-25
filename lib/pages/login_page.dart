import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/services/google_service.dart'
    as google_auth;
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String mensajeError = '';
  bool hayError = false;
  bool iniciandoConGoogle = false;

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
                                subtitle: Text('Accede para continuar'),
                              ),
                              SizedBox(height: 12),
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

  //iniciar sesion con google
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
