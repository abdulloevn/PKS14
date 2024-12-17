
import 'package:barbershop/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<UserCredential> login(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    _firestore.collection("users").doc(userCredential.user!.uid).set(
        {
          "uid": userCredential.user!.uid,
          "email": email,
          "name": userCredential.user!.displayName  
        });
    appData.account = userCredential.user;
    appData.accountPageState!.forceUpdateState();
    return userCredential;
  }

  Future<UserCredential> register(String email, String password, String name) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firestore.collection("users").doc(userCredential.user!.uid).set(
        {
          "uid": userCredential.user!.uid,
          "email": email,
          "name": name  
        });
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      await logout();
      return userCredential;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser()  {
    return _firebaseAuth.currentUser;
  }

  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.displayName != null;
  }
  static bool isAdmin() {
    return isLoggedIn() && FirebaseAuth.instance.currentUser!.email != null && FirebaseAuth.instance.currentUser!.email == "admin@admin.com";
  }
}