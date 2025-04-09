import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String? category;
  CategoryCard({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 80,
      child: Card(
        color: AppColors.cardColor,
        child: Center(
          child: Text(
            category ?? 'testo vuoto',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.cardTextCol,
            ),
          ),
        ),
      ),
    );
  }
}