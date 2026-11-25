import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/widgets/agregar_objeto.dart';
import 'package:certame3_angel_salinas/widgets/todos_los_objetos.dart';
import 'package:certame3_angel_salinas/widgets/peticiones_page.dart';
import 'package:certame3_angel_salinas/widgets/ver_publicaciones.dart';
import 'package:certame3_angel_salinas/widgets/ver_sesion.dart';
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';
import 'package:certame3_angel_salinas/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  //Inicia el widget visual de la tarjeta. proporciona el fondo, bordes y efectos táctiles usados por InkWell
  @override
  Widget build(BuildContext context) {
    return Material(
      color: PaletaColores.accion,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 106,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: PaletaColores.primario),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PaletaColores.primarioOscuro,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageState extends State<HomePage> {
  int tabSeleccionado = 0;

  @override
  Widget build(BuildContext context) {
    final nombreUsuario = AuthService.nombreVisible(
      FirebaseAuth.instance.currentUser,
    );
    return Scaffold(
      backgroundColor: PaletaColores.fondo,
      appBar: AppBar(
        backgroundColor: PaletaColores.superficie,
        foregroundColor: PaletaColores.primarioOscuro,
        //automaticallyImplyLeading: false: impide que Flutter agregue automáticamente un botón de “volver”.
        automaticallyImplyLeading: false,
        //leadingWidth: reserva 56 píxeles si está seleccionado el apartado 1; en otro caso reserva 0.
        leadingWidth: tabSeleccionado == 1 ? 56 : 0,
        //leading: tabSeleccionado == 1: muestra un botón personalizado solo en ese apartado.
        leading: tabSeleccionado == 1
            ? IconButton(
                icon: Icon(MdiIcons.arrowLeft),
                tooltip: 'Volver al inicio',
                onPressed: () {
                  setState(() {
                    tabSeleccionado = 0;
                  });
                },
              )
            : null,
        titleSpacing: 0,
        title: tabSeleccionado == 1
            ? null
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(MdiIcons.accountCircleOutline),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nombreUsuario,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),

        actions: [
          PopupMenuButton(
            onSelected: (valueSeleccionado) => FirebaseAuth.instance.signOut(),
            iconColor: PaletaColores.grisOscuro,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: PaletaColores.botonAzul),
                ),
              ),
            ],
          ),
        ],
      ),
      //Este es el boton de ver Sesion para poder ver el usuario que esta conectado
      floatingActionButton: tabSeleccionado == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              backgroundColor: PaletaColores.primario,
              foregroundColor: PaletaColores.blanco,
              icon: Icon(MdiIcons.logout),
              label: Text('Cerrar sesión'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: tabSeleccionado == 0 ? homeBuild() : VerSesion(),
        ),
      ),
    );
  }

  Widget homeBuild() {
    final user = FirebaseAuth.instance.currentUser;
    final nombreUsuario = AuthService.nombreVisible(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8),
        Text(
          'Objetos Perdidos USM',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PaletaColores.primarioOscuro,
            fontSize: 26,
            height: 1.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Hola, $nombreUsuario',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PaletaColores.secundario,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 40),

        //Aca se muestran todos los botones para hacer todas la acciones del programa
        Row(
          children: [
            Expanded(
              child: HomeActionCard(
                icon: MdiIcons.plusCircle,
                title: 'Publicar\nObjeto',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgregarObjetoPage(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: HomeActionCard(
                icon: MdiIcons.menu,
                title: 'Ver Objetos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TodosLosObjetosPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: HomeActionCard(
                icon: MdiIcons.packageVariant,
                title: 'Mis Publicaciones',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerPublicacionesPage(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: HomeActionCard(
                icon: MdiIcons.accountOutline,
                title: 'Mi Cuenta',
                onTap: () {
                  setState(() {
                    tabSeleccionado = 1;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        HomeActionCard(
          icon: MdiIcons.messageTextOutline,
          title: 'Peticiones',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PeticionesPage()),
            );
          },
        ),
      ],
    );
  }
}
