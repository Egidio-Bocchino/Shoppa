import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';
import 'package:shoppa/core/config/widget/custom_appbar.dart';
import 'package:shoppa/core/config/widget/custom_bottombar.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
