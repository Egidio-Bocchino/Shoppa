import 'package:flutter/material.dart';
import 'package:shoppa/core/config/card/product_card.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import 'package:shoppa/core/config/card/category_card.dart';
import 'package:shoppa/core/config/widget/custom_appbar.dart';
import 'package:shoppa/core/config/widget/custom_bottombar.dart';
import 'package:shoppa/core/config/card/deal_card.dart';

import '../models/product.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(),
      bottomNavigationBar: CustomBottomNavigationBar(),
      body: buildScreenView(),
    );
  }

  SingleChildScrollView buildScreenView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 30),
          buildDealCard(),
          SizedBox(height: 30),
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
          SizedBox(height: 20),
          buildCategoryCard(),
          SizedBox(height: 30),
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
          SizedBox(height: 20),
          buildProductCard(),
        ],
      ),
    );
  }

  GridView buildProductCard() {
    return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return ProductCard();
          },
        );
  }

  SingleChildScrollView buildCategoryCard() {
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

  SingleChildScrollView buildDealCard() {
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

  /*Widget buildProductCard() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore nel caricamento dei prodotti: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text('Nessun prodotto disponibile.'));
        } else {
          List<Product> products = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final product = products[index];
              return ProductCard(
                imageUrl: product.images?.isNotEmpty == true ? product.images![0] : null,
                title: product.title,
                price: product.price?.toDouble(),
                description: product.description,
              );
            },
          );
        }
      },
    );
  }*/

}