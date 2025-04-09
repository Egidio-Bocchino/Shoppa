import 'package:flutter/material.dart';
import 'package:shoppa/core/config/theme/app_colors.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({super.key})
      : super(
    backgroundColor: AppColors.background,
    elevation: 0,
    title: const Text('SHOPPA'),
    titleTextStyle: const TextStyle(
      color: AppColors.primary,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    centerTitle: true,
    leading: SearchAnchor(
      searchController: SearchController(),
      builder: (BuildContext context, SearchController controller) {
        return IconButton(
          icon: const Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          onPressed: () {
            controller.openView();
          },
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        List<String> suggestions = List.generate(10, (index) => 'Item $index')
            .where((item) => item.toLowerCase().contains(controller.text.toLowerCase()))
            .toList();

        return suggestions.map((item) {
          return ListTile(
            title: Text(item),
            onTap: () {
              controller.closeView(item);
            },
          );
        }).toList();
      },
      viewBackgroundColor: AppColors.background,
    ),
  );
}