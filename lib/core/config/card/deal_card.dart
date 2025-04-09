import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';

class DealCard extends StatelessWidget {
  final String? deal;
  DealCard({super.key, this.deal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 60,
      child: Card(
        color: AppColors.cardColor,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  deal ?? 'deal vuoto',
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