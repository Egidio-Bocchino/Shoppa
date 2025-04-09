import 'package:flutter/material.dart';
import 'package:shoppa/core/config/card/product_card.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import 'package:shoppa/core/config/card/category_card.dart';
import 'package:shoppa/core/config/widget/custom_appbar.dart';
import 'package:shoppa/core/config/widget/custom_bottombar.dart';
import 'package:shoppa/core/config/card/deal_card.dart';

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DealCard(deal: '10% OFF'),
                DealCard(deal: '20% OFF'),
                DealCard(deal: '30% OFF'),
                DealCard(deal: '50% OFF'),
              ],
            ),
          ),
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
          SingleChildScrollView(
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
          ),
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
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) {
              return ProductCard();
            },
          ),
        ],
      ),
    );
  }
}