import 'dart:math';

import 'package:barbershop/models/chat_user.dart';
import 'package:barbershop/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget{
  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  List<ChatUser> chatUsers = [];
  Future<void> getChatUsers() async {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("customer_chats")
        .get();

    chatUsers = querySnapshot.docs
        .map((doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    forceUpdateState();
  }

  String limitWords(String text, int maxWordsCount, int maxChatactersCount) {
    String output = "";
    int wordCount = 0;
    for (final word in text.split(" ")) {
      if (wordCount >= maxWordsCount || (output.length + word.length) > maxChatactersCount) {
        output += "...";
        break;
      }
      output += "$word ";
      wordCount++;
    }
    return output;
  }
  void forceUpdateState() {
    if (!mounted) return;

    setState(() {
      
    });
  }
  @override
  void initState() {
    super.initState();
    getChatUsers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Список чатов"),),
      body: chatUsers.isEmpty ? Center(child: Text("Нет чатов с клиентами")) : ListView.builder(
        itemCount: chatUsers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(chatUsers[index].uid)));
            },
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 30),
                  SizedBox(width: 10,),
                  Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chatUsers[index].name, style: TextStyle(fontWeight: FontWeight.w600),),
                  Text(chatUsers[index].email, style: TextStyle(color: Theme.of(context).colorScheme.primaryFixedDim),),
                  SizedBox(height: 3,),
                  Text("Сообщение: " + limitWords(chatUsers[index].lastMessageContent, 5, 25), style: TextStyle(fontWeight: FontWeight.w300),)
                ],
              ),),
                ],
              )
            ),
          );
      },),
    );
  }
}