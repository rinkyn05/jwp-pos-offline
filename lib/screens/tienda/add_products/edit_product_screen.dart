import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/app_localizations.dart';
import '../../../config/models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _inventoryController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _salePriceController;
  File? _mainImage;
  List<File> _galleryImages = [];

  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _categoryController = TextEditingController(text: widget.product.category);
    _inventoryController =
        TextEditingController(text: widget.product.inventory.toString());
    _purchasePriceController =
        TextEditingController(text: widget.product.purchasePrice.toString());
    _salePriceController =
        TextEditingController(text: widget.product.salePrice.toString());

    if (widget.product.imagePath.isNotEmpty) {
      _mainImage = File(widget.product.imagePath);
    }
  }

  Future<void> _pickImage(bool isMainImage) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isMainImage) {
          _mainImage = File(pickedFile.path);
        } else {
          _galleryImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      widget.product.name = _nameController.text;
      widget.product.description = _descriptionController.text;
      widget.product.category = _categoryController.text;
      widget.product.inventory = int.parse(_inventoryController.text);
      widget.product.purchasePrice =
          double.parse(_purchasePriceController.text);
      widget.product.salePrice = double.parse(_salePriceController.text);

      if (_mainImage != null) {
        widget.product.imagePath = _mainImage!.path;
      }

      await widget.product.save();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('productUpdatedSuccessfully'))),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('editProductTitle')),
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
              _mainImage == null
                  ? ElevatedButton(
                      onPressed: () => _pickImage(true),
                      child: Text(localizations.translate('uploadMainImage')),
                    )
                  : Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(_mainImage!, fit: BoxFit.cover),
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(false),
                child: Text(localizations.translate('uploadGalleryImages')),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProduct,
                child: Text(localizations.translate('saveProduct')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
