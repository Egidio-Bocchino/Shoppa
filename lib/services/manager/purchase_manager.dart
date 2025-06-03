import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppa/core/models/cart_item.dart';
import 'package:shoppa/core/models/purchase_model.dart';

class PurchaseManager extends ChangeNotifier{
  List<Purchase> _purchases = [];
  static const String _purchasesKey = 'user_purchase';

  List<Purchase> get purchases => _purchases;

  PurchaseManager(){
    _loadPurchases();
  }

  Future<void> _loadPurchases() async{
    final pref = await SharedPreferences.getInstance();
    final String? purchasesString = pref.getString(_purchasesKey);
    if(purchasesString != null){
      try{
        final List<dynamic> jsonList = json.decode(purchasesString);
        _purchases = jsonList.map((json) => Purchase.fromJson(json as Map<String, dynamic>)).toList();
      }catch(e){
        print("Errore nel caricamento degli acquisti SP$e");
        _purchases = [];
      }
      notifyListeners();
    }
  }

  Future<void> _savePurchases() async{
    final pref = await SharedPreferences.getInstance();
    final String jsonString = json.encode(_purchases.map((purchase) => purchase.toJson()).toList());
    await pref.setString(_purchasesKey, jsonString);
  }

  void addPurchase(List<CartItem> items, double totalPrice){
    final newPurchase = Purchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(items),
      totalPrice: totalPrice,
      purchaseDate: DateTime.now(),
    );

    _purchases.add(newPurchase);
    _savePurchases();
    notifyListeners();
  }

  Purchase? getList(){
    if(_purchases.isEmpty){
      return null;
    }
    return _purchases.last;
  }

}

final purchaseManagerProvider = ChangeNotifierProvider((ref) => PurchaseManager());
