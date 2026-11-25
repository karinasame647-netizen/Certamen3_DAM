import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/utils/peticion.dart';
import 'package:certame3_angel_salinas/utils/tipo_card_publicaciones.dart';
import 'package:certame3_angel_salinas/utils/tipo_fecha.dart';
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';

class TodosLosObjetosPage extends StatelessWidget {
  const TodosLosObjetosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaColores.fondo,
      appBar: AppBar(
        backgroundColor: PaletaColores.superficie,
        foregroundColor: PaletaColores.primarioOscuro,
        title: Text('Todos los objetos'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('producciones')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar los objetos: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final objetos =
              snapshot.data?.docs ??
              <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          if (objetos.isEmpty) {
            return Center(child: Text('Aún no hay objetos publicados'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(objetos.length, (index) {
                final documento = objetos[index];
                final datos = documento.data();
                final fecha = leerFecha(datos['fechaHora']);
                final lugar = datos['lugar'];
                final fotoUrl = datos['fotoUrl'];
                final foto = datos['foto'] ?? datos['foto'];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < objetos.length - 1 ? 8 : 0,
                  ),
                  child: TipoCardPublicaciones(
                    titulo: datos['titulo'] as String? ?? 'Sin título',
                    fecha: fecha,
                    lugar: lugar is String ? lugar : 'Lugar no especificado',
                    tipo: datos['tipo'] as String?,
                    estado: datos['estado'] as String?,
                    fotoUrl: fotoUrl is String ? fotoUrl : null,
                    foto: foto is String ? foto : null,
                    alPresionar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleObjetoPage(datos: datos),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  DateTime? leerFecha(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return null;
  }
}

class DetalleObjetoPage extends StatelessWidget {
  const DetalleObjetoPage({super.key, required this.datos});

  final Map<String, dynamic> datos;

  static final etiquetas = {
    'tipo': 'Tipo',
    'categoria': 'Categoría',
    'lugar': 'Lugar',
    'fechaHora': 'Fecha y hora',
    'estado': 'Estado',
    'autor': 'Autor',
    'creadoEn': 'Fecha de publicación',
  };

  @override
  Widget build(BuildContext context) {
    final titulo = datos['titulo'] as String? ?? 'Objeto';
    final fotoUrl = datos['fotoUrl'];
    final foto = datos['foto'] ?? datos['foto'];
    final campos = datos.entries.where(
      (campo) =>
          campo.key != 'titulo' &&
          campo.key != 'descripcion' &&
          campo.key != 'foto' &&
          campo.key != 'fotoUrl' &&
          campo.key != 'foto' &&
          campo.key != 'autorUid' &&
          campo.value != null,
    );

    return Scaffold(
      backgroundColor: PaletaColores.fondo,
      appBar: AppBar(
        backgroundColor: PaletaColores.superficie,
        foregroundColor: PaletaColores.primarioOscuro,
        title: Text('Detalle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: PaletaColores.textoPrincipal,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  imagen(fotoUrl, foto),
                  SizedBox(height: 12),
                  ...campos.map(
                    (campo) => filaDetalle(
                      etiquetas[campo.key] ?? campo.key,
                      formatearValor(campo.value),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => abrirFormularioPeticion(context),
                    icon: Icon(MdiIcons.messageProcessingOutline),
                    label: Text('Contactar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PaletaColores.botonAzul,
                      foregroundColor: PaletaColores.blanco,
                      minimumSize: Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> abrirFormularioPeticion(BuildContext context) async {
    final enviada = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => FormularioPeticionDialog(datos: datos),
    );

    if (enviada == true && context.mounted) {
      mostrarMensajeFlotante(context, 'Petición guardada');
    }
  }

  void mostrarMensajeFlotante(BuildContext context, String mensaje) {
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

  Widget imagen(Object? url, Object? base64) {
    if (url is String && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          height: 190,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => imagenVacia(),
        ),
      );
    }
    if (base64 is String && base64.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            base64Decode(base64),
            height: 190,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => imagenVacia(),
          ),
        );
      } on FormatException {
        return imagenVacia();
      }
    }
    return imagenVacia();
  }

  Widget imagenVacia() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: PaletaColores.imagenVacia,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        MdiIcons.packageVariant,
        size: 72,
        color: PaletaColores.textoSecundario,
      ),
    );
  }

  Widget filaDetalle(String etiqueta, String valor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              etiqueta,
              style: TextStyle(
                color: PaletaColores.secundario,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: TextStyle(color: PaletaColores.textoPrincipal),
            ),
          ),
        ],
      ),
    );
  }

  String formatearValor(Object valor) {
    if (valor is Timestamp) return TipoFecha.formatear(valor.toDate());
    if (valor is DateTime) return TipoFecha.formatear(valor);
    return valor.toString();
  }
}

class FormularioPeticionDialog extends StatefulWidget {
  const FormularioPeticionDialog({super.key, required this.datos});

  final Map<String, dynamic> datos;

  @override
  State<FormularioPeticionDialog> createState() =>
      _FormularioPeticionDialogState();
}

class _FormularioPeticionDialogState extends State<FormularioPeticionDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController remitenteCtrl;
  final descripcionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    remitenteCtrl = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email ?? '',
    );
  }

  @override
  void dispose() {
    remitenteCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchoDisponible = MediaQuery.sizeOf(context).width - 32;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        minWidth: anchoDisponible,
        maxWidth: anchoDisponible,
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enviar petición',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: remitenteCtrl,
                        decoration: InputDecoration(
                          labelText: 'Quién envía la petición',
                          prefixIcon: Icon(MdiIcons.accountOutline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Indica quién envía la petición';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: descripcionCtrl,
                        decoration: InputDecoration(
                          labelText: 'Descripción de la petición',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(MdiIcons.messageTextOutline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Escribe la petición';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(false),
                  child: Text('Cancelar'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _guardarPeticion,
                  child: Text('Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _guardarPeticion() {
    if (!formKey.currentState!.validate()) return;

    final autor = widget.datos['autor'];
    final autorUid = widget.datos['autorUid'];
    PeticionesLocales.agregar(
      Peticion(
        remitente: remitenteCtrl.text.trim(),
        descripcion: descripcionCtrl.text.trim(),
        tituloObjeto: widget.datos['titulo'] as String? ?? 'Objeto',
        fecha: DateTime.now(),
        autorObjeto: autor is String ? autor : null,
        destinatarioUid: autorUid is String ? autorUid : null,
        destinatarioCorreo: autor is String ? autor : null,
      ),
    );
    Navigator.of(context, rootNavigator: true).pop(true);
  }
}
