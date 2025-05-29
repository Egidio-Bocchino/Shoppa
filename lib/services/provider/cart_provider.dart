import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppa/core/models/product_model.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      final List<dynamic> decodedData = jsonDecode(cartJson);
      _productsInCart.clear();
      _productsInCart.addAll(decodedData.map((item) => CartItem.fromJson(item as Map<String, dynamic>)));
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    final pref = await SharedPreferences.getInstance();
    final String encodedCart = jsonEncode(_productsInCart.map((item) => item.toJson()).toList());
    await pref.setString(_cartKey, encodedCart);
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