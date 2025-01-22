import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../config/app_localizations.dart';

import '../login_or_register/login/loginScreen.dart';
import '../login_or_register/register/regScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 0, 110, 173),
          Color.fromARGB(255, 0, 36, 56),
        ])),
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(top: 200.0),
            child: Image(image: AssetImage('assets/logo.png')),
          ),
          const SizedBox(
            height: 50,
          ),
          Text(
            localizations.translate('welcome'),
            style: const TextStyle(fontSize: 30, color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: LoginScreen(),
                  duration: Duration(milliseconds: 300),
                ),
              );
              ;
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
              child: Center(
                child: Text(
                  localizations.translate('sign_in'),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RegScreen()));
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
              child: Center(
                child: Text(
                  localizations.translate('sign_up'),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Text(
          //   localizations.translate('login_with_social_media'), // Clave de traducción
          //   style: const TextStyle(fontSize: 17, color: Colors.white),
          // ),
          // const SizedBox(
          //   height: 12,
          // ),
          // const Image(image: AssetImage('assets/social.png')),
        ]),
      ),
    );
  }
}
