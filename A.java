import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shoppa/main.dart' as app; 
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/services/provider/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppa/services/provider/product_stream_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shoppa/firebase_options.dart';
import 'package:hive/hive.dart'; // Importa Hive
import 'package:hive_flutter/hive_flutter.dart'; // Importa hive_flutter
import 'package:hive_test/hive_test.dart'; // 🔴 NUOVO IMPORT: hive_test
import 'package:shoppa/core/models/review_model.dart'; // Assicurati di importare ReviewAdapter

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final testProduct = Product(
    id: 1, 
    title: 'Test Product Name',
    description: 'This is a test product for integration testing.',
    price: 19.99,
    discountPercentage: 0.1,
    rating: 4.5,
    stock: 10,
    brand: 'TestBrand',
    category: 'TestCategory',
    thumbnail: 'https://example.com/test_thumb.jpg',
    images: ['https://example.com/test_image_1.jpg'],
  );

  group('Cart Page End-to-End Test', () {
    setUpAll(() async {
      // 1. Inizializzazione Firebase per i test
      if (Firebase.apps.isEmpty) { 
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      // 2. Mocking SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // 🔴 3. Inizializzazione Hive usando hive_test
      await setUpHive(); // Questo inizializza Hive in un percorso temporaneo isolato

      // Registra l'adapter solo se non è già registrato
      if (!Hive.isAdapterRegistered(ReviewAdapter().typeId)) {
        Hive.registerAdapter(ReviewAdapter());
      }
    });

    // 🔴 Pulisci Hive dopo tutti i test nel gruppo
    tearDownAll(() async {
      await tearDownHive(); // Pulisce i dati di Hive creati dal test
    });

    testWidgets('Navigate to product, add to cart, navigate to cart, verify presence and checkout',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsStreamProvider.overrideWith((ref) => Stream.value([
                  testProduct,
                  Product(
                    id: 2,
                    title: 'Another Product',
                    description: '...',
                    price: 9.99,
                    discountPercentage: 0.05,
                    rating: 4.0,
                    stock: 5,
                    brand: 'BrandX',
                    category: 'CategoryY',
                    thumbnail: 'https://example.com/another_thumb.jpg',
                    images: ['https://example.com/another_image.jpg'],
                  ),
                ])),
          ],
          child: const app.MyApp(), // MyApp inizierà da SplashPage
        ),
      );

      // Gestione della SplashPage: Aspetta che la SplashPage completi la sua navigazione.
      await tester.pumpAndSettle(const Duration(seconds: 5)); 

      // A questo punto, la app dovrebbe essere sulla MainWrapperPage/HomePage
      expect(find.byType(CircularProgressIndicator), findsNothing, reason: 'Il caricamento dei prodotti dovrebbe essere terminato.');

      // --- SIMULAZIONE DELLA NAVIGAZIONE VERSO LA PRODUCT DETAIL PAGE ---
      final productCard = find.byKey(Key('product_card_${testProduct.id}'));
      expect(productCard, findsOneWidget, reason: 'Il prodotto test non è stato trovato nella HomePage');
      await tester.tap(productCard);
      await tester.pumpAndSettle(); // Attende la navigazione alla ProductDetailPage

      // --- AGGIUNTA DEL PRODOTTO AL CARRELLO DALLA PRODUCT DETAIL PAGE ---
      final addToCartButton = find.byKey(Key('add_to_cart_button_product_${testProduct.id}'));
      expect(addToCartButton, findsOneWidget, reason: 'Il pulsante "Aggiungi al Carrello" non è stato trovato');
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      final addToCartSnackBar = find.text('${testProduct.title} aggiunto al carrello!');
      expect(addToCartSnackBar, findsOneWidget, reason: 'SnackBar di aggiunta al carrello non apparsa');
      await tester.pumpAndSettle(const Duration(milliseconds: 500)); 

      // --- NAVIGAZIONE ALLA PAGINA DEL CARRELLO ---
      final cartButton = find.byKey(const Key('bottom_nav_cart_button'));
      expect(cartButton, findsOneWidget, reason: 'Il pulsante del carrello non è stato trovato nella bottom navigation bar');
      await tester.tap(cartButton);
      await tester.pumpAndSettle();

      // --- VERIFICA PRESENZA PRODOTTO NEL CARRELLO ---
      final findProductInCart = find.text(testProduct.title);
      expect(findProductInCart, findsOneWidget, reason: 'Il titolo del prodotto aggiunto non è presente nel carrello');

      final expectedTotalPrice = '${testProduct.price.toStringAsFixed(2)} €';
      final findTotalPrice = find.text(expectedTotalPrice);
      expect(findTotalPrice, findsOneWidget, reason: 'Il prezzo totale non corrisponde');

      // --- PROCEDI AL CHECKOUT ---
      final checkoutButton = find.byKey(const Key('checkout_button'));
      expect(checkoutButton, findsOneWidget, reason: 'Il pulsante "Procedi al Checkout" non è stato trovato');
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      // --- VERIFICA STATO DOPO CHECKOUT ---
      final emptyCartMessage = find.text('Il tuo carrello è vuoto!');
      expect(emptyCartMessage, findsOneWidget, reason: 'Il messaggio di carrello vuoto non è apparso dopo il checkout');

      final thankYouSnackBar = find.text('Grazie per l\'acquisto!');
      expect(thankYouSnackBar, findsOneWidget, reason: 'La SnackBar di ringraziamento non è apparsa');

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('Displays empty cart message when cart is initially empty',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsStreamProvider.overrideWith((ref) => Stream.value([
                  testProduct,
                  Product(
                    id: 2,
                    title: 'Another Product',
                    description: '...',
                    price: 9.99,
                    discountPercentage: 0.05,
                    rating: 4.0,
                    stock: 5,
                    brand: 'BrandX',
                    category: 'CategoryY',
                    thumbnail: 'https://example.com/another_thumb.jpg',
                    images: ['https://example.com/another_image.jpg'],
                  ),
                ])),
          ],
          child: const app.MyApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Gestione SplashPage

      final cartButton = find.byKey(const Key('bottom_nav_cart_button'));
      expect(cartButton, findsOneWidget);
      await tester.tap(cartButton);
      await tester.pumpAndSettle();

      expect(find.text('Il tuo carrello è vuoto!'), findsOneWidget);
      expect(find.text('Aggiungi alcuni prodotti per iniziare lo shopping.'), findsOneWidget);
      expect(find.byKey(const Key('checkout_button')), findsNothing);
    });
  });
}