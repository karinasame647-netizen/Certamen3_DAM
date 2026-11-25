import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/services/producto_service.dart';
import 'package:certame3_angel_salinas/utils/tipo_card_publicaciones.dart';
import 'package:certame3_angel_salinas/utils/editar_publicacion.dart';
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';

//Este es para ver las publicaciones que el usuario que esta activo en el programa a hecho
class VerPublicacionesPage extends StatefulWidget {
  const VerPublicacionesPage({super.key});

  @override
  State<VerPublicacionesPage> createState() => _VerPublicacionesPageState();
}

class _VerPublicacionesPageState extends State<VerPublicacionesPage> {
  final _productoService = ProductoService();
  Stream<QuerySnapshot<Map<String, dynamic>>>? publicaciones;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      publicaciones = FirebaseFirestore.instance
          .collection('producciones')
          .where('autorUid', isEqualTo: uid)
          .snapshots();
    }
  }

  // Este es el tab para colocar las publicaciones por orden de si esta devuelto o esta vigente
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: PaletaColores.fondo,
        appBar: AppBar(
          backgroundColor: PaletaColores.superficie,
          foregroundColor: PaletaColores.primarioOscuro,
          title: Text(
            'Mis Publicaciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Todas'),
              Tab(text: 'Perdidos'),
              Tab(text: 'Encontrados'),
            ],
          ),
        ),
        //Aca se muestra un mensaje de error en caso de acceder a la pagina sin correo verificado
        body: publicaciones == null
            ? Center(child: Text('Inicia sesión para ver tus publicaciones'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: publicaciones,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No se pudieron cargar las publicaciones: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final documentos =
                      snapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                  return TabBarView(
                    children: [
                      listaPublicaciones(documentos),
                      listaPublicaciones(documentos, tipo: 'Perdido'),
                      listaPublicaciones(documentos, tipo: 'Encontrado'),
                    ],
                  );
                },
              ),
      ),
    );
  }

  //Este lista las publicaciones por mediante los tabs si son de tipo encontrado o perdido
  Widget listaPublicaciones(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> publicaciones, {
    String? tipo,
  }) {
    final filtradas = tipo == null
        ? publicaciones
        : publicaciones.where((documento) {
            final datos = documento.data();
            final estado = datos['estado'];
            if (tipo == 'Perdido') {
              return datos['tipo'] == 'Perdido' && estado != 'Devuelto';
            }
            return datos['tipo'] == 'Encontrado' || estado == 'Devuelto';
          }).toList();

    if (filtradas.isEmpty) {
      return Center(
        child: Text(
          tipo == null
              ? 'Aún no tienes publicaciones'
              : 'No tienes publicaciones de tipo $tipo',
          textAlign: TextAlign.center,
          style: TextStyle(color: PaletaColores.secundario),
        ),
      );
    }
    //Y este los lista
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: filtradas.length,
      separatorBuilder: (context, index) => SizedBox(height: 8),
      itemBuilder: (context, index) {
        final datos = filtradas[index].data();
        final titulo = datos['titulo'] as String? ?? 'Sin título';
        final fecha = leerFecha(datos['fechaHora']);
        final lugar = datos['lugar'] as String? ?? 'Lugar no especificado';
        final fotoUrl = datos['fotoUrl'] as String?;
        final foto = (datos['fotoBase64'] ?? datos['foto']) as String?;
        final estado = datos['estado'] as String? ?? 'Vigente';

        return TipoCardPublicaciones(
          titulo: titulo,
          fecha: fecha,
          lugar: lugar,
          tipo: datos['tipo'] as String?,
          estado: estado,
          fotoUrl: fotoUrl,
          foto: foto,
          onEditar: () => editarEstado(filtradas[index].id, estado),
          onEliminar: () => eliminarPublicacion(filtradas[index].id, titulo),
        );
      },
    );
  }

  //Este es para editar los estos de la publicacion
  Future<void> editarEstado(String id, String estadoActual) async {
    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (context) => EditarPublicacionDialog(
        estadoActual: estadoActual == 'Devuelto' ? estadoActual : 'Vigente',
      ),
    );
    if (nuevoEstado == null || nuevoEstado == estadoActual) return;

    try {
      await _productoService.editarProducto(id, nuevoEstado);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      await mostrarError(
        'No se pudo actualizar el estado',
        error.message ?? 'Intenta nuevamente.',
      );
    }
  }

  //Este elimina las publicaciones que el usuario tiene
  Future<void> eliminarPublicacion(String id, String titulo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar publicación'),
        content: Text(
          '¿Quieres eliminar "$titulo"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _productoService.borrarProducto(id);
      if (!mounted) return;
      mostrarMensajeFlotante('Publicación eliminada correctamente');
    } on FirebaseException catch (error) {
      if (!mounted) return;
      await mostrarError(
        'No se pudo eliminar la publicación',
        error.message ?? 'Intenta nuevamente.',
      );
    } on Exception catch (error) {
      if (!mounted) return;
      await mostrarError(
        'No se pudo eliminar la publicación',
        'Ocurrió un error inesperado: $error',
      );
    }
  }

  //Y este es para mostrar un mensaje de error
  Future<void> mostrarError(String titulo, String mensaje) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // Esta es para mostrar un mensaje en caso de exito
  void mostrarMensajeFlotante(String mensaje) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entrada;
    Timer(Duration(seconds: 3), () {
      if (entrada.mounted) entrada.remove();
      entrada.dispose();
    });

    entrada = OverlayEntry(
      builder: (context) => Positioned(
        left: 20,
        right: 20,
        bottom: 32,
        child: SafeArea(
          child: Center(
            child: Material(
              color: PaletaColores.transparente,
              child: Container(
                constraints: BoxConstraints(maxWidth: 420),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: PaletaColores.exito,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: PaletaColores.sombraFuerte,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PaletaColores.blanco,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entrada);
  }

  //Este es para leer la fecha
  DateTime? leerFecha(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return null;
  }
}
