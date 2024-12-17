import 'package:barbershop/pages/chat_list.dart';
import 'package:barbershop/pages/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:barbershop/models/auth_service.dart';
import 'package:barbershop/pages/orders_page.dart';
import '/main.dart';
import '/pages/account_update.dart';
class AccountPage extends StatefulWidget{
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    appData.accountPageState = this;
  }
  void forceUpdateState()
  {
    if (!mounted) return;
    setState(() {
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100,),
            const Icon(Icons.account_circle, size: 200.0),
            const SizedBox(height: 10,),
            Text(/*appData.account!.Name*/ appData.account!.displayName as String, style: const TextStyle(
              fontSize: 22
            ),),
            const SizedBox(height: 10,),
            Text(/*appData.account!.Email*/ appData.account!.email!),
            //const SizedBox(height: 10,),
            //Text(appData.account!.phoneNumber),
            const SizedBox(height: 20,),

            // AuthService.isAdmin() ? const Center() :
            // TextButton(onPressed: (){
            //   Navigator.push(context, MaterialPageRoute(builder: (context) => AccountUpdatePage()));
            // }, child: const Text("Обновить данные", style: TextStyle(fontSize: 18),),),

            AuthService.isAdmin() ? const Center() :
             TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage()));
            }, child: const Text("Мои заказы", style: TextStyle(fontSize: 18),),),

            AuthService.isAdmin() ? const Center() : 
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(null)));
            }, child: const Text("Чат с продавцом", style: TextStyle(fontSize: 18),),),
            
            AuthService.isAdmin() ? 
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatList()));
            }, child: const Text("Чат с клиентами", style: TextStyle(fontSize: 18),),) : const Center()
          ],
        ),
      ),
      persistentFooterButtons: [
        SizedBox.expand(child: TextButton(onPressed: () async {
          final authService = AuthService();
          await authService.logout();
        }, child: const Text("Выйти", style: TextStyle(fontSize: 18),),))
      ],
    );
  }
}