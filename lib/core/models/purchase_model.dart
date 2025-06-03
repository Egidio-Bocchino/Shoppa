import 'dart:convert';

import 'package:shoppa/core/models/cart_item.dart';

class Purchase {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime purchaseDate;

  Purchase({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.purchaseDate,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      items: (json['items'] as List)
          .map((itemJson) => CartItem.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );
  }
}
