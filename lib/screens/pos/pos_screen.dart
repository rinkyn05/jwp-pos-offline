import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../config/app_localizations.dart';
import '../../../config/models/product_model.dart';
import '../../../config/models/user_model.dart';
import '../../../config/models/sale_model.dart';
import 'package:pdf/widgets.dart' as pw;

import '../home_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({Key? key}) : super(key: key);

  @override
  _POSScreenState createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> filteredProductList = [];
  List<Map<String, dynamic>> cart = [];
  double total = 0.0;
  String storeName = '';
  String cashierEmail = '';
  String cashierName = '';
  String phone = '';
  String address = '';
  int saleCounter = 1;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _getCurrentUserInfo();
    searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
      setState(() {
        storeName = currentUser.storeName;
        cashierEmail = currentUser.email;
        cashierName = currentUser.name;
        phone = currentUser.phone;
        address = currentUser.address;
      });
      return {
        'email': currentUser.email,
        'storeName': currentUser.storeName,
        'name': currentUser.name,
        'phone': currentUser.phone,
        'address': currentUser.address,
      };
    }

    return {};
  }

  void _filterProducts() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredProductList = productList.where((product) {
        return product['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadProducts() async {
    var productBox = Hive.box<Product>('products');
    Map<String, String> currentUserInfo = await _getCurrentUserInfo();
    String storeName = currentUserInfo['storeName'] ?? '';

    setState(() {
      productList = productBox.values
          .where((product) => product.storeName == storeName)
          .map<Map<String, dynamic>>((product) => {
                'name': product.name,
                'price': product.salePrice,
                'imagePath': product.imagePath,
                'inventory': product.inventory,
              })
          .toList();

      filteredProductList = productList;
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      var cartItem =
          cart.firstWhereOrNull((item) => item['name'] == product['name']);
      if (cartItem != null) {
        cartItem['quantity'] += 1;
      } else {
        cart.add({
          'name': product['name'],
          'price': product['price'],
          'imagePath': product['imagePath'],
          'quantity': 1,
        });
      }
      _calculateTotal();
    });
  }

  void _removeFromCart(Map<String, dynamic> product) {
    setState(() {
      var cartItem =
          cart.firstWhereOrNull((item) => item['name'] == product['name']);
      if (cartItem != null) {
        cartItem['quantity'] -= 1;
        if (cartItem['quantity'] == 0) {
          cart.remove(cartItem);
        }
      }
      _calculateTotal();
    });
  }

  void _clearCart() {
    setState(() {
      cart.clear();
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double newTotal = 0.0;
    for (var item in cart) {
      newTotal += item['price'] * item['quantity'];
    }
    setState(() {
      total = newTotal;
    });
  }

  Future<void> _updateInventory() async {
    var productBox = Hive.box<Product>('products');
    for (var item in cart) {
      var product = productBox.values.firstWhereOrNull(
          (p) => p.name == item['name'] && p.storeName == storeName);
      if (product != null) {
        product.inventory -= item['quantity'] as int;
        product.save();
      }
    }
  }

  Future<void> _recordSale() async {
    var salesBox = Hive.box<Sale>('sales');
    var currentDate = DateTime.now();

    String saleId = saleCounter.toString().padLeft(4, '0');

    var sale = Sale(
      saleId: int.parse(saleId),
      saleNumber: int.parse(saleId),
      products: cart
          .map((item) => {
                'name': item['name'],
                'price': item['price'],
                'quantity': item['quantity'],
              })
          .toList(),
      total: total,
      storeName: storeName,
      cashier: cashierEmail,
      date: currentDate.toIso8601String(),
    );

    await salesBox.add(sale);
    setState(() {
      saleCounter++;
    });
  }

  Future<void> _completePurchase() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String clientName = 'Invitado';
        double paymentAmount = 0.0;
        double change = 0.0;
        String note = '';
        TextEditingController clientController = TextEditingController();
        TextEditingController paymentController = TextEditingController();
        TextEditingController noteController = TextEditingController();

        final localizations = AppLocalizations.of(context);

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            localizations.translate('completePurchase'),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: clientController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('client'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    clientName = value.isNotEmpty ? value : 'Invitado';
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: paymentController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('paymentAmount'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    double payment = double.tryParse(value) ?? 0.0;
                    change = payment - total;
                    setState(() {});
                  },
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [500, 1000, 2000].map((amount) {
                    return OutlinedButton(
                      onPressed: () {
                        paymentController.text = amount.toString();
                        paymentAmount = amount.toDouble();
                        change = paymentAmount - total;
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                      child: Text(
                        '$amount',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('note'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    note = value;
                  },
                ),
                if (change != 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      '${localizations.translate('change')}: \$${change.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                localizations.translate('cancel'),
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (paymentAmount >= total || paymentController.text.isEmpty) {
                  await _updateInventory();
                  await _recordSale();
                  await _printReceipt(clientName, paymentAmount, change, note);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.transparent,
                        content: Center(
                          child: Icon(
                            Icons
                                .check_circle,
                            color: Colors.green,
                            size: 100,
                          ),
                        ),
                      );
                    },
                  );

                  await Future.delayed(Duration(seconds: 2));
                  Navigator.of(context).pop();
                  _clearCart();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(localizations.translate('insufficientPayment')),
                    ),
                  );
                }
              },
              child: Text(
                localizations.translate('complete'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _printReceipt(String clientName, double paymentAmount,
      double change, String note) async {
    final pdf = pw.Document();
    final pageFormat =
        PdfPageFormat(72.1 * PdfPageFormat.mm, 210 * PdfPageFormat.mm);

    final localizations = AppLocalizations.of(context);
    final now = DateTime.now().toLocal();

    final formattedHour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final formattedMinute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final formattedTime = '$formattedHour:$formattedMinute $period';

    final formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final formattedDateTime = '$formattedDate $formattedTime';

    final saleNumber = 'Venta #: ${saleCounter.toString().padLeft(4, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  storeName,
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  address,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  phone,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  saleNumber,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '${localizations.translate('client')}: $clientName',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '${localizations.translate('dateAndTime')}: $formattedDateTime',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    localizations.translate('products'),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${localizations.translate('price')} - ${localizations.translate('total')}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ...cart.map<pw.Widget>((item) {
                double totalPorProducto = item['quantity'] * item['price'];

                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'x${item['quantity']} - ${item['name']}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.Text(
                      '\$${item['price'].toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      '\$${totalPorProducto.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      '${localizations.translate('total')}:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (paymentAmount > 0) ...[
                pw.SizedBox(height: 6),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${localizations.translate('paymentAmount')}:',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '\$${paymentAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 12),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${localizations.translate('change')}:',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '\$${change.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 12),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              pw.SizedBox(height: 4),
              if (note.isNotEmpty)
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '${localizations.translate('note')}: $note',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '${localizations.translate('leAtendio')}: $cashierName',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  localizations.translate('thankYouMessage'),
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    Uint8List pdfData = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
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
        title: Text(localizations.translate('pos')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${localizations.translate('totalProducts')}: ${productList.length}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: localizations.translate('search'),
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredProductList.isEmpty
                      ? Center(
                          child: Text(
                              localizations.translate('noProductsRegistered')),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: itemWidth / 250,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredProductList.length,
                          itemBuilder: (context, index) {
                            final product = filteredProductList[index];
                            return GestureDetector(
                              onTap: () => _addToCart(product),
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
                                          File(product['imagePath']),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        product['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('\$${product['price']}'),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () =>
                                                _addToCart(product),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      localizations.translate('cart'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: cart.isEmpty
                        ? Center(
                            child: Text(localizations.translate('cartIsEmpty')))
                        : ListView.builder(
                            itemCount: cart.length,
                            itemBuilder: (context, index) {
                              final item = cart[index];
                              return ListTile(
                                leading: Image.file(
                                  File(item['imagePath']),
                                  width: 50,
                                  height: 50,
                                ),
                                title: Text(item['name']),
                                subtitle: Text('\$${item['price']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _removeFromCart(item),
                                    ),
                                    Text('${item['quantity']}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _addToCart(item),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '${localizations.translate('total')}: \$${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: _clearCart,
                          child: Container(
                            height: 55,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(colors: [
                                Color.fromARGB(255, 0, 110, 173),
                                Color.fromARGB(255, 0, 36, 56),
                              ]),
                            ),
                            child: Center(
                              child: Text(
                                localizations.translate('clearCart'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: cart.isEmpty ? null : _completePurchase,
                          child: Container(
                            height: 55,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(colors: [
                                Color.fromARGB(255, 0, 110, 173),
                                Color.fromARGB(255, 0, 36, 56),
                              ]),
                            ),
                            child: Center(
                              child: Text(
                                localizations.translate('complete'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
