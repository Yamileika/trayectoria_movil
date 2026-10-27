import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../datos/modelos.dart';

enum OrigenArchivo { camara, galeria, archivos }

/// Elige un archivo del teléfono. Se inyecta para poder simularlo en pruebas.
abstract class SelectorArchivos {
  /// Devuelve null si la persona cancela.
  Future<ArchivoElegido?> elegir(OrigenArchivo origen);
}

class SelectorArchivosDispositivo implements SelectorArchivos {
  @override
  Future<ArchivoElegido?> elegir(OrigenArchivo origen) async {
    if (origen == OrigenArchivo.archivos) {
      final archivos = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ArchivoElegido.extensiones);
      if (archivos.isEmpty) return null;
      final archivo = archivos.first;
      return ArchivoElegido(nombre: archivo.name, tamano: await archivo.length() ?? 0);
    }
    final foto = await ImagePicker().pickImage(
      source: origen == OrigenArchivo.camara ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2400,
    );
    if (foto == null) return null;
    return ArchivoElegido(nombre: foto.name, tamano: await foto.length());
  }
}
