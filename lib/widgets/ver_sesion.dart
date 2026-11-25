import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';
import 'package:certame3_angel_salinas/services/auth_service.dart';

//Aqui se muestra el boton ver sesion que no tiene mayor uso que solo colocar el usuario que esta conectado
class VerSesion extends StatelessWidget {
  const VerSesion({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8),
        Text(
          'Mi Cuenta',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PaletaColores.primarioOscuro,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: Icon(MdiIcons.accountOutline),
            title: Text('Nombre'),
            subtitle: Text(AuthService.nombreVisible(user)),
          ),
        ),
      ],
    );
  }
}
