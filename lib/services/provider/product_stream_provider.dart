import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod/riverpod.dart';
import '../../core/exception/data_parsing_exception.dart';
import '../../core/exception/exception_handler.dart';
import '../../core/models/product_model.dart';

final productsStreamProvider = StreamProvider<List<Product>>((ref) {

  final productsRef = FirebaseDatabase.instance.ref().child('/products');

  return productsRef.onValue.map((event) {
    final DataSnapshot dataSnapshot = event.snapshot;
    final Object? rawData = dataSnapshot.value;

    final List<Product> products = <Product>[];

    if(rawData == null){
      ExceptionHandler.handle(
        'Raw data is null',
        null,
        context: 'productsStreamProvider',
        data: dataSnapshot.ref.path,
      );
      return products;
    }

    Iterable<Object?> productDataIterable;

    if (rawData is Map<dynamic, dynamic>) {
      productDataIterable = rawData.values;
    }
    else if (rawData is List<dynamic>) {
      productDataIterable = rawData;
    } else {
      throw DataParsingException(
        'Formato dati non supportato per i prodotti',
        data: rawData,
      );
    }

    for (var value in productDataIterable) {
      if(value is Map<dynamic, dynamic>){
        try{
          final Map<String, dynamic> productMap = Map<String, dynamic>.from(value);

          products.add(Product(
            id: productMap['id'] as int? ?? 0,
            title: productMap['title'] as String? ?? '',
            description: productMap['description'] as String? ?? '',
            price: (productMap['price'] as num?)?.toDouble() ?? 0,
            discountPercentage: (productMap['discountPercentage'] as num?)?.toDouble() ?? 0.0,
            rating: (productMap['rating'] as num?)?.toDouble() ?? 0.0,
            stock: productMap['stock'] as int? ?? 0,
            brand: productMap['brand'] as String? ?? '',
            category: productMap['category'] as String? ?? '',
            thumbnail: productMap['thumbnail'] as String? ?? '',
            images: List<String>.from(productMap['images'] as List<dynamic>? ?? []),
          ));
        }catch(e){
          throw DataParsingException(
            'Errore nel parsing di un prodotto: $e',
            data: value,
          );
        }
      }else{
        throw DataParsingException(
          'Elemento inatteso nel flusso dei dati: non è una mappa',
          data: value,
        );
      }
    }
    return products;
  });
});

final categoriesProvider = Provider<List<String>>((ref) {
  final productsAsyncValue = ref.watch(productsStreamProvider);

  return productsAsyncValue.when(
    data: (products) {
      final categories = <String>{};
      for (var product in products) {
        categories.add(product.category);
      }
      final List<String> sortedCategories = categories.toList()..sort();
      return sortedCategories;
    },
    loading: () {
      return [];
    },
    error: (error, stack) {
      if (error is DataParsingException) {
        ExceptionHandler.handleDataParsingException(error, stack, context: 'categoriesProvider');
      } else {
        ExceptionHandler.handle(error, stack, context: 'categoriesProvider: Errore Generico');
      }
      return [];
    },
  );
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');