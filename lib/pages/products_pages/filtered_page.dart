import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/pages/products_pages/product_detail_page.dart';
import '../../core/card/product_card.dart';
import '../../core/theme/app_colors.dart';
import '../../services/provider/product_stream_provider.dart';

class FilteredPage extends ConsumerWidget{
  final String? selectedCategory;
  final String? selectedDiscountRange;
  final String pageTitle;

  const FilteredPage({
    super.key,
    this.selectedCategory,
    this.selectedDiscountRange,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: Text(pageTitle, style: const TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),

      body: productsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore nel caricamento dei prodotti: $error')),
        data: _filterBuilder,
      ),
    );
  }

  Widget? _filterBuilder(List<dynamic> products) {
    final filteredProducts = products.where((product) {
      bool matchesCategory = true;
      if (selectedCategory != null){
        matchesCategory = product.category.toLowerCase() == selectedCategory!.toLowerCase();
      }


      return matchesCategory;
    }).toList();

    if (filteredProducts.isEmpty) {
      String message = 'Nessun prodotto disponibile';
      if (selectedCategory != null) {
        message += ' per la categoria "$selectedCategory"';
      }
      return Center(child: Text(message.toUpperCase(),));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisExtent: 250,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          }
        );
      },
    );
  }
}