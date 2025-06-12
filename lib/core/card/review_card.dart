import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/models/review_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/manager/review_manager.dart';
import '../theme/app_colors.dart';

class ReviewCard extends ConsumerWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  Future<bool> _fileExists(String? path) async {
    if (path == null || path.isEmpty) {
      return false;
    }
    try {
      return await File(path).exists();
    } catch (e) {
      print('Errore durante la verifica dell\'esistenza del file: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isMyReview = currentUser != null && currentUser.uid == review.userId;
    final reviewManager = ref.watch(reviewManagerProvider);

    Widget _buildReviewContent(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            review.reviewText.isNotEmpty ? review.reviewText : 'Nessun commento.',
            style: TextStyle(fontSize: 14, color: AppColors.cardTextCol),
          ),
          const SizedBox(height: 5),
          if (review.imageUrl != null && review.imageUrl!.isNotEmpty)
            FutureBuilder<bool>(
              future: _fileExists(review.imageUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(review.imageUrl!),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Errore di caricamento immagine da file: $error');
                          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                        },
                      ),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  );
                }
              },
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '${review.reviewDate.day}/${review.reviewDate.month}/${review.reviewDate.year}',
              style: TextStyle(fontSize: 12, color: AppColors.cardTextCol.withOpacity(0.7)),
            ),
          ),
        ],
      );
    }

    if (!isMyReview) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: AppColors.cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildReviewContent(context),
        ),
      );
    }

    return Dismissible(
      key: ValueKey(review.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        final bool? confirmDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Conferma Eliminazione', style: TextStyle(color: AppColors.primary),),
              content: const Text('Sei sicuro di voler eliminare questa recensione?', style: TextStyle(color: AppColors.cardTextCol),),
              backgroundColor: AppColors.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: AppColors.cardTextCol)
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annulla', style: TextStyle(color: AppColors.primary),),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Elimina', style: TextStyle(color: AppColors.primary),),
                ),
              ],
            );
          },
        );
        if (confirmDelete == true) {
          await reviewManager.deleteReview(review.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.cardColor,
              content: Text('Recensione eliminata', style: TextStyle(color: AppColors.cardTextCol))
            ),
          );
          return true;
        }
        return false;
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: AppColors.cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildReviewContent(context),
        ),
      ),
    );
  }
}