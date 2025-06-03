import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:riverpod/src/framework.dart';
import 'package:shoppa/core/models/cart_item.dart';
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/pages/products_pages/cart_page.dart';
import 'package:shoppa/services/manager/purchase_manager.dart';
import 'package:shoppa/services/provider/cart_provider.dart';

import 'cart_page_widget_test.mocks.dart'; // Generato da build_runner

// Genera i mock per i provider
@GenerateMocks([CartProvider, PurchaseManager])
void main() {
  group('CartPage Widget Test', () {
    late MockCartProvider mockCartProvider;
    late MockPurchaseManager mockPurchaseManager;

    setUp(() {
      mockCartProvider = MockCartProvider();
      mockPurchaseManager = MockPurchaseManager();

      // Mock dei comportamenti di default
      when(mockCartProvider.productsInCart).thenReturn([]);
      when(mockCartProvider.totalPrice).thenReturn(0.0);
      when(mockCartProvider.itemCount).thenReturn(0);
      when(mockCartProvider.clearCart()).thenAnswer((_) async {});

      // Removed: The method 'getLastPurchase' does not exist on PurchaseManager.
      // when(mockPurchaseManager.getLastPurchase()).thenReturn(null);
      when(mockPurchaseManager.purchases).thenReturn([]); // Mock the 'purchases' getter instead
      when(mockPurchaseManager.addPurchase(any, any)).thenAnswer((_) {}); // Mock addPurchase

    });

    testWidgets('should display empty cart message when cart is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Corrected: Use a function for overrideWith for ChangeNotifierProvider
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

      expect(find.text('Il tuo carrello è vuoto!'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('should display products and total when cart is not empty', (tester) async {
      final productA = Product(
          id: 1,
          title: 'Product A',
          description: 'Description A',
          price: 20.0,
          discountPercentage: 0.0,
          rating: 4.0,
          stock: 10,
          brand: 'Brand A',
          category: 'Category A',
          thumbnail: 'thumbA.jpg',
          images: ['imageA.jpg']);
      final productB = Product(
          id: 2,
          title: 'Product B',
          description: 'Description B',
          price: 40.0,
          discountPercentage: 0.0,
          rating: 4.5,
          stock: 5,
          brand: 'Brand B',
          category: 'Category B',
          thumbnail: 'thumbB.jpg',
          images: ['imageB.jpg']);

      final cartItems = [
        CartItem(product: productA, quantity: 1),
        CartItem(product: productB, quantity: 1),
      ];

      when(mockCartProvider.productsInCart).thenReturn(cartItems);
      when(mockCartProvider.totalPrice).thenReturn(60.0);
      when(mockCartProvider.itemCount).thenReturn(2);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Corrected: Use a function for overrideWith for ChangeNotifierProvider
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
      expect(find.text('60.00'), findsOneWidget); // Changed to match exact price display

      // Verifica che il pulsante "Procedi al Checkout" sia presente
      expect(find.text('Procedi al Checkout'), findsOneWidget);

      // Simula il tap sul pulsante "Procedi al Checkout"
      await tester.tap(find.text('Procedi al Checkout'));
      // Aggiunto pump per il dialog di caricamento e per il delay
      await tester.pump(); // Pump per mostrare il dialog
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processando l\'acquisto...'), findsOneWidget);

      // Simula il passaggio del delay di 0.5 secondi
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Dopo il delay, il dialog dovrebbe essere chiuso e lo SnackBar mostrato
      expect(find.byType(AlertDialog), findsNothing); // Dialog should be gone
      expect(find.byType(SnackBar), findsOneWidget); // SnackBar should be present
      expect(find.text('Grazie per l\'acquisto!'), findsOneWidget);

      // Verifica che addPurchase sia stato chiamato sul mock PurchaseManager
      verify(mockPurchaseManager.addPurchase(
        argThat(isA<List<CartItem>>().having((list) => list.length, 'length', 2)),
        60.0,
      )).called(1);

      // Verifica che clearCart sia stato chiamato sul mock CartProvider
      verify(mockCartProvider.clearCart()).called(1);

      // Attendi il pop della pagina (dopo un piccolo delay dello SnackBar)
      await tester.pumpAndSettle(const Duration(milliseconds: 100)); // Delay per il pop della pagina

      // Verifica che la pagina sia stata pop
      expect(find.byType(CartPage), findsNothing);
    });

    testWidgets('should decrease quantity when minus button is tapped', (tester) async {
      final productA = Product(
          id: 1,
          title: 'Product A',
          description: 'Description A',
          price: 20.0,
          discountPercentage: 0.0,
          rating: 4.0,
          stock: 10,
          brand: 'Brand A',
          category: 'Category A',
          thumbnail: 'thumbA.jpg',
          images: ['imageA.jpg']);
      final cartItem = CartItem(product: productA, quantity: 2);

      when(mockCartProvider.productsInCart).thenReturn([cartItem]);
      when(mockCartProvider.totalPrice).thenReturn(40.0);
      when(mockCartProvider.itemCount).thenReturn(2);
      // Mock the removeFromCart method
      when(mockCartProvider.removeFromCart(productA)).thenAnswer((_) {
        cartItem.quantity--; // Manually decrease quantity for mock consistency
        if (cartItem.quantity == 0) {
          when(mockCartProvider.productsInCart).thenReturn([]); // Simulate removal
          when(mockCartProvider.totalPrice).thenReturn(0.0);
          when(mockCartProvider.itemCount).thenReturn(0);
        } else {
          when(mockCartProvider.totalPrice).thenReturn(20.0); // Simulate new total
          when(mockCartProvider.itemCount).thenReturn(1);
        }
      });

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

      expect(find.text('2'), findsOneWidget); // Initial quantity
      expect(find.text('40.00'), findsOneWidget); // Initial total

      // Find the minus button for Product A
      final minusButton = find.descendant(
        of: find.byType(ListTile).at(0), // Assuming CartCard uses ListTile or similar structure
        matching: find.byIcon(Icons.remove_circle_outline),
      );
      await tester.tap(minusButton);
      await tester.pump(); // Rebuild after tap

      // Verify removeFromCart was called
      verify(mockCartProvider.removeFromCart(productA)).called(1);

      // After decrement, verify new quantity and total (if quantity > 1)
      expect(find.text('1'), findsOneWidget); // Quantity decreased
      expect(find.text('20.00'), findsOneWidget); // Total updated

      // Tap again to remove the last item
      await tester.tap(minusButton);
      await tester.pump();

      // Verify removeFromCart was called again
      verify(mockCartProvider.removeFromCart(productA)).called(2);

      // Now cart should be empty
      expect(find.text('Il tuo carrello è vuoto!'), findsOneWidget);
    });

    testWidgets('should increase quantity when plus button is tapped', (tester) async {
      final productA = Product(
          id: 1,
          title: 'Product A',
          description: 'Description A',
          price: 20.0,
          discountPercentage: 0.0,
          rating: 4.0,
          stock: 10,
          brand: 'Brand A',
          category: 'Category A',
          thumbnail: 'thumbA.jpg',
          images: ['imageA.jpg']);
      final cartItem = CartItem(product: productA, quantity: 1);

      when(mockCartProvider.productsInCart).thenReturn([cartItem]);
      when(mockCartProvider.totalPrice).thenReturn(20.0);
      when(mockCartProvider.itemCount).thenReturn(1);

      // Mock the addToCart method
      when(mockCartProvider.addToCart(productA)).thenAnswer((_) {
        cartItem.quantity++; // Manually increase quantity for mock consistency
        when(mockCartProvider.totalPrice).thenReturn(40.0); // Simulate new total
        when(mockCartProvider.itemCount).thenReturn(2);
      });

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

      expect(find.text('1'), findsOneWidget); // Initial quantity
      expect(find.text('20.00'), findsOneWidget); // Initial total

      // Find the plus button for Product A
      final plusButton = find.descendant(
        of: find.byType(ListTile).at(0),
        matching: find.byIcon(Icons.add_circle_outline),
      );
      await tester.tap(plusButton);
      await tester.pump(); // Rebuild after tap

      // Verify addToCart was called
      verify(mockCartProvider.addToCart(productA)).called(1);

      // After increment, verify new quantity and total
      expect(find.text('2'), findsOneWidget); // Quantity increased
      expect(find.text('40.00'), findsOneWidget); // Total updated
    });

    testWidgets('should remove all of product when delete button is tapped', (tester) async {
      final productA = Product(
          id: 1,
          title: 'Product A',
          description: 'Description A',
          price: 20.0,
          discountPercentage: 0.0,
          rating: 4.0,
          stock: 10,
          brand: 'Brand A',
          category: 'Category A',
          thumbnail: 'thumbA.jpg',
          images: ['imageA.jpg']);
      final cartItem = CartItem(product: productA, quantity: 2);

      when(mockCartProvider.productsInCart).thenReturn([cartItem]);
      when(mockCartProvider.totalPrice).thenReturn(40.0);
      when(mockCartProvider.itemCount).thenReturn(2);

      // Mock the removeAllOfProduct method
      when(mockCartProvider.removeAllOfProduct(productA)).thenAnswer((_) {
        when(mockCartProvider.productsInCart).thenReturn([]); // Simulate removal
        when(mockCartProvider.totalPrice).thenReturn(0.0);
        when(mockCartProvider.itemCount).thenReturn(0);
      });

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

      expect(find.text('Product A'), findsOneWidget);

      // Find the delete button for Product A (assuming it's a trash can icon)
      final deleteButton = find.descendant(
        of: find.byType(ListTile).at(0),
        matching: find.byIcon(Icons.delete_outline),
      );
      await tester.tap(deleteButton);
      await tester.pump(); // Rebuild after tap

      // Verify removeAllOfProduct was called
      verify(mockCartProvider.removeAllOfProduct(productA)).called(1);

      // Now cart should be empty
      expect(find.text('Il tuo carrello è vuoto!'), findsOneWidget);
      expect(find.text('Product A'), findsNothing);
    });
  });
}