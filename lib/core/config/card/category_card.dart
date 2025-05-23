import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';

import '../../../services/provider/product_stream_provider.dart';

class CategoryCard extends ConsumerWidget {
  final String category;
  CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = category;
      },
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