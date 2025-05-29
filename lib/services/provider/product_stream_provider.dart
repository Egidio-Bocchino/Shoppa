import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod/riverpod.dart';
import '../../core/models/product_model.dart';

final productsStreamProvider = StreamProvider<List<Product>>((ref) {

  final productsRef = FirebaseDatabase.instance.ref().child('/products');

  // Ascolta lo stream degli eventi (come 'value' che si attiva sui cambiamenti)
  return productsRef.onValue.map((event) {
    final DataSnapshot dataSnapshot = event.snapshot;
    // dataSnapshot.value contiene i dati grezzi.
    // Sarà tipicamente una Map dove le chiavi sono gli ID dei prodotti
    // e i valori sono le Map che rappresentano i singoli prodotti.
    final Object? rawData = dataSnapshot.value;

    final List<Product> products = <Product>[];

    if (rawData == null) {
      return products;
    }

    Iterable<Object?> productDataIterable;

    // Controllo se rawData è una Map (come {"0": {...}, "1": {...}})
    if (rawData is Map<dynamic, dynamic>) {
      // Ottiengo i valori della Map e li converto in un Iterable
      productDataIterable = rawData.values;
    }
    // Controllo se rawData è una List (come direttamente un array [...])
    else if (rawData is List<dynamic>) {
      productDataIterable = rawData;
    } else {
      print('Formato dati non supportato per i prodotti: ${rawData.runtimeType}');
      return products; // Restituisco una lista vuota per formato sconosciuto
    }

    productDataIterable?.forEach((value) {
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
          print('Errore nel parsing del prodotto con chiave $e');
        }
      }else{
        print('Valore non valido per i prodotti: $value');
      }
    });
    return products;
  });
});

final categoriesProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(productsStreamProvider.stream).map((products) {
    final categories = <String>{};
    for (var product in products) {
      categories.add(product.category);
    }
    final List<String> sortedCategories = categories.toList()..sort();
    return sortedCategories;
  });
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final Map<String, List<double>?> discountRange = {
  'All': null,
  '10%' : [0, 15],
  '20%' : [16, 25],
  '30%' : [26, 44],
  '50%' : [45, 55],
};

final selectedDiscountProvider = StateProvider<String>((ref) => 'All');