/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shoppa/core/models/cart_item.dart';
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/pages/products_pages/cart_page.dart';
import 'package:shoppa/pages/products_pages/home_page.dart';
import 'package:shoppa/pages/products_pages/product_detail_page.dart';
import 'package:shoppa/services/manager/purchase_manager.dart';
import 'package:shoppa/services/provider/cart_provider.dart';
import 'package:shoppa/services/provider/product_stream_provider.dart';
import 'package:shoppa/core/card/product_card.dart'; // For finding ProductCard

// Import per Hive e path_provider
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shoppa/core/models/review_model.dart'; // Assicurati di importare il tuo modello Review

// Import DEL BINDING DI INTEGRAZIONE
import 'package:integration_test/integration_test.dart';

// Import del file main dell'app, in modo da poterlo avviare nel test
import 'package:shoppa/main.dart' as app;

// Import del file dei mock generati per questo test.
// Questo file verrà generato da build_runner nella stessa directory.
import 'app_integration_test.mocks.dart'; // <--- QUESTA È L'UNICA IMPORTAZIONE DEI MOCK NECESSARIA QUI

// Genera i mock solo per le classi che possono essere istanziate e i cui metodi possono essere sovrascritti.
// productsStreamProvider è un Provider globale, non una classe, quindi non viene mockato qui.
@GenerateMocks([CartProvider, PurchaseManager])
void main() {
  // Assicurati che il binding Flutter sia inizializzato prima di qualsiasi test.
  // Questo è essenziale per i test widget e di integrazione.
  WidgetsFlutterBinding.ensureInitialized();
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Inizializza Hive una sola volta prima di tutti i test
  setUpAll(() async {
    // Ottieni la directory dei documenti dell'applicazione per l'archiviazione di Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Registra l'adattatore ReviewAdapter se non è già registrato nel tuo main.dart
    // Questo è cruciale per permettere a Hive di gestire il tipo Review nei test
    if (!Hive.isAdapterRegistered(ReviewAdapter().typeId)) {
      Hive.registerAdapter(ReviewAdapter());
    }
  });

  group('Shopping App Integration Test', () {
    late MockCartProvider mockCartProvider;
    late MockPurchaseManager mockPurchaseManager;

    final testProduct1 = Product(
      id: 1,
      title: 'Product A',
      description: 'Description A',
      price: 20.0,
      discountPercentage: 10.0,
      rating: 4.5,
      stock: 10,
      brand: 'Brand A',
      category: 'Category A',
      thumbnail: 'https://via.placeholder.com/150',
      images: ['https://via.placeholder.com/150'],
    );

    final testProduct2 = Product(
      id: 2,
      title: 'Product B',
      description: 'Description B',
      price: 40.0,
      discountPercentage: 5.0,
      rating: 4.0,
      stock: 5,
      brand: 'Brand B',
      category: 'Category B',
      thumbnail: 'https://via.placeholder.com/150',
      images: ['https://via.placeholder.com/150'],
    );

    setUp(() {
      mockCartProvider = MockCartProvider();
      mockPurchaseManager = MockPurchaseManager();

      // Mock dei comportamenti di default per CartProvider
      when(mockCartProvider.productsInCart).thenReturn([]);
      when(mockCartProvider.totalPrice).thenReturn(0.0);
      when(mockCartProvider.itemCount).thenReturn(0);
      when(mockCartProvider.clearCart()).thenAnswer((_) async {});
      when(mockCartProvider.addToCart(any)).thenAnswer((invocation) {
        final product = invocation.positionalArguments[0] as Product;
        final currentItems = mockCartProvider.productsInCart.toList(); // Crea una copia mutabile
        final existingItemIndex = currentItems.indexWhere((item) => item.product.id == product.id);

        if (existingItemIndex != -1) {
          currentItems[existingItemIndex].quantity++;
        } else {
          currentItems.add(CartItem(product: product));
        }
        when(mockCartProvider.productsInCart).thenReturn(currentItems);
        when(mockCartProvider.itemCount).thenReturn(currentItems.fold(0, (sum, item) => sum + item.quantity));
        when(mockCartProvider.totalPrice).thenReturn(currentItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity)));
      });
      when(mockCartProvider.removeFromCart(any)).thenAnswer((invocation) {
        final product = invocation.positionalArguments[0] as Product;
        final currentItems = mockCartProvider.productsInCart.toList(); // Crea una copia mutabile
        final existingItemIndex = currentItems.indexWhere((item) => item.product.id == product.id);

        if (existingItemIndex != -1) {
          if (currentItems[existingItemIndex].quantity > 1) {
            currentItems[existingItemIndex].quantity--;
          } else {
            currentItems.removeAt(existingItemIndex);
          }
        }
        when(mockCartProvider.productsInCart).thenReturn(currentItems);
        when(mockCartProvider.itemCount).thenReturn(currentItems.fold(0, (sum, item) => sum + item.quantity));
        when(mockCartProvider.totalPrice).thenReturn(currentItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity)));
      });
      when(mockCartProvider.removeAllOfProduct(any)).thenAnswer((invocation) {
        final product = invocation.positionalArguments[0] as Product;
        final currentItems = mockCartProvider.productsInCart.toList(); // Crea una copia mutabile
        currentItems.removeWhere((item) => item.product.id == product.id);
        when(mockCartProvider.productsInCart).thenReturn(currentItems);
        when(mockCartProvider.itemCount).thenReturn(currentItems.fold(0, (sum, item) => sum + item.quantity));
        when(mockCartProvider.totalPrice).thenReturn(currentItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity)));
      });


      // Mock dei comportamenti di default per PurchaseManager
      when(mockPurchaseManager.addPurchase(any, any)).thenAnswer((_) async {});
    });

    testWidgets('Full shopping flow: Home -> ProductDetail -> Cart -> Checkout', (tester) async {
      // Avvia l'applicazione con gli override dei provider
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartProvider.overrideWith((ref) => mockCartProvider),
            purchaseManagerProvider.overrideWith((ref) => mockPurchaseManager),
            // Fornisci direttamente uno Stream.value per productsStreamProvider
            productsStreamProvider.overrideWith((ref) => Stream.value([testProduct1, testProduct2])),
          ],
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Verifica che HomePage sia visualizzata e i prodotti siano caricati
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('Product B'), findsOneWidget);

      // Naviga alla ProductDetailPage per Product A
      await tester.tap(find.byType(ProductCard).at(0));
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('Description A'), findsOneWidget);

      // Aggiungi Product A al carrello
      await tester.tap(find.byIcon(Icons.add_shopping_cart));
      await tester.pumpAndSettle();
      verify(mockCartProvider.addToCart(testProduct1)).called(1); // Verifica che addToCart sia stato chiamato

      // Simula alcuni cambiamenti di stato per il carrello per riflettere l'aggiunta
      when(mockCartProvider.productsInCart).thenReturn([CartItem(product: testProduct1, quantity: 1)]);
      when(mockCartProvider.itemCount).thenReturn(1);
      when(mockCartProvider.totalPrice).thenReturn(testProduct1.price);
      await tester.pumpAndSettle();

      // Naviga alla CartPage usando la barra di navigazione inferiore (assumendo che sia presente e funzionale)
      // Questo assume che CustomBottomNavigationBar abbia un'icona per il carrello.
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      expect(find.byType(CartPage), findsOneWidget);
      expect(find.text('Il tuo Carrello'), findsOneWidget);
      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('${testProduct1.price.toStringAsFixed(2)} €'), findsOneWidget); // Verifica il prezzo di Product A

      // Aggiungi un altro Product B al carrello dalla Home Page
      await tester.tap(find.byIcon(Icons.home)); // Torna alla home page (assumendo che l'icona home sia presente)
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ProductCard).at(1)); // Tocca Product B
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.text('Product B'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_shopping_cart));
      await tester.pumpAndSettle();
      verify(mockCartProvider.addToCart(testProduct2)).called(1);

      // Simula alcuni cambiamenti di stato per il carrello per riflettere l'aggiunta
      when(mockCartProvider.productsInCart).thenReturn([
        CartItem(product: testProduct1, quantity: 1),
        CartItem(product: testProduct2, quantity: 1)
      ]);
      when(mockCartProvider.itemCount).thenReturn(2);
      when(mockCartProvider.totalPrice).thenReturn(testProduct1.price + testProduct2.price);
      await tester.pumpAndSettle();


      // Torna alla pagina del carrello
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('Product B'), findsOneWidget);
      expect(find.text('Totale:'), findsOneWidget);
      expect(find.text((testProduct1.price + testProduct2.price).toStringAsFixed(2)), findsOneWidget);

      // Aumenta la quantità di Product A
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();
      verify(mockCartProvider.addToCart(testProduct1)).called(1); // Verifica che addToCart sia stato chiamato di nuovo per Product A
      // Simula il cambio di stato per la quantità aumentata
      when(mockCartProvider.productsInCart).thenReturn([
        CartItem(product: testProduct1, quantity: 2),
        CartItem(product: testProduct2, quantity: 1)
      ]);
      when(mockCartProvider.itemCount).thenReturn(3);
      when(mockCartProvider.totalPrice).thenReturn((testProduct1.price * 2) + testProduct2.price);
      await tester.pumpAndSettle();
      expect(find.text((testProduct1.price * 2 + testProduct2.price).toStringAsFixed(2)), findsOneWidget);


      // Rimuovi tutti i Product A
      await tester.tap(find.byKey(Key('delete_item_${testProduct1.id}')));
      await tester.pumpAndSettle();
      verify(mockCartProvider.removeAllOfProduct(testProduct1)).called(1);
      // Simula il cambio di stato dopo aver rimosso il prodotto A
      when(mockCartProvider.productsInCart).thenReturn([CartItem(product: testProduct2, quantity: 1)]);
      when(mockCartProvider.itemCount).thenReturn(1);
      when(mockCartProvider.totalPrice).thenReturn(testProduct2.price);
      await tester.pumpAndSettle();
      expect(find.text('Product A'), findsNothing);
      expect(find.text('Product B'), findsOneWidget);
      expect(find.text(testProduct2.price.toStringAsFixed(2)), findsOneWidget);


      // Procedi al Checkout
      await tester.tap(find.text('Procedi al Checkout'));
      await tester.pumpAndSettle();

      // Verifica che addPurchase sia stato chiamato
      verify(mockPurchaseManager.addPurchase(
        argThat(isA<List<CartItem>>().having((list) => list.length, 'length', 1)), // Aspettati 1 elemento rimanente
        testProduct2.price,
      )).called(1);

      // Verifica che clearCart sia stato chiamato
      verify(mockCartProvider.clearCart()).called(1);

      // Verifica che la snackbar sia mostrata
      expect(find.text('Grazie per l\'acquisto!'), findsOneWidget);

      // Verifica che il carrello sia vuoto dopo il checkout
      when(mockCartProvider.productsInCart).thenReturn([]);
      when(mockCartProvider.itemCount).thenReturn(0);
      when(mockCartProvider.totalPrice).thenReturn(0.0);
      await tester.pumpAndSettle();
      expect(find.text('Il tuo carrello è vuoto!'), findsOneWidget);
    });
  });
}*/
