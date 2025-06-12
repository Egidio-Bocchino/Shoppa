import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/pages/products_pages/product_detail_page.dart';
import '../../core/card/category_card.dart';
import '../../core/card/product_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widget/custom_appbar.dart';
import '../../core/widget/custom_bottombar.dart';
import '../../services/provider/product_stream_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: _buildScreenView(),
    );
  }

  Widget _buildScreenView() {

    final productsAsyncValue = ref.watch(productsStreamProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      backgroundColor: AppColors.primary,
      color: AppColors.background,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categorie',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildCategoryCards(),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Prodotti Consigliati',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
      
            const SizedBox(height: 20),
      
            _productGrid(productsAsyncValue),
          ],
        ),
      ),
    );
  }

  Widget _productGrid(AsyncValue<List<Product>> productsAsyncValue) {
    return SizedBox(
      child: productsAsyncValue.when(
        loading: () {
          return const Center(
              child: CircularProgressIndicator()
          );
        },
        error: (error, stack) {
          return Center(
              child: Text('Errore nel caricamento dei prodotti: $error')
          );
        },
        data: (products) {
          final random = Random();
          final List<Product> shuffledProducts = List.from(products);
          shuffledProducts.shuffle(random);

          final List<Product> displayedProducts = shuffledProducts.take(10).toList();

          if (displayedProducts.isEmpty) {
            return const Center(child: Text('Nessun prodotto trovato.'));
          }

          return GridView.builder(
            key: const Key('home_page_product_grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisExtent: 250,
              mainAxisSpacing: 10,
            ),
            itemCount: displayedProducts.length,
            itemBuilder: (context, index) {
              final product = displayedProducts[index];

              return ProductCard(
                key: Key('product_card_${product.id}'),
                product: product,
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductDetailPage(product: product)
                      )
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  _buildCategoryCards() {
    final categories = ref.watch(categoriesProvider);

    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Nessuna categoria disponibile.',
          style: TextStyle(color: AppColors.cardTextCol),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
        children: categories.map((category) => CategoryCard(category: category)).toList(),
      ),
    );
  }


  Future<void> _onRefresh() async{
    ref.invalidate(productsStreamProvider);
    ref.invalidate(categoriesProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }
}