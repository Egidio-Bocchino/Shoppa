import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shoppa/core/models/review_model.dart';
import 'package:uuid/uuid.dart';

class ReviewManager extends ChangeNotifier {
  late Box<Review> _reviewsBox;
  final Uuid _uuid = Uuid();

  // Costruttore
  ReviewManager() {
    _initHive();
  }

  // Metodo di inizializzazione di Hive (private)
  Future<void> _initHive() async {
    // Assicurati che ReviewAdapter sia registrato prima di aprire il box
    // Questo controllo previene errori se l'adapter è già stato registrato (es. in main.dart)
    if (!Hive.isAdapterRegistered(ReviewAdapter().typeId)) {
      Hive.registerAdapter(ReviewAdapter());
    }
    _reviewsBox = await Hive.openBox<Review>('reviewsBox'); // Nome del box per le recensioni
    // Notifica i listener subito dopo che il box è stato aperto e i dati caricati
    notifyListeners();
  }

  // Getter per la lista di tutte le recensioni
  List<Review> get reviews => _reviewsBox.values.toList();

  // Metodo per ottenere le recensioni di un prodotto specifico
  List<Review> getReviewsForProduct(String productId) {
    return _reviewsBox.values
        .where((review) => review.productId == productId)
        .toList()
      ..sort((a, b) => b.reviewDate.compareTo(a.reviewDate)); // Ordina per data, più recente prima
  }

  // Metodo helper per ottenere il percorso della directory dei documenti dell'app
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Metodo per aggiungere una recensione
  Future<void> addReview(Review review, File? imageFile) async {
    String? localImagePath;
    if (imageFile != null) {
      try {
        // Genera un nome file unico per l'immagine
        final String imageFileName = '${_uuid.v4()}.png';
        // Costruisce il percorso completo per salvare l'immagine
        final String imagePath = '${await _getLocalPath()}/$imageFileName';
        // Copia il file immagine selezionato nel nuovo percorso
        final File newImage = await imageFile.copy(imagePath);
        localImagePath = newImage.path;
      } catch (e) {
        print('Error saving image locally: $e');
        // Qui potresti voler gestire l'errore, es. non salvare la recensione se l'immagine non può essere salvata
      }
    }

    final String newId = _uuid.v4(); // Genera un ID unico per la recensione
    final newReview = Review(
      id: newId,
      productId: review.productId,
      userId: review.userId,
      userName: review.userName,
      rating: review.rating,
      reviewText: review.reviewText,
      reviewDate: review.reviewDate,
      imageUrl: localImagePath, // Ora è il percorso locale del file immagine
    );

    // Salva la recensione nel box di Hive usando l'ID come chiave
    await _reviewsBox.put(newId, newReview);
    notifyListeners(); // Notifica i widget che osservano ReviewManager
  }

  // Metodo per eliminare una recensione
  Future<void> deleteReview(String reviewId) async {
    final Review? reviewToDelete = _reviewsBox.get(reviewId); // Ottieni la recensione dal box
    if (reviewToDelete != null) {
      if (reviewToDelete.imageUrl != null && reviewToDelete.imageUrl!.isNotEmpty) {
        try {
          final File imageFile = File(reviewToDelete.imageUrl!);
          if (await imageFile.exists()) {
            await imageFile.delete(); // Elimina il file immagine locale
            print('Local image deleted: ${reviewToDelete.imageUrl}');
          }
        } catch (e) {
          print('Error deleting local image: $e');
        }
      }
      await _reviewsBox.delete(reviewId); // Elimina la recensione dal box di Hive
      notifyListeners(); // Notifica i widget che osservano ReviewManager
    }
  }

// Puoi aggiungere altri metodi come updateReview se necessario
}

// Definisci un Provider per ReviewManager usando Riverpod
final reviewManagerProvider = ChangeNotifierProvider<ReviewManager>((ref) {
  return ReviewManager();
});