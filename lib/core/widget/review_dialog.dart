import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppa/core/models/review_model.dart';
import '../../services/manager/review_manager.dart';
import '../theme/app_colors.dart';

class ReviewDialog extends ConsumerStatefulWidget {
  final int productId;

  const ReviewDialog({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends ConsumerState<ReviewDialog> {
  final TextEditingController _reviewController = TextEditingController();
  double currentRating = 0.0;
  File? _selectedImage;
  bool _isPickingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  /// Seleziona un'immagine dalla fotocamera
  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
    });
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Errore nella selezione dell\'immagine dalla fotocamera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Errore nella selezione dell\'immagine: ${e.toString()}', style: TextStyle(color: AppColors.background)),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final reviewManager = ref.watch(reviewManagerProvider);

    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(
        'Aggiungi una recensione',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Voto: ',
              style: TextStyle(
                color: AppColors.cardTextCol,
                fontSize: 16,
              ),
            ),
            Slider(
              value: currentRating,
              min: 0.0,
              max: 5.0,
              divisions: 5,
              label: currentRating.toString(),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.cardColor,
              onChanged: (newValue) {
                setState(() {
                  currentRating = newValue;
                });
              },
            ),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Scrivi la tua recensione...',
                hintStyle: TextStyle(color: AppColors.cardTextCol.withOpacity(0.6)),
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
              style: TextStyle(color: AppColors.cardTextCol),
            ),
            const SizedBox(height: 16),
            if (_selectedImage == null)
              ElevatedButton.icon(
                onPressed: _isPickingImage ? null : _pickImage,
                icon: _isPickingImage
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
                    : const Icon(Icons.camera_alt, color: AppColors.primary),
                label: Text(
                  _isPickingImage ? 'Caricamento...' : 'Aggiungi Foto',
                  style: TextStyle(color: AppColors.primary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            else
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      _selectedImage!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Annulla', style: TextStyle(color: AppColors.primary)),
        ),
        ElevatedButton(
          onPressed: _isPickingImage
              ? null
              : () async {
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Devi essere loggato per aggiungere una recensione!', style: TextStyle(color: AppColors.background)),
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            try {
              final newReview = Review(
                id: '',
                productId: widget.productId.toString(),
                userId: user.uid,
                userName: user.displayName ?? user.email ?? 'Anonimo',
                rating: currentRating,
                reviewText: _reviewController.text.trim(),
                reviewDate: DateTime.now(),
                imageUrl: null,
              );

              await reviewManager.addReview(newReview, _selectedImage);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primary,
                  content: Text('Recensione aggiunta con successo!', style: TextStyle(color: AppColors.background)),
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.of(context).pop();
            } catch (e) {
              print('Errore aggiunta recensione locale: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Errore nell\'aggiunta della recensione: ${e.toString()}', style: TextStyle(color: AppColors.background)),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: Text('Invia Recensione', style: TextStyle(color: AppColors.cardTextCol)),
        ),
      ],
    );
  }
}