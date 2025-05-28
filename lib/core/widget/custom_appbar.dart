import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pages/product_detail_page.dart';
import '../../../services/provider/search_provider.dart';
import '../theme/app_colors.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchManager = ref.watch(productSearchManagerProvider);
    final SearchController searchController = SearchController();

    return AppBar(
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
        searchController: searchController,
        dividerColor: AppColors.primary,
        headerHintStyle: const TextStyle(color: AppColors.primary),
        headerTextStyle: const TextStyle(color: AppColors.primary),
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
          final query = controller.text;
          final filteredProductsAsyncValue = searchManager.searchProducts(query);

          return filteredProductsAsyncValue.when(
            data: (products) {
              return products.map((product) {
                return ListTile(
                  title: Text(
                    product.title,
                    style: TextStyle(color: AppColors.primary),
                  ),
                  onTap: () {
                    controller.closeView(product.title);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)));
                  },
                );
              }).toList();
            },
            loading: () => [
              const ListTile(title: Text('Caricamento prodotti...'))
            ],
            error: (err, stack) => [
              ListTile(title: Text('Errore nel caricamento dei prodotti: $err'))
            ],
          );
        },
        viewBackgroundColor: AppColors.background,
        viewLeading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        viewTrailing: <Widget>[
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.primary),
            onPressed: () {
              searchController.clear();
              searchController.closeView(null);
            },
          ),
        ],
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.text,
      ),
    );
  }
}