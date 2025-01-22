import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../config/models/sale_model.dart';
import '../../config/app_localizations.dart';
import '../../config/models/user_model.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late Box<Sale> salesBox;
  String selectedDate = '';
  List<Sale> dailySales = [];
  String totalSalesAmount = '';

  String storeName = '';
  String address = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    salesBox = Hive.box<Sale>('sales');
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

      loadSalesForDate(selectedDate);
    }
  }

  void loadSalesForDate(String date) {
    final sales = salesBox.values.where((sale) {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(sale.date)) ==
              date &&
          sale.storeName ==
              storeName;
    }).toList();

    double total = 0;
    for (var sale in sales) {
      total += sale.total;
    }

    setState(() {
      dailySales = sales;
      totalSalesAmount = total.toStringAsFixed(2);
    });
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
        loadSalesForDate(selectedDate);
      });
    }
  }

  Future<void> _printSalesReport() async {
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
                        child: pw.Text('# de Venta',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Fecha y Hora',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Cajero',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Detalles de Productos',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Total',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...dailySales.map((sale) {
                    String productDetails = sale.products.map((product) {
                      return '${product['name']} - ${product['quantity']} x ${product['price']}';
                    }).join('; ');

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(sale.saleNumber.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(DateFormat('yyyy-MM-dd HH:mm')
                              .format(DateTime.parse(sale.date))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(sale.cashier),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(productDetails),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(sale.total.toStringAsFixed(2)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total de Ventas: $totalSalesAmount',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('salesTodayTitle')),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    localizations.translate('searchByDay'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(address, style: TextStyle(fontSize: 16)),
                    Text(phone, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      '${localizations.translate('dateLabel')}: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(selectedDate))}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _printSalesReport,
                  child: Container(
                    height: 40,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: [
                        Color.fromARGB(255, 0, 110, 173),
                        Color.fromARGB(255, 0, 36, 56),
                      ]),
                    ),
                    child: Center(
                      child: Text(
                        localizations.translate('printButton'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '${localizations.translate('totalSalesToday')}: \$${totalSalesAmount}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (dailySales.isEmpty)
                  Center(
                    child: Text(localizations.translate('noSalesForDate')),
                  )
                else
                  DataTable(
                    columns: [
                      DataColumn(
                          label: Text(localizations.translate('saleNumber'))),
                      DataColumn(
                          label: Text(localizations.translate('saleDate'))),
                      DataColumn(
                          label: Text(localizations.translate('cashier'))),
                      DataColumn(
                          label:
                              Text(localizations.translate('productDetails'))),
                      DataColumn(label: Text(localizations.translate('total'))),
                    ],
                    rows: dailySales.map((sale) {
                      String productDetails = sale.products.map((product) {
                        return '${product['name']} - ${product['quantity']} x ${product['price']}';
                      }).join('; ');

                      return DataRow(cells: [
                        DataCell(Text(sale.saleNumber.toString())),
                        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                            .format(DateTime.parse(sale.date)))),
                        DataCell(Text(sale.cashier)),
                        DataCell(Text(productDetails)),
                        DataCell(Text(sale.total.toStringAsFixed(2))),
                      ]);
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
