class Peticion {
  const Peticion({
    required this.remitente,
    required this.descripcion,
    required this.tituloObjeto,
    required this.fecha,
    this.autorObjeto,
    this.destinatarioUid,
    this.destinatarioCorreo,
  });

  final String remitente;
  final String descripcion;
  final String tituloObjeto;
  final DateTime fecha;
  final String? autorObjeto;
  final String? destinatarioUid;
  final String? destinatarioCorreo;
}

class PeticionesLocales {
  static final List<Peticion> _peticiones = [];

  static List<Peticion> get peticiones => List.unmodifiable(_peticiones);

  static void agregar(Peticion peticion) {
    _peticiones.add(peticion);
  }
}
