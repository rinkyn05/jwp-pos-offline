import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  String category;

  @HiveField(3)
  int inventory;

  @HiveField(4)
  double purchasePrice;

  @HiveField(5)
  double salePrice;

  @HiveField(6)
  String imagePath;

  @HiveField(7)
  String storeName;

  Product({
    required this.name,
    required this.description,
    required this.category,
    required this.inventory,
    required this.purchasePrice,
    required this.salePrice,
    required this.imagePath,
    required this.storeName,
  });
}
