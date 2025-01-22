import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../config/models/product_model.dart';
import '../../../config/models/sale_model.dart';
import '../../../config/app_localizations.dart';
import '../../../config/models/user_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> products = [];
  Map<String, int> soldQuantities = {};
  double totalLosses = 0.0;
  double totalGains = 0.0;

  String storeName = '';
  String address = '';
  String phone = '';
  String selectedDate = '';

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _getCurrentUserInfo();
  }

  Future<void> _getCurrentUserInfo() async {
    var currentUserBox = Hive.box('currentUser');
    var userBox = Hive.box<User>('users');

    String? currentUserEmail = currentUserBox.get('email');
    if (currentUserEmail == null) return;

    User? currentUser = userBox.values.firstWhereOrNull(
      (user) => user.email == currentUserEmail,
    );

    if (currentUser != null) {
      setState(() {
        storeName = currentUser.storeName;
        address = currentUser.address;
        phone = currentUser.phone;
      });
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    var productBox = Hive.box<Product>('products');
    var saleBox = Hive.box<Sale>('sales');

    print("Store Name del usuario logueado: $storeName");

    products = productBox.values.where((product) {
      print(
          "Producto: ${product.name}, Store Name: ${product.storeName}");
      return product.storeName == storeName;
    }).toList();

    print("Productos encontrados: ${products.length}");

    final sales = saleBox.values.toList();
    soldQuantities = {};
    for (var sale in sales) {
      for (var product in sale.products) {
        final productName = product['name'];
        final quantity = product['quantity'] as int;
        if (soldQuantities.containsKey(productName)) {
          soldQuantities[productName] =
              (soldQuantities[productName] ?? 0) + quantity;
        } else {
          soldQuantities[productName] = quantity;
        }
      }
    }

    totalLosses = 0.0;
    totalGains = 0.0;
    for (var product in products) {
      final soldQuantity = soldQuantities[product.name] ?? 0;
      final totalCost = product.purchasePrice * soldQuantity;
      final totalRevenue = product.salePrice * soldQuantity;
      final profit = totalRevenue - totalCost;

      if (profit < 0) {
        totalLosses += -profit;
      } else {
        totalGains += profit;
      }
    }

    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
        _loadData();
      });
    }
  }

  Future<void> _printInventoryReport() async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4;

    final now = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yyyy').format(now);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(storeName,
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(address, style: pw.TextStyle(fontSize: 16)),
              pw.Text(phone, style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text('Fecha: $formattedDate',
                  style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Producto',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Precio de Compra',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Precio de Venta',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Inventario',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Cantidad Vendida',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...products.map((product) {
                    final soldQuantity = soldQuantities[product.name] ?? 0;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(product.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                              '\$${product.purchasePrice.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                              '\$${product.salePrice.toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(product.inventory.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(soldQuantity.toString()),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Pérdidas: \$${totalLosses.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text('Ganancias: \$${totalGains.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16)),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('inventory')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: products.isEmpty
            ? Center(child: Text(localizations.translate('noProducts')))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(address, style: TextStyle(fontSize: 16)),
                  Text(phone, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 8),
                            Text(
                              '${localizations.translate('dateLabel')}: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(selectedDate))}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _printInventoryReport,
                        child: Container(
                          height: 40,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 0, 110, 173),
                                Color.fromARGB(255, 0, 36, 56),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              localizations.translate('printButton'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${localizations.translate('losses')}: ${totalLosses.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${localizations.translate('gains')}: ${totalGains.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label:
                                  Text(localizations.translate('productName'))),
                          DataColumn(
                              label: Text(
                                  localizations.translate('purchasePrice'))),
                          DataColumn(
                              label:
                                  Text(localizations.translate('salePrice'))),
                          DataColumn(
                              label:
                                  Text(localizations.translate('inventory'))),
                          DataColumn(
                              label: Text(
                                  localizations.translate('soldQuantity'))),
                        ],
                        rows: products.map((product) {
                          final soldQuantity =
                              soldQuantities[product.name] ?? 0;
                          return DataRow(cells: [
                            DataCell(Text(product.name)),
                            DataCell(Text(
                                '\$${product.purchasePrice.toStringAsFixed(2)}')),
                            DataCell(Text(
                                '\$${product.salePrice.toStringAsFixed(2)}')),
                            DataCell(Text(product.inventory.toString())),
                            DataCell(Text(soldQuantity.toString())),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
