import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import '../services/provider/cart_provider.dart';
import 'package:shoppa/core/models/product_model.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final productsInCart = cart.productsInCart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il tuo Carrello'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: productsInCart.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Il tuo carrello è vuoto!',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            Text(
              'Aggiungi alcuni prodotti per iniziare lo shopping.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          _listCart(productsInCart, ref),
          _checkOutButton(cart, context, ref),
        ],
      ),
    );
  }

  Padding _checkOutButton(CartProvider cart, BuildContext context, WidgetRef ref) {
    return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Totale:',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${cart.totalPrice.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.cardColor),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(vertical: 15.0)),
                  ),
                  onPressed: () {
                    Future.delayed(
                      const Duration(milliseconds: 500), () {
                      Navigator.pop(context);
                    });
                    ref.read(cartProvider).clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        elevation: 14,
                        backgroundColor: AppColors.cardColor,
                        content: Text('Grazie per l\'acquisto!', style: TextStyle(color: AppColors.cardTextCol),),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  },
                  child: const Text(
                    'Procedi al Checkout',
                    style: TextStyle(color: AppColors.cardTextCol, fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
  }

  Expanded _listCart(List<Product> productsInCart, WidgetRef ref) {
    return Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: productsInCart.length,
            itemBuilder: (context, index) {
              final product = productsInCart[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                color: AppColors.cardColor,
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          product.thumbnail,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.price.toStringAsFixed(2)} €',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: AppColors.cardTextCol,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          ref.read(cartProvider).removeFromCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.cardColor,
                              content: Text('${product.title} rimosso dal carrello!', style: TextStyle(color: AppColors.cardTextCol),),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
  }
}