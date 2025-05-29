import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/models/product_model.dart';
import '../../core/card/review_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widget/review_dialog.dart';
import '../../services/manager/review_manager.dart';
import '../../services/provider/cart_provider.dart';

class ProductDetailPage extends ConsumerWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewManager = ref.watch(reviewManagerProvider);
    final productReviews = reviewManager.getReviewsForProduct(product.id.toString());
    final cartRef = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  product.thumbnail,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 150, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildImageGallery(product.images),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Brand:', product.brand),
            _buildDetailRow('Categoria:', product.category),
            _buildDetailRow('Stock:', product.stock.toString()),
            const SizedBox(height: 16),
            Text(
              product.description,
              style: TextStyle(fontSize: 16.0, color: AppColors.cardTextCol),
            ),
            const SizedBox(height: 20),
            Text(
              'Recensioni',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            productReviews.isEmpty
                ? const Text('Nessuna recensione disponibile per questo prodotto.', style: TextStyle(color: Colors.grey))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productReviews.length,
              itemBuilder: (context, index) {
                final review = productReviews[index];
                return ReviewCard(review: review);
              },
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    cartRef.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text('${product.title} aggiunto al carrello!', style: TextStyle(color: AppColors.background)),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart, color: AppColors.background),
                  label: const Text('Aggiungi al Carrello', style: TextStyle(color: AppColors.background)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ReviewDialog(productId: product.id),
                    );
                  },
                  icon: const Icon(Icons.rate_review, color: AppColors.background),
                  label: const Text('Lascia una recensione', style: TextStyle(color: AppColors.background)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                images[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.cardTextCol,
              ),
            ),
          ),
        ],
      ),
    );
  }
}