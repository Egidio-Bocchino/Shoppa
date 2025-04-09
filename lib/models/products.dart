/*
import 'package:json_annotation/json_annotation.dart';

part 'products.g.dart';

@JsonSerializable()
class Products {
  List<Product> products;
  int total;
  int skip;
  int limit;

  Products({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

}

@JsonSerializable()
class Product {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  String title;

  @JsonKey(required: true)
  String description;

  @JsonKey(required: true)
  int price;

  @JsonKey(required: true)
  double discountPercentage;

  @JsonKey(required: true)
  double rating;

  @JsonKey(required: true)
  int stock;

  @JsonKey(required: true)
  String brand;

  @JsonKey(required: true)
  String category;

  @JsonKey(required: true)
  String thumbnail;

  @JsonKey(required: true)
  List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String,dynamic> json) => _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

}*/
