import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/provider/cart_provider.dart';
import '../models/cart_item.dart';
import '../theme/app_colors.dart';

class CartCard extends ConsumerWidget {
  final CartItem item;

  const CartCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.cardColor,
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item.product.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Prezzo: ${item.product.price.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.cardTextCol,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Totale articolo: ${(item.product.price * item.quantity).toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.cardTextCol,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                        onPressed: () {
                          // Decrement quantity or remove if quantity is 1
                          ref.read(cartProvider).removeFromCart(item.product);
                        },
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Increment quantity
                          ref.read(cartProvider).addToCart(item.product);
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          ref.read(cartProvider).removeAllOfProduct(item.product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.cardColor,
                              content: Text('${item.product.title} rimosso dal carrello!', style: TextStyle(color: AppColors.cardTextCol),),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
