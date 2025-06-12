import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shoppa/main.dart' as app;
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/core/card/product_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    print('DEBUG TEST: Inizializzazione Firebase per il test...');
    await Firebase.initializeApp();
    print('DEBUG TEST: Firebase inizializzato per il test.');
  });

  group('End-to-end Test', () {
    testWidgets('Add random product to cart from Home Page', (WidgetTester tester) async {
      // ** 0. AUTENTICAZIONE FIREBASE **
      final String testEmail = 'test@test.test'; // <--- EMAIL DI TEST AGGIORNATA
      final String testPassword = 'testing'; // <--- PASSWORD DI TEST AGGIORNATA

      try {
        print('DEBUG TEST: Tentativo di sign-in con Firebase...');
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        print('DEBUG TEST: Sign-in Firebase riuscito.');
      } catch (e) {
        print('DEBUG TEST: Errore durante il sign-in Firebase: $e');
        fail('Impossibile effettuare il sign-in con Firebase: $e');
      }

      // 1. Avvia l'app in un contesto asincrono
      await tester.runAsync(() async {
        app.main();
      });
      await tester.pumpAndSettle();

      print('DEBUG TEST: Inizio attesa dinamica per GridView...');

      // 2. Attendi dinamicamente che il GridView sia presente
      final productGridKey = const Key('home_page_product_grid');
      Finder productGridFinder = find.byKey(productGridKey);

      bool gridFound = false;
      int maxAttempts = 150;
      int attempt = 0;

      while (!gridFound && attempt < maxAttempts) {
        await tester.pump(const Duration(milliseconds: 100));
        productGridFinder = find.byKey(productGridKey);
        if (tester.any(productGridFinder)) {
          gridFound = true;
          print('DEBUG TEST: GridView trovato dopo ${attempt * 100}ms');
        }
        attempt++;
      }

      if (!gridFound) {
        print('DEBUG TEST: GridView NON trovato dopo ${attempt * 100}ms (max attempts raggiunti).');
      }

      expect(productGridFinder, findsOneWidget, reason: 'Il GridView dei prodotti non è stato trovato dopo l\'attesa dinamica. Eventuali eccezioni non gestite durante il rendering: ${tester.takeException()}');

      final allProductCardsInGrid = find.descendant(
        of: productGridFinder,
        matching: find.byType(ProductCard),
      );

      expect(allProductCardsInGrid, findsAtLeast(1),
          reason: 'Nessun ProductCard trovato all\'interno del GridView. Nonostante i dati siano presenti, i prodotti non sono stati renderizzati come ProductCard.');

      final productCardFinder = allProductCardsInGrid.first;

      final Product productToTest = (tester.widget(productCardFinder) as ProductCard).product;
      final int productId = productToTest.id;
      print('DEBUG TEST: Tapping on Product with ID: $productId');

      // 3. Tocca il prodotto per navigare alla ProductDetailPage
      await tester.tap(productCardFinder);
      await tester.pumpAndSettle();

      // Verifica di essere sulla ProductDetailPage
      expect(find.text('Recensioni'), findsOneWidget);

      // 4. Trova il pulsante "Aggiungi al Carrello"
      final addToCartButtonFinder = find.byKey(Key('add_to_cart_button_product_$productId'));

      expect(addToCartButtonFinder, findsOneWidget);
      await tester.tap(addToCartButtonFinder);
      await tester.pump();

      // 5. Verifica che lo SnackBar di conferma appaia
      expect(find.textContaining('aggiunto al carrello!'), findsOneWidget);
      await tester.pumpAndSettle(); // Assicurati che lo SnackBar sparisca

      // *** NUOVA LOGICA: TORNA ALLA HOME PAGE PRIMA DI CERCARE LA BOTTOM NAV BAR ***
      print('DEBUG TEST: Tornando alla HomePage...');
      // Simula il tap sul pulsante "indietro" (freccia) nell'AppBar della ProductDetailPage
      await tester.pageBack(); // Questo chiama Navigator.pop(context)
      await tester.pumpAndSettle(); // Attendi il completamento dell'animazione di ritorno

      // Verifica di essere tornato sulla HomePage (cercando un elemento distintivo della HomePage)
      expect(find.text('Prodotti Consigliati'), findsOneWidget,
          reason: 'Non è stato possibile tornare alla HomePage dopo l\'aggiunta al carrello.');
      print('DEBUG TEST: Tornato alla HomePage.');

      // 6. Naviga al carrello DALLA HOME PAGE
      await tester.pumpAndSettle(); // Assicurati che la HomePage sia completamente renderizzata e la Bottom Nav Bar sia visibile
      final cartIconFinder = find.byKey(const Key('cart_icon_button'));

      expect(cartIconFinder, findsOneWidget, reason: 'L\'icona del carrello non è stata trovata nella Bottom Navigation Bar della HomePage.');
      await tester.tap(cartIconFinder);
      await tester.pumpAndSettle(); // Attendi la navigazione alla CartPage

      // 7. Verifica di essere sulla CartPage e che il prodotto sia nel carrello
      expect(find.text('Il tuo Carrello'), findsOneWidget);
      expect(find.text('Totale:'), findsOneWidget);
      // Puoi aggiungere una verifica più specifica, ad esempio:
      // expect(find.text(productToTest.title), findsOneWidget, reason: 'Il prodotto aggiunto non è presente nel carrello.');
    });
  });
}