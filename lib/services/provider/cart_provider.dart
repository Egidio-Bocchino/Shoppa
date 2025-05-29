import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppa/core/models/product_model.dart';
import '../../core/exception/data_parsing_exception.dart';
import '../../core/exception/exception_handler.dart';
import '../../core/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _productsInCart = [];
  static const String _cartKey = 'cart_items';

  CartProvider() {
    _loadCart();
  }

  List<CartItem> get productsInCart => _productsInCart;
  int get itemCount => _productsInCart.fold(0, (sum, item) => sum + item.quantity);

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        final List<dynamic> decodedData = jsonDecode(cartJson);
        _productsInCart.clear();
        _productsInCart.addAll(decodedData.map((item) {
          try {
            return CartItem.fromJson(item as Map<String, dynamic>);
          } catch (e, s) {
            throw DataParsingException('Errore nel parsing di un CartItem: $e', data: item);
          }
        }).toList());
        notifyListeners();
      }
    } catch (e, s) {
      if (e is DataParsingException) {
        ExceptionHandler.handleDataParsingException(e, s, context: 'CartProvider - _loadCart');
      } else {
        ExceptionHandler.handle(e, s, context: 'CartProvider - _loadCart: Errore generico caricamento carrello');
      }
      _productsInCart.clear();
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final String encodedCart = jsonEncode(_productsInCart.map((item) => item.toJson()).toList());
      await pref.setString(_cartKey, encodedCart);
    } catch (e, s) {
      ExceptionHandler.handle(e, s, context: 'CartProvider - _saveCart');
    }
  }

  void addToCart(Product product) {
    int index = _productsInCart.indexWhere((item) => item.product.id == product.id);
    if(index != -1){
      _productsInCart[index].quantity++;
    }else{
      _productsInCart.add(CartItem(product: product));
    }
    notifyListeners();
    _saveCart();
  }

  void removeFromCart(Product product) {
    int index = _productsInCart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      if (_productsInCart[index].quantity > 1) {
        // Decrease quantity if greater than 1
        _productsInCart[index].quantity--;
      } else {
        // Remove product if quantity is 1
        _productsInCart.removeAt(index);
      }
    }
    notifyListeners();
    _saveCart();
  }

  void removeAllOfProduct(Product product) {
    _productsInCart.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
    _saveCart();
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in _productsInCart) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  void clearCart() {
    _productsInCart.clear();
    notifyListeners();
    _saveCart();
  }

}

final cartProvider = ChangeNotifierProvider<CartProvider>((ref) {
  return CartProvider();
});