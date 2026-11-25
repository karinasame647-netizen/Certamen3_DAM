import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

//este es el tamaño, el formato de la imagen y la calidad de la imagen
class ImagenService {
  final ImagePicker picker = ImagePicker();

  Future<Uint8List?> seleccionarImagen(ImageSource origen) async {
    final XFile? imagen = await picker.pickImage(
      source: origen,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 50,
    );

    if (imagen == null) {
      return null;
    }

    return await imagen.readAsBytes();
  }
}
