import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/services/provider/product_stream_provider.dart';
import '../../../pages/filtered_page.dart';
import '../theme/app_colors.dart';

class DealCard extends ConsumerWidget {
  final String dealLabel;

  const DealCard({
    super.key,
    required this.dealLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDiscount = ref.watch(selectedDiscountProvider);


    return GestureDetector(
      onTap: () {
        ref.read(selectedDiscountProvider.notifier).state = dealLabel;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilteredPage(
              selectedDiscountRange: dealLabel,
              pageTitle: 'OFFERTE: "${dealLabel.toUpperCase()}"',
            ),
          ),
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
            dealLabel.toUpperCase(),
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