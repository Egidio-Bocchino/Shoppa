import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageHandler {
  final ImagePicker _picker = ImagePicker();

  /// Seleziona un'immagine da galleria o fotocamera.
  /// Restituisce un oggetto File? se l'immagine è stata selezionata, altrimenti null.
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Errore nella selezione dell\'immagine: $e');
    }
    return null;
  }

  /// Salva un'immagine localmente nell'area documenti dell'app.
  /// Restituisce il percorso del file salvato, o null in caso di errore.
  /// `fileNamePrefix` può essere usato per organizzare o dare un nome specifico ai file.
  Future<String?> saveImageLocally(File imageFile, String fileNamePrefix) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      /// Previene nomi di file duplicati aggiungendo timestamp e prefisso
      final String fileName = '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final File newImage = await imageFile.copy('$appDocPath/$fileName');
      return newImage.path;
    } catch (e) {
      print('Errore durante la copia dell\'immagine localmente: $e');
      return null;
    }
  }

  /// Elimina un file immagine locale.
  Future<void> deleteLocalImage(String? imagePath) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
          print('Local image deleted: $imagePath');
        }
      } catch (e) {
        print('Error deleting local image: $e');
      }
    }
  }
}