import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppa/core/models/review_model.dart';
import '../../services/manager/review_manager.dart';
import '../exception/exception_handler.dart';
import '../theme/app_colors.dart';
import 'image_handler.dart';

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
  File? _currentImageInDialog;
  bool _isPickingImage = false;
  final ImageHandler _imageHandler = ImageHandler();

  @override
  void initState() {
    super.initState();
    _reviewController.text = '';
    currentRating = 0.0;
    _currentImageInDialog = null;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final File? pickedFile = await _imageHandler.pickImage(ImageSource.camera);

      if (!mounted) return;

      if (pickedFile != null) {
        setState(() {
          _currentImageInDialog = pickedFile;
        });
      }
    } catch (e, s) {
      ExceptionHandler.handle(e, s, context: 'ReviewDialog - _pickImageFromCamera');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Errore nella selezione dell\'immagine: ${e.toString()}', style: TextStyle(color: AppColors.background)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
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
              inactiveColor: AppColors.cardTextCol,
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
                hintStyle: TextStyle(color: AppColors.cardTextCol),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: AppColors.cardTextCol.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.cardColor,
              ),
              maxLines: 3,
              style: TextStyle(color: AppColors.cardTextCol),
              cursorColor: AppColors.primary,
            ),
            const SizedBox(height: 16),
            if (_currentImageInDialog == null)
              ElevatedButton.icon(
                onPressed: _isPickingImage ? null : _pickImageFromCamera,
                icon: _isPickingImage
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.cardTextCol,
                  ),
                )
                    : const Icon(Icons.camera_alt, color: AppColors.cardTextCol),
                label: Text(
                  _isPickingImage ? 'Caricamento...' : 'Aggiungi Foto',
                  style: TextStyle(color: AppColors.cardTextCol),
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
                      _currentImageInDialog!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _currentImageInDialog = null;
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
            Navigator.of(context).pop(null);
          },
          child: Text('Annulla', style: TextStyle(color: AppColors.primary)),
        ),
        ElevatedButton(
          onPressed: _isPickingImage
              ? null
              : () async {
            if (user == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.orange,
                    content: Text('Devi essere loggato per lasciare una recensione.', style: TextStyle(color: AppColors.background)),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
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

              await reviewManager.addReview(newReview, _currentImageInDialog);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.cardColor,
                    content: Text('Recensione aggiunta con successo!', style: TextStyle(color: AppColors.cardTextCol)),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop({'success': true});
              }
            } catch (e, s) {
              ExceptionHandler.handle(e, s, context: 'ReviewDialog - addReview');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Errore nell\'aggiunta della recensione: ${e.toString()}', style: TextStyle(color: AppColors.background)),
                    duration: const Duration(seconds: 3),
                  ),
                );
                Navigator.of(context).pop({'success': false});
              }
            }
          },
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.cardColor)),
          child: Text(
              'Invia Recensione',
              style: TextStyle(color: AppColors.cardTextCol)
          ),
        ),
      ],
    );
  }
}