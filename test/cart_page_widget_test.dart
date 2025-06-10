import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shoppa/core/models/cart_item.dart';
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/pages/products_pages/cart_page.dart';
import 'package:shoppa/services/manager/purchase_manager.dart';
import 'package:shoppa/services/provider/cart_provider.dart';
import 'package:shoppa/core/widget/custom_bottombar.dart';

import 'cart_page_widget_test.mocks.dart';

// Genera i mock per i provider
@GenerateMocks([CartProvider, PurchaseManager])
void main() {
  group('CartPage Widget Test', () {
    late MockCartProvider mockCartProvider;
    late MockPurchaseManager mockPurchaseManager;

    // Prodotti di esempio per il carrello
    final productA = Product(
      id: 1,
      title: 'Product A',
      description: 'Descrizione A',
      price: 20.00,
      discountPercentage: 0.0,
      rating: 4.0,
      stock: 10,
      brand: 'BrandA',
      category: 'CategoryA',
      thumbnail: 'thumbnailA.jpg',
      images: ['imageA1.jpg'],
    );

    final productB = Product(
      id: 2,
      title: 'Product B',
      description: 'Descrizione B',
      price: 40.00,
      discountPercentage: 0.0,
      rating: 4.0,
      stock: 5,
      brand: 'BrandB',
      category: 'CategoryB',
      thumbnail: 'thumbnailB.jpg',
      images: ['imageB1.jpg'],
    );

    setUp(() {
      mockCartProvider = MockCartProvider();
      mockPurchaseManager = MockPurchaseManager();

      // Mock dei comportamenti di default per un carrello vuoto
      when(mockCartProvider.productsInCart).thenReturn([]);
      when(mockCartProvider.totalPrice).thenReturn(0.0);
      when(mockCartProvider.itemCount).thenReturn(0);
      when(mockCartProvider.clearCart()).thenAnswer((_) async {});
      when(mockCartProvider.addListener(any)).thenAnswer((_) {});
      when(mockCartProvider.removeListener(any)).thenAnswer((_) {});

      // Mock dei comportamenti di default per PurchaseManager
      when(mockPurchaseManager.addPurchase(any, any)).thenAnswer((_) {});
      when(mockPurchaseManager.addListener(any)).thenAnswer((_) {});
      when(mockPurchaseManager.removeListener(any)).thenAnswer((_) {});
    });

    testWidgets('Mostra "Il tuo carrello è vuoto!" quando il carrello è vuoto', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartProvider.overrideWith((ref) => mockCartProvider),
            purchaseManagerProvider.overrideWith((ref) => mockPurchaseManager),
          ],
          child: const MaterialApp(
            home: CartPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Il tuo carrello è vuoto!'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('Procedi al Checkout'), findsNothing);
      expect(find.text('Totale:'), findsNothing);
    });

    testWidgets('Mostra i prodotti nel carrello e il totale quando il carrello non è vuoto', (WidgetTester tester) async {
      // Prepara i dati del carrello non vuoto
      final cartItems = [
        CartItem(product: productA, quantity: 1),
        CartItem(product: productB, quantity: 1),
      ];

      when(mockCartProvider.productsInCart).thenReturn(cartItems);
      when(mockCartProvider.totalPrice).thenReturn(60.00); // 20.00 + 40.00
      when(mockCartProvider.itemCount).thenReturn(2);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartProvider.overrideWith((ref) => mockCartProvider),
            purchaseManagerProvider.overrideWith((ref) => mockPurchaseManager),
          ],
          child: const MaterialApp(
            home: CartPage(),
          ),
        ),
      );

      // Attendi che il widget si stabilizzi (ad esempio, dopo il caricamento dei dati)
      await tester.pumpAndSettle();

      // Verifica che i prodotti siano visualizzati
      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('Product B'), findsOneWidget);
      expect(find.text('Totale:'), findsOneWidget);
      expect(find.text('60.00 €'), findsOneWidget); // Verifica il totale corretto

      // Verifica che il pulsante "Procedi al Checkout" sia presente
      expect(find.text('Procedi al Checkout'), findsOneWidget);
    });

    testWidgets('Il checkout svuota il carrello, aggiunge l\'acquisto e mostra snackbar', (WidgetTester tester) async {
      // Prepara i dati del carrello per il checkout
      final cartItems = [
        CartItem(product: productA, quantity: 1),
        CartItem(product: productB, quantity: 1),
      ];
      when(mockCartProvider.productsInCart).thenReturn(cartItems);
      when(mockCartProvider.totalPrice).thenReturn(60.00);

      // Abbiamo bisogno di un Navigator per testare pop()
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartProvider.overrideWith((ref) => mockCartProvider),
            purchaseManagerProvider.overrideWith((ref) => mockPurchaseManager),
          ],
          child: MaterialApp(
            home: Builder(
              // Utilizziamo un Builder per accedere al Navigator.of(context)
              builder: (context) {
                return Navigator(
                  // Usiamo un Navigator con una pagina iniziale
                  initialRoute: '/',
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute(builder: (context) => const CartPage());
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Assicurati che la pagina sia completamente renderizzata

      // Simula il tap sul pulsante "Procedi al Checkout"
      await tester.tap(find.text('Procedi al Checkout'));

      // Esegui un pump per permettere allo SnackBar di apparire
      // Il SnackBar viene mostrato immediatamente dopo il tap nel tuo codice
      // prima del Future.delayed e del Navigator.pop.
      await tester.pump();

      // Verifica che lo SnackBar sia visualizzato
      expect(find.text('Grazie per l\'acquisto!'), findsOneWidget);

      // Esegui pumpAndSettle per permettere al Future.delayed di completarsi
      // e al Navigator.pop di avvenire.
      await tester.pumpAndSettle();

      // Verifica che addPurchase sia stato chiamato sul mock PurchaseManager
      verify(mockPurchaseManager.addPurchase(
        argThat(isA<List<CartItem>>().having((list) => list.length, 'length', 2)),
        60.0,
      )).called(1);

      // Verifica che clearCart sia stato chiamato sul mock CartProvider
      verify(mockCartProvider.clearCart()).called(1);

      // Verifica che la navigazione sia avvenuta (la pagina è stata poppata)
      // Se la pagina è stata poppata, non dovremmo più trovare il titolo della pagina del carrello.
      expect(find.text('Il tuo Carrello'), findsNothing);
    });

    // Test per verificare che CustomBottomNavigationBar sia presente
    testWidgets('Mostra CustomBottomNavigationBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartProvider.overrideWith((ref) => mockCartProvider),
            purchaseManagerProvider.overrideWith((ref) => mockPurchaseManager),
          ],
          child: const MaterialApp(
            home: CartPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Il finder corretto per il tuo widget CustomBottomNavigationBar
      expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
    });
  });
}