import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barbershop/main.dart';
import 'package:barbershop/pages/account.dart';
import 'package:barbershop/pages/login_page.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: appData.firebaseInitialization, builder:(context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(),)
        );
      }
      return StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting)
        {
          return CircularProgressIndicator();
        }
        if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.displayName != null)
        {
          return AccountPage();
        }
        return LoginPage();
      },);

      // final session = snapshot.hasData ? snapshot.data!.session : null;
      // if (session != null)
      // {
      //   return const AccountPage();
      // }
      // else
      // {
      //     return LoginPage();
      // }
    });
  }
}

