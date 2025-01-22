import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../../../config/app_localizations.dart';
import '../../../config/models/user_model.dart';
import '../../home_screen.dart';
import 'add_cashiers_screen.dart';
import 'edit_cashiers_screen.dart';

class CashierListScreen extends StatefulWidget {
  const CashierListScreen({Key? key}) : super(key: key);

  @override
  _CashierListScreenState createState() => _CashierListScreenState();
}

class _CashierListScreenState extends State<CashierListScreen> {
  List<Map<String, String>> cashierList = [];

  @override
  void initState() {
    super.initState();
    _loadCashiers();
  }

  Future<void> _loadCashiers() async {
    var userBox = Hive.box<User>('users');
    var currentUserBox = Hive.box('currentUser');

    String? currentUserEmail = currentUserBox.get('email');
    if (currentUserEmail == null) return;

    User? currentUser = userBox.values.firstWhereOrNull(
      (user) => user.email == currentUserEmail,
    );

    if (currentUser != null) {
      setState(() {
        cashierList = userBox.values
            .where((user) =>
                user.role == 'Cajero' &&
                user.storeName == currentUser.storeName)
            .map<Map<String, String>>(
                (user) => {'name': user.name, 'email': user.email})
            .toList();
      });
    }
  }

  Future<void> _deleteCashier(String email) async {
    var userBox = Hive.box<User>('users');

    int? cashierKey = userBox.keys.cast<int>().firstWhereOrNull(
          (key) => userBox.get(key)?.email == email,
        );

    if (cashierKey != null) {
      await userBox.delete(cashierKey);
      _loadCashiers();
    }
  }

  void _showDeleteConfirmationDialog(String email) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('confirmDelete')),
          content: Text(localizations.translate('confirmDeleteCashier')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(localizations.translate('cancel')),
            ),
            TextButton(
              onPressed: () async {
                await _deleteCashier(email);
                Navigator.pop(context);
              },
              child: Text(localizations.translate('delete')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    var userBox = Hive.box<User>('users');

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('cashierList')),
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
                    builder: (context) => const AddCashierScreen()),
              );
            },
          ),
        ],
      ),
      body: cashierList.isEmpty
          ? Center(child: Text(localizations.translate('noCashiersRegistered')))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total de cajeros: ${cashierList.length}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cashierList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(cashierList[index]['name']!),
                        subtitle: Text(cashierList[index]['email']!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                User cashierToEdit = userBox.values.firstWhere(
                                  (user) =>
                                      user.email == cashierList[index]['email'],
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditCashierScreen(
                                        cashier: cashierToEdit),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    cashierList[index]['email']!);
                              },
                            ),
                          ],
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
            MaterialPageRoute(builder: (context) => const AddCashierScreen()),
          );
        },
        child: const Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}
