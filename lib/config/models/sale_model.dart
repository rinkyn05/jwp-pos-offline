import 'package:hive/hive.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 2)
class Sale extends HiveObject {
  @HiveField(0)
  int saleId;

  @HiveField(1)
  int saleNumber;

  @HiveField(2)
  List<Map<String, dynamic>> products;

  @HiveField(3)
  double total;

  @HiveField(4)
  String storeName;

  @HiveField(5)
  String cashier;

  @HiveField(6)
  String date;

  Sale({
    required this.saleId,
    required this.saleNumber,
    required this.products,
    required this.total,
    required this.storeName,
    required this.cashier,
    required this.date,
  });
}
