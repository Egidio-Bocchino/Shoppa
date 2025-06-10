import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shoppa/core/models/review_model.dart';
import 'package:uuid/uuid.dart';
import '../../core/widget/image_handler.dart';

class ReviewManager extends ChangeNotifier {
  late Box<Review> _reviewsBox;
  bool _isInitialized = false;
  final Uuid _uuid = Uuid();
  final ImageHandler _imageHandler = ImageHandler();

  ReviewManager() {
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isAdapterRegistered(ReviewAdapter().typeId)) {
      Hive.registerAdapter(ReviewAdapter());
    }
    _reviewsBox = await Hive.openBox<Review>('reviewsBox');
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  List<Review> get reviews => _reviewsBox.values.toList();

  List<Review> getReviewsForProduct(String productId) {
    if(!_isInitialized) {
      return [];
    }
    return _reviewsBox.values
        .where((review) => review.productId == productId)
        .toList();
  }

  Future<void> addReview(Review review, File? imageFile) async {
    if(!_isInitialized) {
      return;
    }

    final String newId = _uuid.v4();
    String? localImagePath;

    if (imageFile != null) {
      localImagePath = await _imageHandler.saveImageLocally(imageFile, 'review_${review.productId}');
    }

    final Review newReview = Review(
      id: newId,
      productId: review.productId,
      userId: review.userId,
      userName: review.userName,
      rating: review.rating,
      reviewText: review.reviewText,
      reviewDate: review.reviewDate,
      imageUrl: localImagePath,
    );

    await _reviewsBox.put(newId, newReview);
    notifyListeners();
  }

  Future<void> deleteReview(String reviewId) async {
    if(!_isInitialized) {
      return;
    }

    final Review? reviewToDelete = _reviewsBox.get(reviewId);
    if (reviewToDelete != null) {
      if (reviewToDelete.imageUrl != null && reviewToDelete.imageUrl!.isNotEmpty) {
        await _imageHandler.deleteLocalImage(reviewToDelete.imageUrl!);
      }
      await _reviewsBox.delete(reviewId);
      notifyListeners();
    }
  }
}

final reviewManagerProvider = ChangeNotifierProvider((ref) => ReviewManager());