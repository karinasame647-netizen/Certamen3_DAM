//Esta es el formateo para mostrar la fecha
class TipoFecha {
  static String formatear(DateTime fechaHora) {
    final dia = fechaHora.day.toString().padLeft(2, '0');
    final mes = fechaHora.month.toString().padLeft(2, '0');
    final anio = fechaHora.year.toString().padLeft(4, '0');
    final hora = fechaHora.hour.toString().padLeft(2, '0');
    final minuto = fechaHora.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }
}
