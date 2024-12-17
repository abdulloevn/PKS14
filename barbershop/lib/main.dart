import 'package:barbershop/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barbershop/components/auth_gate.dart';
import '/pages/favourite.dart';
import 'models/auth_service.dart';
import 'models/global_data.dart';
import 'pages/cart.dart';
import 'pages/catalog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

GlobalData appData = GlobalData();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  appData.firebaseInitialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await appData.firebaseInitialization;
  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
    appData.appState?.forceUpdateState();
  });
  await appData.fetchAllData();
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Key key = UniqueKey();
  int selectedIndex = 0;
  List<Widget> pages = [
    const Catalog(),
    const Favourite(),
    const Cart(),
    AuthGate()
  ];
  @override void initState() {
    // TODO: implement initState
    super.initState();
    appData.appState = this;
  }
  void restartApp() {
    key = UniqueKey();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: AuthService.isLoggedIn() ? pages[selectedIndex] : LoginPage(),
        bottomNavigationBar:AuthService.isLoggedIn() ? BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.cut), label: "Стрижки"),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: "Избранные"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket), label: "Запись"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
          ],
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          currentIndex: selectedIndex,
          useLegacyColorScheme: true,
          onTap: (int barItemIndex) => {
            setState(() {
              selectedIndex = barItemIndex;
            })
          },
        ) : null,
      ),
    );
  }

  void forceUpdateState(){
    if (mounted){
      setState(() {
      
    });
    }
  }
}
