import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoService {
  // obtener los productos
  Stream<QuerySnapshot> productos() {
    return FirebaseFirestore.instance.collection('producciones').snapshots();
  }

  // Aca agrega la categoria unica a la tabla categorias
  Future<void> agregarCategoria(String nombre, String autorUid) {
    return FirebaseFirestore.instance.collection('categoria').doc().set({
      'nombre': nombre,
      'autorUid': autorUid,
    });
  }

  //agregar producto
  Future<void> agregarProducto(
    String titulo,
    String descripcion,
    String lugar,
    String tipo,
    DateTime fechaHora, {
    String estado = 'Vigente',
    String? autor,
    String? autorUid,
    String? foto,
  }) {
    return FirebaseFirestore.instance.collection('producciones').doc().set({
      'titulo': titulo,
      'descripcion': descripcion,
      'lugar': lugar,
      'tipo': tipo,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'estado': estado,
      'autor': autor,
      'autorUid': autorUid,
      'foto': ?foto,
      'creadoEn': FieldValue.serverTimestamp(),
    });
  }

  //editar un estado de producto
  Future<void> editarProducto(String id, String estado) {
    return FirebaseFirestore.instance.collection('producciones').doc(id).update(
      {'estado': estado},
    );
  }

  //borrar un producto
  Future<void> borrarProducto(String id) {
    return FirebaseFirestore.instance
        .collection('producciones')
        .doc(id)
        .delete();
  }
}
