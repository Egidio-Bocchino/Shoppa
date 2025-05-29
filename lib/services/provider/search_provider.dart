import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/services/provider/product_stream_provider.dart';

class SearchProvider{
  final Ref _ref;

  SearchProvider(this._ref);

  AsyncValue<List<Product>> searchProducts(String query) {
    final products = _ref.watch(productsStreamProvider);

    return products.when(
      data: (products) {
        if(query.isEmpty){
          return AsyncValue.data([]);
        }
        final filteredProducts = products.where(
                (product) => product.title.toLowerCase().contains(query.toLowerCase())
        ).toList();
        return AsyncValue.data(filteredProducts);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  }
}


final productSearchManagerProvider = Provider<SearchProvider>((ref) {
  return SearchProvider(ref);
});