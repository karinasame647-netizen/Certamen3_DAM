import 'dart:convert';

import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:certame3_angel_salinas/utils/tipo_fecha.dart';
import 'package:certame3_angel_salinas/utils/paleta_colores.dart';

// eston los tipos de card que se usan par ver objetos y mis publicaciones
class TipoCardPublicaciones extends StatelessWidget {
  const TipoCardPublicaciones({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.lugar,
    this.tipo,
    this.estado,
    this.fotoUrl,
    this.foto,
    this.alPresionar,
    this.onEditar,
    this.onEliminar,
  });

  final String titulo;
  final DateTime? fecha;
  final String lugar;
  final String? tipo;
  final String? estado;
  final String? fotoUrl;
  final String? foto;
  final VoidCallback? alPresionar;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  //Primero se usa el InkWell para colocar la imagen que se guardo en la base de datos
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        color: PaletaColores.blanco,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              miniatura(),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: PaletaColores.textoPrincipal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    //Esta es la fecha que coloca cuando la fecha no esta disponible
                    Text(
                      fecha == null
                          ? 'Fecha no disponible'
                          : TipoFecha.formatear(fecha!),
                      style: TextStyle(
                        color: PaletaColores.textoSecundario,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    //Este es el lugar que coloca cuando el lugar
                    Row(
                      children: [
                        Icon(
                          MdiIcons.mapMarkerOutline,
                          size: 15,
                          color: PaletaColores.textoSecundario,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lugar,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: PaletaColores.textoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    //Y aqui se coloca el estado del producto y cambia de color cuando es vigente o devuelto
                    if (mostrarEstado())
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: esDevuelto()
                                ? PaletaColores.exito
                                : PaletaColores.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            esDevuelto() ? 'Devuelto' : 'Perdido',
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              //Este es para el boton de editar estado o eliminar en mis publicaciones
              if (alPresionar != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: PaletaColores.superficie,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    MdiIcons.chevronRight,
                    color: PaletaColores.primarioOscuro,
                  ),
                ),
              if (onEditar != null || onEliminar != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    MdiIcons.dotsVertical,
                    color: PaletaColores.primarioOscuro,
                  ),
                  onSelected: (accion) {
                    if (accion == 'editar') {
                      onEditar?.call();
                    } else if (accion == 'eliminar') {
                      onEliminar?.call();
                    }
                  },
                  //Este lo edita
                  itemBuilder: (context) => [
                    if (onEditar != null)
                      PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(MdiIcons.pencilOutline),
                            SizedBox(width: 8),
                            Text('Editar estado'),
                          ],
                        ),
                      ),
                    //Este lo elimina
                    if (onEliminar != null)
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(MdiIcons.deleteOutline),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  //La variable actua como un switch para ver si cambia de rojo a verde
  bool esDevuelto() {
    return estado?.trim().toLowerCase() == 'devuelto';
  }

  //Este muestra el estado
  bool mostrarEstado() {
    if (esDevuelto()) return true;
    final estadoNormalizado = estado?.trim().toLowerCase();
    final tipoNormalizado = tipo?.trim().toLowerCase();
    return estadoNormalizado == 'perdido' ||
        estadoNormalizado == 'vigente' && tipoNormalizado == 'perdido';
  }

  //Este es para mostrar la miniatura de la imagen aunque este vacia
  Widget miniatura() {
    if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          fotoUrl!,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fotoVacia(),
        ),
      );
    }
    if (foto != null && foto!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            base64Decode(foto!),
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fotoVacia(),
          ),
        );
      } on FormatException {
        return fotoVacia();
      }
    }

    return fotoVacia();
  }

  //Y este verifica si esta vacia la imagen
  Widget fotoVacia() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: PaletaColores.imagenVacia,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        MdiIcons.packageVariant,
        size: 32,
        color: PaletaColores.textoSecundario,
      ),
    );
  }
}
