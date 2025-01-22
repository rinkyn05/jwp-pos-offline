import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../config/app_localizations.dart';
import '../../../config/models/user_model.dart';
import 'cashiers_list_screen.dart';

class EditCashierScreen extends StatefulWidget {
  final User cashier;

  const EditCashierScreen({Key? key, required this.cashier}) : super(key: key);

  @override
  _EditCashierScreenState createState() => _EditCashierScreenState();
}

class _EditCashierScreenState extends State<EditCashierScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.cashier.name;
    emailController.text = widget.cashier.email;
  }

  Future<void> _editCashier() async {
    if (passwordController.text == confirmPasswordController.text) {
      var userBox = Hive.box<User>('users');

      User updatedCashier = User(
        name: nameController.text,
        email: widget.cashier.email,
        password: passwordController.text.isNotEmpty
            ? passwordController.text
            : widget.cashier.password,
        role: widget.cashier.role,
        storeName: widget.cashier.storeName,
        phone: widget.cashier.phone,
        address: widget.cashier.address,
        profileImage: widget.cashier.profileImage,
      );

      int index = userBox.values
          .toList()
          .indexWhere((user) => user.email == widget.cashier.email);

      if (index != -1) {
        await userBox.putAt(index, updatedCashier);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('cashierUpdatedSuccessfully')),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CashierListScreen()),
        );
      }
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
        title: Text(localizations.translate('editCashier')),
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
              readOnly: true,
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
              onTap: _editCashier,
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
                    localizations.translate('updateCashier'),
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
