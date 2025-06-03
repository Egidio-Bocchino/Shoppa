import 'package:flutter_test/flutter_test.dart';
import 'package:shoppa/core/models/product_model.dart';

void main() {
  group('Product', () {
    // Define a sample JSON map for testing
    final Map<String, dynamic> sampleProductJson = {
      'id': 1,
      'title': 'Test Product',
      'description': 'This is a test product description.',
      'price': 99.99,
      'discountPercentage': 10.0,
      'rating': 4.5,
      'stock': 50,
      'brand': 'TestBrand',
      'category': 'TestCategory',
      'thumbnail': 'http://example.com/thumbnail.jpg',
      'images': [
        'http://example.com/image1.jpg',
        'http://example.com/image2.jpg'
      ],
    };

    test('Product can be instantiated with all required fields', () {
      final product = Product(
        id: 1,
        title: 'Sample Product',
        description: 'A brief description.',
        price: 12.34,
        discountPercentage: 5.0,
        rating: 3.8,
        stock: 100,
        brand: 'BrandX',
        category: 'Electronics',
        thumbnail: 'thumb.jpg',
        images: ['img1.jpg', 'img2.jpg'],
      );

      expect(product, isA<Product>());
      expect(product.id, 1);
      expect(product.title, 'Sample Product');
      expect(product.description, 'A brief description.');
      expect(product.price, 12.34);
      expect(product.discountPercentage, 5.0);
      expect(product.rating, 3.8);
      expect(product.stock, 100);
      expect(product.brand, 'BrandX');
      expect(product.category, 'Electronics');
      expect(product.thumbnail, 'thumb.jpg');
      expect(product.images, ['img1.jpg', 'img2.jpg']);
    });

    test('Product.fromJson creates a Product instance correctly', () {
      final product = Product.fromJson(sampleProductJson);

      expect(product.id, sampleProductJson['id']);
      expect(product.title, sampleProductJson['title']);
      expect(product.description, sampleProductJson['description']);
      expect(product.price, sampleProductJson['price']);
      expect(product.discountPercentage, sampleProductJson['discountPercentage']);
      expect(product.rating, sampleProductJson['rating']);
      expect(product.stock, sampleProductJson['stock']);
      expect(product.brand, sampleProductJson['brand']);
      expect(product.category, sampleProductJson['category']);
      expect(product.thumbnail, sampleProductJson['thumbnail']);
      expect(product.images, sampleProductJson['images']);
    });

    test('Product.fromJson handles missing or null values with defaults', () {
      final Map<String, dynamic> jsonWithMissingValues = {
        'id': null,
        'title': null,
        'description': null,
        'price': null,
        'discountPercentage': null,
        'rating': null,
        'stock': null,
        'brand': null,
        'category': null,
        'thumbnail': null,
        'images': null,
      };

      final product = Product.fromJson(jsonWithMissingValues);

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.description, '');
      expect(product.price, 0.0);
      expect(product.discountPercentage, 0.0);
      expect(product.rating, 0.0);
      expect(product.stock, 0);
      expect(product.brand, '');
      expect(product.category, '');
      expect(product.thumbnail, '');
      expect(product.images, []);
    });

    test('Product.toJson converts a Product instance to a JSON map correctly', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        description: 'This is a test product description.',
        price: 99.99,
        discountPercentage: 10.0,
        rating: 4.5,
        stock: 50,
        brand: 'TestBrand',
        category: 'TestCategory',
        thumbnail: 'http://example.com/thumbnail.jpg',
        images: [
          'http://example.com/image1.jpg',
          'http://example.com/image2.jpg'
        ],
      );

      final json = product.toJson();

      expect(json['id'], product.id);
      expect(json['title'], product.title);
      expect(json['description'], product.description);
      expect(json['price'], product.price);
      expect(json['discountPercentage'], product.discountPercentage);
      expect(json['rating'], product.rating);
      expect(json['stock'], product.stock);
      expect(json['brand'], product.brand);
      expect(json['category'], product.category);
      expect(json['thumbnail'], product.thumbnail);
      expect(json['images'], product.images);
    });

    test('Product.toJson output can be used by Product.fromJson', () {
      final product = Product(
        id: 2,
        title: 'Round Trip',
        description: 'From JSON to object and back to JSON.',
        price: 150.0,
        discountPercentage: 0.0,
        rating: 5.0,
        stock: 5,
        brand: 'Travel',
        category: 'Experiences',
        thumbnail: 'trip.jpg',
        images: [],
      );

      final jsonFromProduct = product.toJson();
      final productFromJson = Product.fromJson(jsonFromProduct);

      expect(productFromJson.id, product.id);
      expect(productFromJson.title, product.title);
      expect(productFromJson.description, product.description);
      expect(productFromJson.price, product.price);
      expect(productFromJson.discountPercentage, product.discountPercentage);
      expect(productFromJson.rating, product.rating);
      expect(productFromJson.stock, product.stock);
      expect(productFromJson.brand, product.brand);
      expect(productFromJson.category, product.category);
      expect(productFromJson.thumbnail, product.thumbnail);
      expect(productFromJson.images, product.images);
    });
  });
}