import 'dart:async';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../config/app_localizations.dart';
import '../welcome/WelcomeScreen.dart';

class PresentationScreen extends StatefulWidget {
  @override
  _PresentationScreenState createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  int _currentIndex = 0;
  int _loadingDots = 0;
  Timer? _timer;

  final List<Map<String, String>> _sections = [
    {
      'title': 'welcomeTitle',
      'image': 'assets/onboarding/onboarding1.png',
      'paragraph': 'welcomeParagraph',
    },
    {
      'title': 'salesInventoryTitle',
      'image': 'assets/onboarding/onboarding1.png',
      'paragraph': 'salesInventoryParagraph',
    },
    {
      'title': 'dataProtectionTitle',
      'image': 'assets/onboarding/onboarding1.png',
      'paragraph': 'dataProtectionParagraph',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startPresentation();
  }

  void _startPresentation() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick % 4 == 0 && timer.tick <= 12) {
        setState(() {
          _currentIndex = (timer.tick ~/ 4) % _sections.length;
        });
      }

      setState(() {
        _loadingDots = timer.tick % 3;
      });

      if (timer.tick == 15) {
        _timer?.cancel();
        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.scale,
            child: WelcomeScreen(),
            alignment: Alignment.center,
            duration: Duration(milliseconds: 300),
          ),
        );
      }
    });
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
            Text(
              AppLocalizations.of(context)
                  .translate(_sections[_currentIndex]['title']!),
              style: TextStyle(
                color: Color.fromARGB(255, 0, 110, 173),
                fontSize: 26,
              ),
            ),
            SizedBox(height: 20),
            Image.asset(
              _sections[_currentIndex]['image']!,
              width: 500,
              height: 500,
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)
                  .translate(_sections[_currentIndex]['paragraph']!),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "${AppLocalizations.of(context).translate('loadingText')}${'.' * _loadingDots}",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 110, 173),
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
