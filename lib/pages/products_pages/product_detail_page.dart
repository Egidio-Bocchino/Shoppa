import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/models/product_model.dart';
import '../../core/card/review_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widget/review_dialog.dart';
import '../../services/manager/review_manager.dart';
import '../../services/provider/cart_provider.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late String _currentMainImg;

  @override
  void initState(){
    super.initState();
    _currentMainImg = widget.product.thumbnail;
  }

  void _showReviewDialog(BuildContext context, Product product) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ReviewDialog(
          productId: product.id,
        );
      },
    );
    if (result != null && result.containsKey('success')) {
      if (result['success'] == true) {
        // Recensione aggiunta con successo.
        // La UI si aggiornerà automaticamente grazie a Riverpod e notifyListeners nel ReviewManager.
        // Puoi aggiungere qui un log o un feedback aggiuntivo se necessario.
      } else {
        // Errore nell'aggiunta della recensione.
        // Il dialog dovrebbe già aver mostrato un messaggio di errore.
      }
    }
  }

  @override
  Widget build(BuildContext contex) {
    final reviewManager = ref.watch(reviewManagerProvider);
    final productReviews = reviewManager.getReviewsForProduct(widget.product.id.toString());
    final cartRef = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title, style: TextStyle(color: AppColors.primary)),
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
                  _currentMainImg,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 150, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildImageGallery(widget.product.images),
            const SizedBox(height: 20),
            Text(
              widget.product.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\€${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Brand:', widget.product.brand),
            _buildDetailRow('Categoria:', widget.product.category),
            const SizedBox(height: 16),
            Text(
              widget.product.description,
              style: TextStyle(fontSize: 16.0, color: AppColors.cardTextCol),
            ),
            const SizedBox(height: 20),
            _cartButton(cartRef, context),
            const SizedBox(height: 16),
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
                ? const Text(
                  'Nessuna recensione disponibile per questo prodotto.',
                  style: TextStyle(color: AppColors.cardTextCol)
                  )
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
                _reviewsButton(context),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  SizedBox _reviewsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _showReviewDialog(context, widget.product),
        icon: const Icon(Icons.rate_review, color: AppColors.cardTextCol),
        label: const Text('Lascia una recensione', style: TextStyle(color: AppColors.cardTextCol)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  SizedBox _cartButton(CartProvider cartRef, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          cartRef.addToCart(widget.product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.cardColor,
              content: Text(
                  '${widget.product.title} aggiunto al carrello!',
                  style: TextStyle(color: AppColors.cardTextCol)
              ),
              duration: const Duration(milliseconds: 500),
            ),
          );
        },
        icon: const Icon(Icons.shopping_cart, color: AppColors.cardTextCol),
        label: const Text('Aggiungi al Carrello', style: TextStyle(color: AppColors.cardTextCol)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          final imageUrl = images[index];
          return GestureDetector(
            onTap: () {
             setState(() {
               _currentMainImg = imageUrl;
             });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
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