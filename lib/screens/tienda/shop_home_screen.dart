import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../../config/app_localizations.dart';
import '../../config/models/user_model.dart';
import '../../config/notifiers/theme_notifier.dart';
import '../../config/notifiers/language_notifier.dart';
import '../company_info/company_info_screen.dart';
import '../pos/inventory.dart';
import '../pos/pos_screen.dart';
import '../pos/sales_screen.dart';
import '../tienda/add_cashiers/cashiers_list_screen.dart';
import '../profile/profile_screen.dart';
import '../tienda/add_products/products_list_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({Key? key}) : super(key: key);

  @override
  _ShopHomeScreenState createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  int _selectedIndex = 0;
  String name = "";
  String email = "";
  String storeName = "";
  String role = "";
  String profileImage = "assets/logo.png";
  String selectedFlag = "";

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const POSScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductListScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SalesScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InventoryScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CashierListScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final languageNotifier = Provider.of<LanguageNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('home_title')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 110, 173),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(profileImage),
                  ),
                  Text(
                    name.isEmpty
                        ? AppLocalizations.of(context).translate('no_available')
                        : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    email.isEmpty
                        ? AppLocalizations.of(context).translate('no_available')
                        : email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    storeName.isEmpty
                        ? AppLocalizations.of(context).translate('no_available')
                        : storeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, size: 30),
              title: Text(AppLocalizations.of(context).translate('home')),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle, size: 30),
              title: Text(AppLocalizations.of(context).translate('profile')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_sharp, size: 30),
              title: Text(AppLocalizations.of(context).translate('info')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompanyInfoScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, size: 30),
              title: Text(AppLocalizations.of(context).translate('language')),
              onTap: () {
                _showLanguageDialog(context, languageNotifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.style, size: 30),
              title:
                  Text(AppLocalizations.of(context).translate('change_theme')),
            ),
            Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (value) {
                themeNotifier.toggleTheme(value);
              },
            ),
            Spacer(),
            ListTile(
              title: Center(
                child: Text(
                  AppLocalizations.of(context).translate('version') + ' 1.0',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompanyInfoScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: const POSScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 40,
            ),
            label: localizations.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
              size: 40,
            ),
            label: localizations.translate('products'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.attach_money,
              size: 40,
            ),
            label: localizations.translate('sales'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.money,
              size: 40,
            ),
            label: localizations.translate('inventory'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.group,
              size: 40,
            ),
            label: localizations.translate('cashier'),
          ),
        ],
        selectedItemColor: Color.fromARGB(255, 0, 110, 173),
        unselectedItemColor: const Color.fromARGB(255, 78, 78, 78),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, LanguageNotifier languageNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                  AppLocalizations.of(context).translate('select_language')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFlag = "assets/i18n/mexico_flag.png";
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  selectedFlag == "assets/i18n/mexico_flag.png"
                                      ? Colors.blue
                                      : Colors.transparent,
                              width: 3.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.asset(
                            'assets/i18n/mexico_flag.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFlag = "assets/i18n/usa_flag.png";
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedFlag == "assets/i18n/usa_flag.png"
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 3.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.asset(
                            'assets/i18n/usa_flag.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (selectedFlag.isNotEmpty)
                    Text(
                      selectedFlag == 'assets/i18n/mexico_flag.png'
                          ? 'Español'
                          : 'English',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context).translate('cancel')),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedFlag == 'assets/i18n/mexico_flag.png') {
                      await languageNotifier.setLocale('es', '');
                    } else if (selectedFlag == 'assets/i18n/usa_flag.png') {
                      await languageNotifier.setLocale('en', 'US');
                    }

                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context).translate('ok')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
