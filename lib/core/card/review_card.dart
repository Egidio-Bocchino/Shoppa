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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isMyReview = currentUser != null && currentUser.uid == review.userId;

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
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Elimina Recensione'),
              content: const Text('Sei sicuro di voler eliminare questa recensione?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Elimina', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
        return confirmDelete ?? false;
      },
      onDismissed: (direction) async {
        try {
          await ref.read(reviewManagerProvider).deleteReview(review.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text('Recensione eliminata con successo!', style: TextStyle(color: AppColors.background)),
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          print('Errore eliminazione recensione tramite swipe: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Errore nell\'eliminazione della recensione: ${e.toString()}',
                style: TextStyle(color: AppColors.background)
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 36),
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

  Widget _buildReviewContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              review.userName,
              style: TextStyle(
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
            future: File(review.imageUrl!).exists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(review.imageUrl!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == false) {

                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                );
              }
              return const SizedBox.shrink(); // O un CircularProgressIndicator
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
}