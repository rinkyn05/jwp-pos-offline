import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_localizations.dart';
import '../../config/models/user_model.dart';
import '../welcome/WelcomeScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String storeName = "";
  String role = "";
  String profileImage = "assets/logo.png";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var box = Hive.box<User>('users');
    var userBox = Hive.box('currentUser');
    String? currentUserEmail = userBox.get('email');

    User? currentUser = box.values.firstWhereOrNull(
      (user) => user.email == currentUserEmail,
    );

    if (currentUser != null) {
      setState(() {
        name = currentUser.name;
        email = currentUser.email;
        storeName = currentUser.storeName;
        role = currentUser.role;
        profileImage = currentUser.profileImage;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    //await prefs.setBool('isFirstTime', false);

    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.scale,
        child: WelcomeScreen(),
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('profile')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(profileImage),
            ),
            const SizedBox(height: 20),
            Text("${AppLocalizations.of(context).translate('name')}: $name",
                style: const TextStyle(fontSize: 18)),
            Text("${AppLocalizations.of(context).translate('email')}: $email",
                style: const TextStyle(fontSize: 18)),
            Text(
                "${AppLocalizations.of(context).translate('store_name')}: $storeName",
                style: const TextStyle(fontSize: 18)),
            Text("${AppLocalizations.of(context).translate('role')}: $role",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _logout,
              child: Text(AppLocalizations.of(context).translate('logout')),
            ),
          ],
        ),
      ),
    );
  }
}
