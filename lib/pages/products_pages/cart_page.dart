import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/card/cart_card.dart';
import '../../core/models/cart_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widget/custom_bottombar.dart';
import '../../services/provider/cart_provider.dart';
import 'package:shoppa/core/models/product_model.dart';
import '../../services/manager/purchase_manager.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final productsInCart = cart.productsInCart;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Il tuo Carrello'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),

      bottomNavigationBar: CustomBottomNavigationBar(),

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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: productsInCart.length,
              itemBuilder: (context, index) {
                final cartItem = productsInCart[index];
                return CartCard(item: cartItem);
              },
            ),
          ),
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
              key: const Key('checkout_button'),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(AppColors.cardColor),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(vertical: 15.0)),
              ),
              onPressed: () {
                final List<CartItem> itemsToPurchase = List.from(cart.productsInCart);
                final double purchasesTotalPrice = cart.totalPrice;

                ref.read(purchaseManagerProvider).addPurchase(itemsToPurchase, purchasesTotalPrice);

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

  Expanded _listCart(List<CartItem> productsInCart, WidgetRef ref) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: productsInCart.length,
        itemBuilder: (context, index) {
          final cartItem = productsInCart[index];
          return CartCard(item: cartItem);
        },
      ),
    );
  }
}