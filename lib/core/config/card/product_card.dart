import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String? product;
  ProductCard({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 100,
      child: Card(
        color: AppColors.cardColor,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  product ?? 'prodotto vuoto',
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.cardTextCol,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
