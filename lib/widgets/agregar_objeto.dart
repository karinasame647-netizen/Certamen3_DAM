import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/data/categoria.dart';
import 'package:certame3_angel_salinas/services/imagen_service.dart';
import 'package:certame3_angel_salinas/services/producto_service.dart';
import 'package:certame3_angel_salinas/services/auth_service.dart';
import 'package:certame3_angel_salinas/utils/tipo_fecha.dart';
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class AgregarObjetoPage extends StatefulWidget {
  const AgregarObjetoPage({super.key});

  @override
  State<AgregarObjetoPage> createState() => _AgregarObjetoPageState();
}

class _AgregarObjetoPageState extends State<AgregarObjetoPage> {
  final productoService = ProductoService();
  final imagenService = ImagenService();
  final formKey = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();
  final fotoKey = GlobalKey<FormFieldState<Uint8List>>();

  Uint8List? fotoSeleccionada;
  final String tipo = 'Perdido';
  String categoria = categorias.first;
  DateTime fechaHora = DateTime.now();
  bool guardando = false;

  @override
  void dispose() {
    tituloCtrl.dispose();
    descripcionCtrl.dispose();
    lugarCtrl.dispose();
    super.dispose();
  }

  String get fechaHoraTexto => TipoFecha.formatear(fechaHora);
  //Aqui se selecciona la foto mediante la camara o galeria y se guarda en la variable fotoSeleccionada, ademas de mostrar un mensaje flotante en caso de error
  Future<void> seleccionarFoto() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera_outlined),
              title: Text('Tomar fotografía'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('Seleccionar desde la galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (origen == null) return;
    //aqui es la validacion de la foto seleccionada, si es nula no se hace nada, si no se guarda en la variable fotoSeleccionada y se actualiza el estado del formulario
    try {
      final imagen = await imagenService.seleccionarImagen(origen);
      if (!mounted || imagen == null) return;
      setState(() => fotoSeleccionada = imagen);
      fotoKey.currentState?.didChange(imagen);
      //el plataform exception es para manejar los errores de la plataforma especifica el nombre del error
    } on PlatformException catch (error) {
      if (!mounted) return;
      mostrarMensajeFlotante(
        error.message ?? 'No se pudo seleccionar la fotografía',
        esError: true,
      );
    } on Exception catch (error) {
      if (!mounted) return;
      mostrarMensajeFlotante(
        'No se pudo seleccionar la fotografía: $error',
        esError: true,
      );
    }
  }

  //este es el mensaje flotante para todo tipo de mensajes
  void mostrarMensajeFlotante(String mensaje, {bool esError = false}) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entrada;
    Timer(Duration(seconds: 3), () {
      if (entrada.mounted) entrada.remove();
      entrada.dispose();
    });

    entrada = OverlayEntry(
      builder: (context) => Positioned(
        left: 30,
        right: 30,
        bottom: 32,
        child: SafeArea(
          //lo coloca en medio
          child: Center(
            //le coloca un material para que tenga sombra
            child: Material(
              color: PaletaColores.transparente,
              //Esta es la verificacion para saber si es error o exito
              child: Container(
                constraints: BoxConstraints(maxWidth: 420),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: esError ? PaletaColores.error : PaletaColores.exito,
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
                    fontWeight: FontWeight.bold,
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

  //Este es el boton para seleccionar la foto
  Widget botonFoto() {
    final foto = fotoSeleccionada;
    return InkWell(
      onTap: seleccionarFoto,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: foto == null ? 80 : 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: foto == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    color: PaletaColores.botonAzul,
                    size: 32,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Agregar Foto',
                    style: TextStyle(
                      color: PaletaColores.primarioOscuro,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            //si la foto no es nula se muestra la foto y un boton para cambiarla
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(foto, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: PaletaColores.primarioOscuro,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Cambiar foto',
                        style: TextStyle(
                          color: PaletaColores.blanco,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  //Esta es la seleccion de la fecha y hora hasta el dia de hoy
  Future<void> seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fechaHora),
    );
    if (hora == null || !mounted) return;

    setState(() {
      fechaHora = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  //Este metodo publica el objeto en la base de datos, primero valida que el formulario sea valido y que la foto no sea nula,
  //luego obtiene el usuario actual y llama a los metodos de agregar categoria, agregar producto del servicio de producto
  Future<void> publicar() async {
    if (!formKey.currentState!.validate()) return;
    if (fotoSeleccionada == null) {
      mostrarMensajeFlotante('La fotografía es obligatoria', esError: true);
      return;
    }

    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;
    setState(() => guardando = true);

    try {
      await productoService.agregarCategoria(categoria, usuario.uid);
      await productoService.agregarProducto(
        tituloCtrl.text.trim(),
        descripcionCtrl.text.trim(),
        lugarCtrl.text.trim(),
        tipo,
        fechaHora,
        estado: 'Vigente',
        autor: AuthService.nombreVisible(usuario),
        autorUid: usuario.uid,
        foto: base64Encode(fotoSeleccionada!),
      );

      if (!mounted) return;
      mostrarMensajeFlotante('Publicación guardada');
      Navigator.pop(context);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      mostrarMensajeFlotante(
        error.message == null
            ? 'No se guardó la publicación'
            : 'No se guardó la publicación: ${error.message}',
        esError: true,
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  //Este es el formulario que se utiliza para agregar un nuevo objeto
  @override
  Widget build(BuildContext context) {
    final autor = AuthService.nombreVisible(
      FirebaseAuth.instance.currentUser,
    );
    return Scaffold(
      backgroundColor: PaletaColores.fondo,
      appBar: AppBar(
        backgroundColor: PaletaColores.superficie,
        foregroundColor: PaletaColores.primarioOscuro,
        title: Text(
          'Publicar Objeto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //Esta es la parte para agregar una foto y la validacion para saber si esta en blanco
                    SizedBox(height: 16),
                    FormField<Uint8List>(
                      key: fotoKey,
                      initialValue: fotoSeleccionada,
                      validator: (foto) {
                        if (foto == null) {
                          return 'Selecciona una fotografía obligatoria';
                        }
                        return null;
                      },
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          botonFoto(),
                          if (state.hasError) ...[
                            SizedBox(height: 6),
                            Text(
                              state.errorText!,
                              style: TextStyle(
                                color: PaletaColores.error,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    //Estos son los formularios para agregar el titulo, descripcion, tipo, estado, etc.
                    TextFormField(
                      controller: tituloCtrl,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ej: Audífonos Bluetooth negros',
                        prefixIcon: Icon(MdiIcons.formatTitle),
                        filled: true,
                        fillColor: PaletaColores.blanco,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el título';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: descripcionCtrl,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: Icon(MdiIcons.text),
                        filled: true,
                        fillColor: PaletaColores.blanco,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa una descripción';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        prefixIcon: Icon(MdiIcons.swapHorizontal),
                        filled: true,
                        fillColor: PaletaColores.blanco,
                      ),
                      child: Text(tipo),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: categoria,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(MdiIcons.shapeOutline),
                        filled: true,
                        fillColor: PaletaColores.blanco,
                      ),
                      items: categorias
                          .map(
                            (categoria) => DropdownMenuItem<String>(
                              value: categoria,
                              child: Text(categoria),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => categoria = value!),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: lugarCtrl,
                      decoration: InputDecoration(
                        labelText: 'Lugar del campus',
                        hintText: 'Ej: Laboratorio U100',
                        prefixIcon: Icon(MdiIcons.mapMarkerOutline),
                        filled: true,
                        fillColor: PaletaColores.blanco,
                      ),
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: seleccionarFechaHora,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha y hora',
                          prefixIcon: Icon(MdiIcons.calendarMonthOutline),
                          filled: true,
                          fillColor: PaletaColores.blanco,
                        ),
                        child: Text(fechaHoraTexto),
                      ),
                    ),
                    SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(MdiIcons.checkCircleOutline),
                        filled: true,
                        fillColor: PaletaColores.blanco,
                      ),
                      child: Text('Vigente'),
                    ),
                    SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Autor',
                        prefixIcon: Icon(MdiIcons.accountOutline),
                        filled: true,
                        fillColor: PaletaColores.blanco,
                      ),
                      child: Text(autor),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: guardando ? null : publicar,
                      icon: guardando
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.send),
                      label: Text(guardando ? 'Publicando...' : 'Publicar'),
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
      ),
    );
  }
}
