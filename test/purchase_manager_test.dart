import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppa/core/models/cart_item.dart';
import 'package:shoppa/core/models/product_model.dart';
import 'package:shoppa/core/models/purchase_model.dart';
import 'package:shoppa/services/manager/purchase_manager.dart';

import 'purchase_manager_test.mocks.dart'; // Generato da build_runner

@GenerateMocks([SharedPreferences])
void main() {
  group('PurchaseManager', () {
    late MockSharedPreferences mockSharedPreferences;
    late PurchaseManager purchaseManager;

    // Imposta SharedPreferences per i test
    setUp(() async {
      mockSharedPreferences = MockSharedPreferences();
      // Mock del getter SharedPreferences.getInstance()
      SharedPreferences.setMockInitialValues({}); // Inizializza con un valore vuoto per i test
      when(mockSharedPreferences.getString(any)).thenReturn(null); // Di default non ci sono acquisti salvati
      // Quando viene chiamato getString, possiamo controllare cosa restituisce
      when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);

      // Inizializza PurchaseManager con il mock di SharedPreferences
      // Questo è un workaround per mockare SharedPreferences.getInstance()
      // In un'applicazione reale, potresti iniettare SharedPreferences tramite un costruttore o un provider per facilitare il testing.
      // Per questo test, useremo il mock globale di SharedPreferences.
      // Dobbiamo re-inizializzare il manager per ogni test per assicurarci uno stato pulito.
      // Inizializza SharedPreferences in modo che PurchaseManager lo trovi
      // Questo è un po' hacky, in scenari reali si preferirebbe Dependency Injection.
      // Considera di modificare PurchaseManager per accettare SharedPreferences nel costruttore.
      // Per ora, ci affidiamo a setMockInitialValues e ai mock delle chiamate statiche.
      SharedPreferences.setMockInitialValues({}); // Assicurati che sia vuoto all'inizio di ogni test
      purchaseManager = PurchaseManager();
      await purchaseManager.loadPurchases(); // Carica gli acquisti all'inizializzazione
    });

    test('should add a purchase and retrieve the last one', () async {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'Description',
        price: 10.0,
        discountPercentage: 0.1,
        rating: 4.5,
        stock: 100,
        brand: 'Brand',
        category: 'Category',
        thumbnail: 'thumbnail.png',
        images: ['image1.png'],
      );
      final cartItem = CartItem(product: product, quantity: 2);
      final items = [cartItem];
      final totalPrice = 20.0;

      // Imposta il mock per quando addPurchase chiama _savePurchases
      when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);

      purchaseManager.addPurchase(items, totalPrice);

      // Aspetta che le operazioni asincrone di salvataggio siano completate (se ce ne sono)
      // Non è strettamente necessario qui perché _savePurchases è mockato per essere sincrono nel test,
      // ma è una buona pratica se l'implementazione reale fosse più complessa.
      await Future.microtask(() {}); // Permetti ai microtasks di completare

      final lastPurchase = purchaseManager.getList();

      expect(lastPurchase, isNotNull);
      expect(lastPurchase!.totalPrice, totalPrice);
      expect(lastPurchase.items.length, 1);
      expect(lastPurchase.items.first.product.title, 'Test Product');

      // Verifica che _savePurchases sia stato chiamato
      // Nota: mockSharedPreferences non è direttamente usato dal PurchaseManager a meno che non gli venga iniettato.
      // Qui stiamo testando il comportamento di PurchaseManager che si aspetta SharedPrefs.
      // Se vuoi testare l'interazione con SharedPreferences, PurchaseManager dovrebbe prendere SharedPreferences come dipendenza.
      // Per questo test, ci focalizziamo sulla logica interna del manager.
    });

    test('should return null if no purchases have been made', () {
      final lastPurchase = purchaseManager.getList();
      expect(lastPurchase, isNull);
    });

    test('should load purchases from SharedPreferences on initialization', () async {
      // Dati JSON fittizi per gli acquisti
      final String savedPurchasesJson = '''
      [
        {
          "id": "1",
          "items": [
            {
              "product": {
                "id": 1,
                "title": "Loaded Product",
                "description": "Desc",
                "price": 50.0,
                "discountPercentage": 0.0,
                "rating": 0.0,
                "stock": 0,
                "brand": "Brand",
                "category": "Cat",
                "thumbnail": "",
                "images": []
              },
              "quantity": 1
            }
          ],
          "totalPrice": 50.0,
          "purchaseDate": "${DateTime.now().toIso8601String()}"
        }
      ]
      ''';

      // Mocka il comportamento di SharedPreferences.getInstance() per restituire un mock
      // Questo richiede che PurchaseManager accetti SharedPreferences nel costruttore
      // oppure che SharedPreferences.getInstance() sia mockabile in modo più diretto.
      // Poiché SharedPreferences.getInstance() è statico, l'approccio comune è usare
      // `SharedPreferences.setMockInitialValues` e poi fare delle verifiche sullo stato
      // interno del manager dopo l'inizializzazione.

      SharedPreferences.setMockInitialValues({
        'user_purchases': savedPurchasesJson, // Assicurati che la chiave sia la stessa di PurchaseManager
      });

      final loadedPurchaseManager = PurchaseManager();
      await loadedPurchaseManager.loadPurchases(); // Chiamiamo esplicitamente per forzare il caricamento

      expect(loadedPurchaseManager.purchases.length, 1);
      expect(loadedPurchaseManager.purchases.first.totalPrice, 50.0);
      expect(loadedPurchaseManager.purchases.first.items.first.product.title, 'Loaded Product');
    });

    test('should clear purchases on cart clear (indirectly through cart provider)', () async {
      // Questo test verifica che la logica di clearCart del CartProvider (se fosse qui)
      // non influenzi direttamente PurchaseManager. PurchaseManager non ha un metodo clearPurchases.
      // Il test precedente `should return null if no purchases have been made` copre lo stato iniziale.
      // Se ci fosse un metodo clearPurchases in PurchaseManager, lo testeremmo qui.
      // Poiché non c'è, questo test è più un promemoria per il caso in cui tu lo implementassi.
    });
  });
}