import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../config/app_localizations.dart';
import '../../../config/models/user_model.dart';
import 'cashiers_list_screen.dart';

class AddCashierScreen extends StatefulWidget {
  const AddCashierScreen({Key? key}) : super(key: key);

  @override
  _AddCashierScreenState createState() => _AddCashierScreenState();
}

class _AddCashierScreenState extends State<AddCashierScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final String defaultRole = "Cajero";
  final String defaultProfileImage = "assets/logo.png";

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<Map<String, String>> _getCurrentUserInfo() async {
    var userBox = Hive.box<User>('users');
    var currentUserBox = Hive.box('currentUser');

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

  Future<void> _addCashier() async {
    if (passwordController.text == confirmPasswordController.text) {
      var userBox = Hive.box<User>('users');

      Map<String, String> currentUserInfo = await _getCurrentUserInfo();
      String storeName = currentUserInfo['storeName'] ?? '';

      User newCashier = User(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: 'Cajero',
        storeName: storeName,
        phone: '00000000',
        address: 'Rep. Dom.',
        profileImage: 'assets/default_profile_image.png',
      );

      if (userBox.values.any((user) => user.email == newCashier.email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context).translate('cashierExists'))),
        );
        return;
      }

      await userBox.add(newCashier);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('cashierSavedSuccessfully')),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CashierListScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('passwordsDoNotMatch')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('addCashier')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:
                  InputDecoration(labelText: localizations.translate('name')),
            ),
            TextField(
              controller: emailController,
              decoration:
                  InputDecoration(labelText: localizations.translate('email')),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: localizations.translate('pass'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: localizations.translate('confirmPass'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_confirmPasswordVisible,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _addCashier,
              child: Container(
                height: 55,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 110, 173),
                      Color.fromARGB(255, 0, 36, 56),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    localizations.translate('addCashier'),
                    style: TextStyle(
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
    );
  }
}
