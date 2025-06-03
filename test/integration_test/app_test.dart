import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/main.dart' as app;
import 'package:shoppa/services/provider/cart_provider.dart';

// Per mockare SharedPreferences negli integration test, puoi usarlo solo se non hai inizializzato SharedPreferences in main()
// o se lo inizializzi in modo da poter iniettare il mock. Per integration test, spesso si usano i veri SharedPreferences.
// Se hai bisogno di mockare Firebase, SharedPrefs, ecc., gli integration test diventano complessi.
// Per semplicità in questo esempio, supponiamo che SharedPreferences funzioni realmente o sia inizializzato in un modo che non interferisce.
// In un vero test di integrazione, Firebase o SharedPrefs dovrebbero essere configurati per l'ambiente di test (es. un emulatore Firebase locale).

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end Test', () {
    testWidgets('Verify user can add product to cart and checkout', (tester) async {
      // 1. Avvia l'app
      app.main();
      await tester.pumpAndSettle(); // Attendi che l'app si avvii completamente e si stabilizzi

      // Considerazioni per l'Autenticazione:
      // Se la tua app ha un login, dovrai simulare il login qui.
      // Per esempio:
      // await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      // await tester.enterText(find.byType(TextFormField).at(1), 'password');
      // await tester.tap(find.byType(ElevatedButton));
      // await tester.pumpAndSettle();

      // Qui, per semplicità, supponiamo che l'app sia già autenticata o che ci sia un modo per bypassare il login per i test.
      // Se l'app inizia con `LoginPage`, la prima cosa che vedrai sarà `LoginPage`.
      // Dobbiamo navigare dalla login page alla home page o bypassare il login per testare il carrello.
      // Per un test di integrazione reale con Firebase, potresti voler impostare un emulatore Firebase locale.

      // Simuliamo un utente già loggato per raggiungere la home page.
      // Questo richiede di impostare un account test o di usare un mock temporaneo per Firebase Auth
      // (ma mockare in integration test è complesso e spesso vanifica l'integrazione reale).
      // Per questo esempio, bypassiamo la navigazione dal login e andiamo direttamente a simulare l'interazione con i prodotti.

      // Esempio: Assumiamo di essere già nella schermata dei prodotti.
      // Potresti dover aggiungere un metodo di navigazione fittizio o un'impostazione per i test.
      // Per ora, assumiamo di poter trovare un prodotto.

      // 2. Trova un prodotto e aggiungilo al carrello
      // Questo dipenderà dalla struttura della tua `HomePage` o `ProductsOverviewPage`
      // Supponiamo che ci sia un pulsante "Aggiungi al carrello" visibile per un prodotto specifico.
      // Per trovare un prodotto, potresti cercare un testo o un widget specifico.
      // Esempio: Trova il primo prodotto in una lista o una griglia.
      // Questo è un placeholder, dovrai adattarlo ai tuoi Finder specifici.

      // Assicurati che l'app sia caricata e che tu sia sulla pagina giusta (es. home page con i prodotti)
      // Se parti dalla `LoginPage`, dovrai prima simulare il login.
      // Esempio per simulare un login se `main()` avvia `MaterialApp(home: LoginPage())`:
      /*
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      // Ora dovresti essere nella home page o in una pagina successiva.
      */

      // Trova un bottone "Aggiungi al carrello" per un prodotto (se c'è)
      // Questo è un esempio, adatta il finder al tuo layout.
      // Ad esempio, se ogni prodotto ha un Text('Add to Cart'):
      // Final Finder addButton = find.text('Add to Cart').first; // Trova il primo bottone "Add to Cart"
      // Se hai un IconButton con un'icona del carrello:
      // final Finder addToCartButton = find.byIcon(Icons.add_shopping_cart).first; // Oppure cerca un'icona specifica

      // Dato che non abbiamo la struttura della tua pagina dei prodotti, simulo con un Finder generico:
      // Trova un modo per interagire con un prodotto, ad esempio un pulsante per aggiungerlo al carrello.
      // Qui sto simulando che un prodotto sia nella schermata iniziale e abbia un pulsante "Add to Cart".
      // Potresti aver bisogno di una `Key` o di un testo specifico per identificare il pulsante.

      // Simula l'aggiunta di un prodotto al carrello. Assicurati che l'elemento sia presente.
      // Esempio di un "Add to Cart" button sulla home page:
      // await tester.tap(find.byKey(const Key('add_to_cart_button_product_1'))); // Supponendo una chiave per il pulsante
      // await tester.pumpAndSettle(); // Aspetta che il carrello si aggiorni

      // Se hai una schermata dei prodotti, potresti navigarci prima
      // esempio: await tester.tap(find.byIcon(Icons.shopping_bag)); await tester.pumpAndSettle();
      // Poi aggiungere un prodotto.

      // Per questo test, simuliamo che un prodotto sia stato aggiunto.
      // Supponiamo che ci sia un pulsante "Cart" nella CustomBottomNavigationBar per navigare.
      // Quindi, prima aggiungiamo un elemento al carrello, poi navighiamo al carrello.

      // Aggiungiamo un prodotto fittizio direttamente al CartProvider (per test più rapidi senza UI product list)
      // Questo richiede di rendere il CartProvider accessibile globalmente per il test
      // In un vero integration test, si interagisce con la UI.
      // Per aggirare la mancanza della schermata dei prodotti:
      // app.main() inizializza ProviderScope. Possiamo accedere ai provider.
      // Questo è un "hack" per l'integration test: in un test reale, si dovrebbe interagire con la UI.
      // Commento il codice di sotto e ti mostro come farlo interagendo con la UI (idealmente)
      // o come mockare la lista dei prodotti se non ne hai una facilmente navigabile.

      // ***** Scenario 1: Interazione UI per aggiungere un prodotto (il modo preferito per integration test) *****
      // Per questo, dovresti avere una schermata dei prodotti navigabile da `main.dart`.
      // Ad esempio, se il primo tab del `CustomBottomNavigationBar` porta ai prodotti.
      // Naviga alla pagina dei prodotti (se non è la schermata iniziale)
      // await tester.tap(find.byIcon(Icons.home)); // O l'icona della tua pagina dei prodotti
      // await tester.pumpAndSettle();

      // Assumi che ci sia un prodotto visualizzato con un bottone "Aggiungi al carrello"
      // Se non hai prodotti hardcoded o un mock API setup, potresti dover mockare il servizio prodotti
      // o creare un prodotto fittizio nella tua UI per i test.
      // Per questo esempio, simulo il tap su un pulsante ipotetico:
      // await tester.tap(find.byKey(const Key('add_to_cart_button_product_1')));
      // await tester.pumpAndSettle();
      // expect(find.text('Prodotto aggiunto!'), findsOneWidget); // Se mostri uno snackbar

      // ***** Scenario 2: Test simulato per l'integrazione (se non hai UI di prodotti facilmente accessibile) *****
      // Questo approccio è meno "integration" e più un mix con unit test, ma può essere utile.
      // Richiede che il tuo main.dart sia wrapato da ProviderScope
      // e che tu possa accedere ai provider globalmente (non consigliato per app grandi, ma per test specifici va bene).
      // Dato che non abbiamo una UI completa dei prodotti per aggiungere, simuleremo l'aggiunta al carrello.
      // Questa parte è difficile da fare in un integration test senza un `ProductPage` con prodotti reali o mockati.

      // Per far funzionare questo integration test in modo significativo senza una `ProductPage` completa,
      // dobbiamo concentrarci sull'interazione con `CartPage` e `AccountPage` dopo aver "simulato"
      // che un prodotto è già nel carrello.

      // ---- REALE INTEGRATION TEST SCENARIO (con le pagine che hai) ----
      // Ipotizziamo che l'app parta e mostri la CustomBottomNavigationBar.
      // Naviga alla CartPage
      await tester.tap(find.byIcon(Icons.shopping_cart)); // L'icona del carrello nella bottom bar
      await tester.pumpAndSettle();

      // Assicurati che il carrello sia vuoto all'inizio del test (o puliscilo)
      expect(find.text('Il tuo carrello è vuoto!'), findsOneWidget);

      // NON possiamo aggiungere un prodotto al carrello direttamente dalla UI
      // perché non abbiamo la pagina dei prodotti (ProductsOverviewPage).
      // Per questo test, simuleremo che un prodotto sia stato aggiunto.
      // Per un vero integration test dovresti aggiungere un prodotto dalla UI.
      // PER TESTARE IL CHECKOUT, SIMULIAMO DI AVERE UN PRODOTTO NEL CARRELLO.

      // In un vero scenario, dovresti navigare alla pagina dei prodotti, trovare un prodotto e tappare il pulsante "aggiungi al carrello".
      // Poiché la tua app non ha la pagina dei prodotti fornita, mockiamo l'aggiunta.
      // Questo non è "pure" integration testing, ma è un compromesso.

      // Workaround: Inietta un prodotto nel carrello per il test
      final container = ProviderContainer(); // Crea un ProviderContainer per mockare
      final cartProviderInstance = container.read(cartProvider);
      final product = Product(
        id: 1, title: 'Test Product', description: 'Desc', price: 10.0,
        discountPercentage: 0.0, rating: 0.0, stock: 10, brand: 'Brand',
        category: 'Category', thumbnail: 'thumb.png', images: [],
      );
      cartProviderInstance.addToCart(product);
      container.dispose(); // Rilascia il container

      // Ritorna all'app e ri-pompa per riflettere i cambiamenti
      await tester.pumpAndSettle(); // Ricarica la UI dopo la modifica del provider

      // Naviga di nuovo alla CartPage per vedere il prodotto
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      expect(find.text('Product A'), findsOneWidget); // O il nome del tuo prodotto mockato
      expect(find.text('Procedi al Checkout'), findsOneWidget);

      // 3. Procedi al Checkout
      await tester.tap(find.text('Procedi al Checkout'));
      await tester.pumpAndSettle(); // Attendi la fine del pop e dello snackbar

      // 4. Verifica che il carrello sia stato svuotato
      expect(find.text('Il tuo carrello è vuoto!'), findsOneWidget);
      expect(find.text('Grazie per l\'acquisto!'), findsOneWidget); // Verifica lo SnackBar

      // 5. Naviga alla pagina dell'Account per verificare l'ultimo acquisto
      await tester.tap(find.byIcon(Icons.person)); // L'icona dell'account nella bottom bar
      await tester.pumpAndSettle();

      // Verifica che l'ultimo acquisto sia visualizzato (se la pagina lo mostra)
      // Questo dipende dal tuo `AccountPage` e se `purchaseManagerProvider` ha persistito l'acquisto.
      // Dato che `purchase_manager.dart` usa `SharedPreferences`, l'acquisto dovrebbe essere persistito.
      // In un ambiente di test reale, SharedPreferences potrebbe essere resettato tra i test.
      // Potresti dover mockare SharedPreferences anche qui o assicurarti che il contesto di test sia pulito.
      expect(find.text('Ultimo Acquisto'), findsOneWidget);
      expect(find.textContaining('Totale: 10.00 €'), findsOneWidget); // Verifica il totale
      expect(find.text('Product A (x1)'), findsOneWidget); // Verifica gli articoli

      // Verifica che la pagina Account abbia i bottoni Log out, Reset password, Delete account
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Reset password'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
    });

    testWidgets('Verify "Reset password" button shows snackbar', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Naviga alla pagina dell'Account
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      expect(find.text('Reset password'), findsOneWidget);

      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();

      expect(find.text('Funzionalità di reset password non ancora implementata.'), findsOneWidget);
    });

    // Test per il logout e delete account richiederebbero l'integrazione con Firebase Auth Mocks
    // che è un po' più complessa da configurare per un test di integrazione completo,
    // ma fattibile. Non la includo qui per mantenere la risposta più gestibile,
    // ma tieni presente che dovresti mockare Firebase Auth se non vuoi colpire un server reale.
  });
}