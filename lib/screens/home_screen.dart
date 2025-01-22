import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import '../../config/app_localizations.dart';
import '../config/models/user_model.dart';
import 'cajero/cajero_home_screen.dart';
import 'tienda/shop_home_screen.dart';
import 'welcome/WelcomeScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _loadingDots = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startHomeScreen();
  }

  Future<void> _startHomeScreen() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _loadingDots = timer.tick % 3;
      });
    });

    await Future.delayed(Duration(seconds: 3));

    var box = Hive.box<User>('users');
    var userBox = Hive.box('currentUser');
    String? currentUserEmail = userBox.get('email');

    User? currentUser = box.values.firstWhereOrNull(
      (user) => user.email == currentUserEmail,
    );

    _timer?.cancel();

    if (currentUser != null) {
      if (currentUser.role == 'Tienda') {
        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.scale,
            child: ShopHomeScreen(),
            alignment: Alignment.center,
            duration: Duration(milliseconds: 300),
          ),
        );
      } else if (currentUser.role == 'Cajero') {
        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.scale,
            child: CajeroHomeScreen(),
            alignment: Alignment.center,
            duration: Duration(milliseconds: 300),
          ),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.scale,
          child: WelcomeScreen(),
          alignment: Alignment.center,
          duration: Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/gif/weed-walking-weed.gif',
              width: 500,
              height: 500,
            ),
            SizedBox(height: 20),
            Text(
              "${AppLocalizations.of(context).translate('loadingText')}${'.' * _loadingDots}",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 110, 173),
                fontSize: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
