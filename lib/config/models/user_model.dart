import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String storeName;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String address;

  @HiveField(5)
  String password;

  @HiveField(6)
  String role;

  @HiveField(7)
  String profileImage;

  User({
    required this.name,
    required this.email,
    required this.storeName,
    required this.phone,
    required this.address,
    required this.password,
    required this.role,
    required this.profileImage,
  });
}
