import 'package:hive/hive.dart';
part 'review_model.g.dart';

@HiveType(typeId: 0)
class Review extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String productId;
  @HiveField(2)
  final String userId;
  @HiveField(3)
  final String userName;
  @HiveField(4)
  final double rating;
  @HiveField(5)
  final String reviewText;
  @HiveField(6)
  final DateTime reviewDate;
  @HiveField(7)
  final String? imageUrl;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.reviewText,
    required this.reviewDate,
    this.imageUrl,
  });
}