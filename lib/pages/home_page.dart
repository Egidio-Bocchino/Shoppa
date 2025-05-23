import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import 'package:shoppa/core/config/card/category_card.dart';
import 'package:shoppa/core/config/widget/custom_appbar.dart';
import 'package:shoppa/core/config/widget/custom_bottombar.dart';
import 'package:shoppa/core/config/card/deal_card.dart';
import 'package:shoppa/core/config/card/product_card.dart';
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/pages/product_detail_page.dart';
import '../services/provider/product_stream_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

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
    final categories = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildDealCard(),
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
          _buildCategoryCard(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Prodotti',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _productGrid(productsAsyncValue,),
        ],
      ),
    );
  }

  SizedBox _productGrid(AsyncValue<List<Product>> productsAsyncValue) {
    return SizedBox(
      child: productsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Errore nel caricamento dei prodotti: $error')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('Nessun prodotto trovato.'));
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisExtent: 250,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
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

  Widget _buildCategoryCard() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryCard(category: 'SmartPhone'),
          CategoryCard(category: 'Laptops'),
          CategoryCard(category: 'Fragrances'),
          CategoryCard(category: 'Home-Deco'),
          CategoryCard(category: 'Groceries'),
          CategoryCard(category: 'SkinCare'),
        ],
      ),
    );
  }

  Widget _buildDealCard() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          DealCard(deal: '10% OFF'),
          DealCard(deal: '20% OFF'),
          DealCard(deal: '30% OFF'),
          DealCard(deal: '50% OFF'),
        ],
      ),
    );
  }
}