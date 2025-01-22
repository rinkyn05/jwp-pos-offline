import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../../config/app_localizations.dart';
import '../../../config/models/product_model.dart';
import '../../../config/models/user_model.dart';
import '../../home_screen.dart';
import 'add_products_screen.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> productList = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _getCurrentUserInfo();
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
        'storeName': currentUser.storeName,
      };
    }

    return {};
  }

  Future<void> _loadProducts() async {
    var productBox = Hive.box<Product>('products');

    Map<String, String> currentUserInfo = await _getCurrentUserInfo();
    String storeName = currentUserInfo['storeName'] ?? '';

    setState(() {
      productList = productBox.values
          .where((product) => product.storeName == storeName)
          .toList();
    });
  }

  Future<void> _deleteProduct(
      String productName, String productImagePath) async {
    var productBox = Hive.box<Product>('products');

    final productToDelete = productBox.values.firstWhereOrNull(
      (product) => product.name == productName,
    );

    if (productToDelete != null) {
      await productBox.delete(productToDelete.key);

      final directory = await getApplicationDocumentsDirectory();
      final productDir =
          Directory('${directory.path}/jwp_files/products/$productName');

      if (await productDir.exists()) {
        await productDir.delete(recursive: true);
      }

      await _loadProducts();
    }
  }

  void _showProductOptionsDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context).translate('edit')),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProductScreen(
                        product: product,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(AppLocalizations.of(context).translate('delete')),
                onTap: () {
                  Navigator.of(context).pop();

                  _deleteProduct(
                    product.name,
                    product.imagePath,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 250).floor();
    final itemWidth = (screenWidth / crossAxisCount).clamp(200.0, 250.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('productListTitle')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 40,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddProductScreen()),
              ).then((_) => _loadProducts());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${localizations.translate('totalProducts')}: ${productList.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: productList.isEmpty
                ? Center(
                    child:
                        Text(localizations.translate('noProductsRegistered')))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: itemWidth / 250,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final product = productList[index];
                      return GestureDetector(
                        onTap: () {
                          _showProductOptionsDialog(product);
                        },
                        child: Container(
                          width: itemWidth,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  child: Image.file(
                                    File(product.imagePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('\$${product.salePrice}'),
                              ),
                              SizedBox(height: 50),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 0, 110, 173),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then((_) => _loadProducts());
        },
        child: const Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}
