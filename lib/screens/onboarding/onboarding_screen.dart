import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';
import 'package:provider/provider.dart';

import '../../config/app_localizations.dart';
import '../../config/notifiers/language_notifier.dart';
import '../../config/notifiers/theme_notifier.dart';
import '../../config/themes/theme.dart';
import '../welcome/WelcomeScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int selectedPageIndex = 0;
  bool isDarkTheme = false;
  DateTime? backpressTime;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    Provider.of<LanguageNotifier>(context);

    final pageModelList = [
      Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Provider.of<LanguageNotifier>(context, listen: false)
                        .setLocale('es', '');
                  },
                  child: Image.asset(
                    "assets/i18n/mexico_flag.png",
                    height: size.height * 0.15,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () async {
                    await Provider.of<LanguageNotifier>(context, listen: false)
                        .setLocale('en', 'US');
                  },
                  child: Image.asset(
                    "assets/i18n/usa_flag.png",
                    height: size.height * 0.15,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            heightBox(size.height * 0.05),
            Text(
              AppLocalizations.of(context).translate('select_language'),
              style: bold18Black,
              textAlign: TextAlign.center,
            ),
            heightSpace,
            Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (value) {
                themeNotifier.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
      Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              "assets/onboarding/onboarding1.png",
              height: size.height * 0.3,
              fit: BoxFit.cover,
            ),
            heightBox(size.height * 0.09),
            Text(
              AppLocalizations.of(context).translate('welcome_onboarding'),
              style: bold18Black,
              textAlign: TextAlign.center,
            ),
            heightSpace,
            heightSpace,
            Text(
              AppLocalizations.of(context).translate('welcome_onboarding_text'),
              style: regular14Grey,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
      Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              "assets/onboarding/onboarding2.png",
              height: size.height * 0.3,
              fit: BoxFit.cover,
            ),
            heightBox(size.height * 0.09),
            Text(
              AppLocalizations.of(context).translate('welcome_onboarding1'),
              style: bold18Black,
              textAlign: TextAlign.center,
            ),
            heightSpace,
            heightSpace,
            Text(
              AppLocalizations.of(context)
                  .translate('welcome_onboarding_text1'),
              style: regular14Grey,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
      Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            const Spacer(),
            Image.asset(
              "assets/onboarding/onboarding3.png",
              height: size.height * 0.3,
              fit: BoxFit.cover,
            ),
            heightBox(size.height * 0.09),
            Text(
              AppLocalizations.of(context).translate('welcome_onboarding2'),
              style: bold18Black,
              textAlign: TextAlign.center,
            ),
            heightSpace,
            heightSpace,
            Text(
              AppLocalizations.of(context)
                  .translate('welcome_onboarding_text2'),
              style: regular14Grey,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        bool backStatus = onWillpop(context);
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                child: Onboarding(
                  swipeableBody: pageModelList,
                  startIndex: selectedPageIndex,
                  onPageChanges: (netDragDistance, pagesLength, currentIndex,
                      slideDirection) {
                    setState(() {
                      selectedPageIndex = currentIndex;
                    });
                  },
                  buildFooter: (context, netDragDistance, pagesLength,
                      currentIndex, setIndex, slideDirection) {
                    return nextAndSkipBuilder(pagesLength, context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  nextAndSkipBuilder(int pagesLength, BuildContext context) {
    return Column(
      children: [
        heightSpace,
        heightSpace,
        heightSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pagesLength, (index) {
            return _buildDot(index);
          }),
        ),
        heightSpace,
        heightSpace,
        heightSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            selectedPageIndex < pagesLength - 1
                ? TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WelcomeScreen()),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('skip'),
                      style: bold16Primary,
                    ),
                  )
                : const TextButton(
                    onPressed: null,
                    child: Text(
                      "",
                      style: bold16Primary,
                    ),
                  ),
            FloatingActionButton(
              backgroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              onPressed: () {
                if (selectedPageIndex < pagesLength - 1) {
                  setState(() {
                    selectedPageIndex++;
                  });
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                  );
                }
              },
              child: const Icon(
                Icons.arrow_forward,
                color: primaryColor,
                size: 28,
              ),
            )
          ],
        ),
      ],
    );
  }

  _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding / 2),
      height: 10,
      width: selectedPageIndex == index ? 25 : 10,
      decoration: BoxDecoration(
        color: selectedPageIndex == index ? primaryColor : whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor, width: 1.5),
      ),
    );
  }

  onWillpop(context) {
    DateTime now = DateTime.now();
    if (backpressTime == null ||
        now.difference(backpressTime!) >= const Duration(seconds: 2)) {
      backpressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: blackColor,
          content: Text(
            AppLocalizations.of(context).translate('exitPrompt'),
            style: bold15White,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}
