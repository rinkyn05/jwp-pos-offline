import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../config/app_localizations.dart';
import '../../../config/models/product_model.dart';
import '../../../config/models/user_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _inventoryController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  File? _mainImage;
  final String _defaultImage = 'assets/producto_sin_imagen.jpeg';

  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(bool isMainImage) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isMainImage) {
          _mainImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<Map<String, String>> _getCurrentUserInfo() async {
    var currentUserBox = Hive.box('currentUser');
    var userBox = Hive.box<User>('users');

    String? currentUserEmail = currentUserBox.get('email');
    if (currentUserEmail == null) return {};

    User? currentUser = userBox.values.firstWhereOrNull(
      (user) => user.email == currentUserEmail,
    );

    if (currentUser != null) {
      return {
        'email': currentUser.email,
        'storeName': currentUser.storeName,
      };
    }

    return {};
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, String> currentUserInfo = await _getCurrentUserInfo();
      String storeName = currentUserInfo['storeName'] ?? '';

      final product = Product(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        inventory: int.parse(_inventoryController.text),
        purchasePrice: double.parse(_purchasePriceController.text),
        salePrice: double.parse(_salePriceController.text),
        imagePath: _mainImage != null ? _mainImage!.path : _defaultImage,
        storeName: storeName,
      );

      var productBox = Hive.box<Product>('products');

      bool productExists = productBox.values.any(
        (existingProduct) =>
            existingProduct.name == product.name &&
            existingProduct.storeName == storeName,
      );

      if (productExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context).translate('productExists'))),
        );
        return;
      }

      await productBox.add(product);

      final directory = await getApplicationDocumentsDirectory();
      final productName = _nameController.text;

      final productDir = Directory(
          '${directory.path}/jwp_files/users/${currentUserInfo['email']}/product/$productName');
      if (!await productDir.exists()) {
        await productDir.create(recursive: true);
      }

      if (_mainImage != null) {
        final mainImagePath =
            '${productDir.path}/${path.basename(_mainImage!.path)}';
        await _mainImage!.copy(mainImagePath);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('productSavedSuccessfully'))),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('addProductTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: localizations.translate('productName'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('productNameRequired');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: localizations.translate('productDescription'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations
                        .translate('productDescriptionRequired');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: localizations.translate('productCategory'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('productCategoryRequired');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _inventoryController,
                decoration: InputDecoration(
                  labelText: localizations.translate('productInventory'),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('productInventoryRequired');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _purchasePriceController,
                decoration: InputDecoration(
                  labelText: localizations.translate('productPurchasePrice'),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations
                        .translate('productPurchasePriceRequired');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _salePriceController,
                decoration: InputDecoration(
                  labelText: localizations.translate('productSalePrice'),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('productSalePriceRequired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _pickImage(true),
                child: _mainImage == null
                    ? Image.asset(
                        _defaultImage,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        _mainImage!,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(true),
                child: Text(localizations.translate('uploadMainImage')),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(localizations.translate('saveProduct')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
