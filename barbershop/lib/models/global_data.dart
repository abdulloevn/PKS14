import 'dart:convert';
import 'package:barbershop/main.dart';
import 'package:barbershop/models/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import '/models/account.dart';
import '/pages/account.dart';
import '/pages/cart.dart';
import '/models/shop_item.dart';
import '/pages/favourite.dart';
import 'cart_item.dart';
import 'order.dart';

class GlobalData
{
  List<ShopItem> shopItems = [];
  List<ShopItem> favouriteItems = [];
  List<CartItem> cartItems = [];
  List<Order> orders = [];
  User? account;
  AccountPageState? accountPageState; 
  FavouriteState? favouriteState; 
  MyAppState? appState;
  CartState? cartState;
  final String serverHost = /*"192.168.60.47"*/ "185.251.90.5";
  final int serverPort = 8080;
  Future<FirebaseApp>? firebaseInitialization;
  Future<void> fetchAllData() async{
    final servicesResponse = await http.get(Uri.parse("http://$serverHost:$serverPort/services"));
    List<dynamic> servicesListRaw = jsonDecode(servicesResponse.body);
    shopItems = servicesListRaw.map((rawObject) => ShopItem.fromJson(rawObject)).toList();

    // only if user is logged in
    if (!AuthService.isLoggedIn()) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favouriteItemsResponse = await http.get(Uri.parse("http://$serverHost:$serverPort/favourite?uid=${uid}"));
    List<dynamic> favouriteItemsRaw = jsonDecode(favouriteItemsResponse.body);
    favouriteItems = favouriteItemsRaw.map((rawObject) => ShopItem.fromJson(rawObject)).toList();

    final cartItemsResponse = await http.get(Uri.parse("http://$serverHost:$serverPort/cart?uid=${uid}"));
    List<dynamic> cartItemsRaw = jsonDecode(cartItemsResponse.body);
    cartItems = cartItemsRaw.map((rawObject) => CartItem.fromJson(rawObject)).toList();

    // final accountResponse = await http.get(Uri(scheme: "http", host: serverHost, port: serverPort, path: "/user", queryParameters: {"id" : "1"} ));
    // Map<String, dynamic> accountRaw =  jsonDecode(accountResponse.body);
    account = FirebaseAuth.instance.currentUser;
    
    final ordersResponse = await http.get(Uri.parse("http://$serverHost:$serverPort/orders?uid=${uid}"));
    List<dynamic> ordersRaw = jsonDecode(ordersResponse.body);
    orders = ordersRaw.map((rawObject) => Order.fromJson(rawObject)).toList();
    return;
  }

  int indexOfFavouriteItem(ShopItem itemToCheck)
  {
    for (int i = 0; i < favouriteItems.length; i++)
    {
      if (favouriteItems[i].ID == itemToCheck.ID)
      {
        return i;
      }
    }
    return -1;
  }
  int indexOfCartItem(ShopItem itemToCheck)
  {
    for (int i = 0; i < cartItems.length; i++)
    {
      if (cartItems[i].item.ID== itemToCheck.ID)
      {
        return i;
      }
    }
    return -1;
  }
  int indexOfShopItem(int id)
  {
    for (int i = 0; i < shopItems.length; i++)
    {
      if (shopItems[i].ID == id)
      {
        return i;
      }
    }
    return -1;
  }
}