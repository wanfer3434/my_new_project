import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class BannerUpload {
  // Función para seleccionar y subir múltiples imágenes
  static Future<void> pickAndUploadBanners(BuildContext context, VoidCallback onSuccess) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://javier.tail33d395.ts.net/upload_banner'), // Cambiar a tu endpoint
      );

      for (var file in result.files) {
        if (file.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'file', file.path!, filename: file.name
          ));
        }
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen(es) subida(s) correctamente!')),
        );
        onSuccess(); // Llamar la función que recarga banners
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir las imágenes')),
        );
      }
    }
  }

  // Widget del botón flotante
  static Widget uploadButton(BuildContext context, VoidCallback onSuccess) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: () => pickAndUploadBanners(context, onSuccess),
        child: const Icon(Icons.upload),
      ),
    );
  }
}
