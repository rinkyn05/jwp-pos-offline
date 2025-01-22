import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../config/app_localizations.dart';
import '../../../config/models/user_model.dart';
import '../splash/splash_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future<void> _changePasswordWithCurrentPassword() async {
    var box = Hive.box<User>('users');

    try {
      User user = box.values.firstWhere(
        (user) =>
            user.email == emailController.text &&
            user.password == currentPasswordController.text,
      );

      if (newPasswordController.text == confirmPasswordController.text) {
        user.password = newPasswordController.text;

        var userKey = box.keyAt(box.values.toList().indexOf(user));

        await box.put(userKey, user);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('passwordChanged')),
        ));

        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('invalidCredentialsOrPasswordMismatch')),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).translate('userNotFound')),
      ));
    }
  }

  Future<void> _changePasswordWithoutCurrentPassword() async {
    var box = Hive.box<User>('users');

    try {
      User user = box.values.firstWhere(
        (user) =>
            user.name == nameController.text &&
            user.email == emailController.text &&
            user.storeName == storeNameController.text,
      );

      if (newPasswordController.text == confirmPasswordController.text) {
        user.password = newPasswordController.text;

        var userKey = box.keyAt(box.values.toList().indexOf(user));

        await box.put(userKey, user);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('passwordChanged')),
        ));

        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('invalidUserOrPasswordMismatch')),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).translate('userNotFound')),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('password_recovery')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.translate('with_current_password')),
            Tab(text: localizations.translate('without_current_password')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('email'),
                  ),
                ),
                TextField(
                  controller: currentPasswordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    label: Text(
                      localizations.translate('current_password'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 110, 173),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: newPasswordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    label: Text(
                      localizations.translate('new_password'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 110, 173),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    label: Text(
                      localizations.translate('confirm_new_password'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 110, 173),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _changePasswordWithCurrentPassword,
                  child: Container(
                    height: 50,
                    width: double.infinity,
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
                        localizations.translate('change_password'),
                        style: const TextStyle(
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('name'),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('email'),
                  ),
                ),
                TextField(
                  controller: storeNameController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('store_name'),
                  ),
                ),
                TextField(
                  controller: newPasswordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    label: Text(
                      localizations.translate('new_password'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 110, 173),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    label: Text(
                      localizations.translate('confirm_new_password'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 110, 173),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _changePasswordWithoutCurrentPassword,
                  child: Container(
                    height: 50,
                    width: double.infinity,
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
                        localizations.translate('change_password'),
                        style: const TextStyle(
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
        ],
      ),
    );
  }
}
