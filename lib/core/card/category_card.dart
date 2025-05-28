import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/services/provider/product_stream_provider.dart';
import '../../../pages/filtered_page.dart';
import '../theme/app_colors.dart';

class CategoryCard extends ConsumerWidget {
  final String category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = category;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilteredPage(
              selectedCategory: category,
              pageTitle: 'PRODOTTI: "${category.toUpperCase()}"',
            ),
          )
        );
      },
      child: Card(
        color: AppColors.cardColor,
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            category.toUpperCase(),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
              color: AppColors.cardTextCol,
            ),
          ),
        ),
      ),
    );
  }
}