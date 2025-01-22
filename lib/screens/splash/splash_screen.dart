import 'dart:async';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_localizations.dart';
import '../home_screen.dart';
import '../presentation_screen/presentation_screen.dart';
import '../welcome/WelcomeScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _loadingDots = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  Future<void> _startSplashScreen() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _loadingDots = timer.tick % 3;
      });
    });

    await Future.delayed(Duration(seconds: 3));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? false;

    _timer?.cancel();

    if (isFirstTime) {
      prefs.setBool('isFirstTime', false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PresentationScreen()),
      );
    } else {
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.scale,
            child: HomeScreen(),
            alignment: Alignment.center,
            duration: Duration(milliseconds: 300),
          ),
        );
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
