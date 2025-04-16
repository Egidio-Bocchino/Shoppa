import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final double? price;
  final String? description;

  const ProductCard({
    Key? key,
    this.imageUrl,
    this.title,
    this.price,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Puoi usare AppColors.cardColor se preferisci
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: imageUrl != null
                    ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                )
                    : const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title ?? 'Nome non disponibile',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              price != null ? '${price?.toStringAsFixed(2)} €' : 'Prezzo non disponibile',
              style: TextStyle(color: AppColors.cardTextCol, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              description ?? 'Descrizione non disponibile',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}