import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_localizations.dart';
import 'config/models/product_model.dart';
import 'config/models/user_model.dart';
import 'config/models/sale_model.dart';
import 'config/notifiers/theme_notifier.dart';
import 'config/notifiers/language_notifier.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SaleAdapter());
  await Hive.openBox<User>('users');
  await Hive.openBox<Product>('products');
  await Hive.openBox<Sale>('sales');
  await Hive.openBox('currentUser');

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? languageCode = prefs.getString('languageCode') ?? 'es';
  final String? countryCode = prefs.getString('countryCode') ?? 'MX';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(
            create: (context) =>
                LanguageNotifier()..setLocale(languageCode!, countryCode!)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final languageNotifier = Provider.of<LanguageNotifier>(context);

    return MaterialApp(
      supportedLocales: [
        Locale('es', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: languageNotifier.locale,
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      debugShowCheckedModeBanner: false,
      title: 'JUST WPOS OFFLINE',
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SplashScreen(),
    );
  }
}