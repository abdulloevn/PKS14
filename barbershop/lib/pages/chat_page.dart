import 'package:barbershop/main.dart';
import 'package:barbershop/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  ChatPage(this.selectedCustomerUID);
  String? selectedCustomerUID;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List<Message> chatMessages = [];
   
  Future<void> sendMessage() async {
    String content = messageController.text;
    if (content.isEmpty) return;
    String customerUID = widget.selectedCustomerUID ?? appData.account!.uid;
    final message = Message(customerUID, widget.selectedCustomerUID != null, content, DateTime.now());
    await FirebaseFirestore.instance
        .collection("customer_chats")
        .doc(customerUID)
        .set({
          "uid" : customerUID,
          "name": appData.account!.displayName,
          "email": appData.account!.email,
          "lastMessageContent": message.content
        }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection("customer_chats")
        .doc(customerUID)
        .collection("messages")
        .add(message.toJson());
    messageController.clear();
  }

  Future<void> getMessages() async {
    String customerUID = widget.selectedCustomerUID ?? appData.account!.uid;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("customer_chats")
        .doc(customerUID)
        .collection("messages")
        .orderBy('timestamp', descending: false)
        .get();

    chatMessages = querySnapshot.docs
        .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    forceUpdateState();
  }

  @override
  void initState() {
    super.initState();
    getMessages();
  }

  void forceUpdateState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Связь с ${widget.selectedCustomerUID == null ? "продавцом" : "клиентом"}"),
      ),
      body: Column(
        children: [
          Expanded(
              child: chatMessages.isEmpty
                  ? Center(child: Text("Здесь пусто. Отправьте сообщение!"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        Message selectedMessage = chatMessages[index];
                        BubbleType bubbleType;
                        Alignment alignment;
                        Color backgroundColor;
                        double leftMargin;
                        double rightMargin;
                        bool isMessageOwner = widget.selectedCustomerUID == null && !selectedMessage.isFromAdmin || 
                                              widget.selectedCustomerUID != null && selectedMessage.isFromAdmin;
                        if (isMessageOwner) {
                          bubbleType = BubbleType.sendBubble;
                          alignment = Alignment.topRight;
                          backgroundColor = Colors.black;
                          leftMargin = MediaQuery.of(context).size.width / 4;
                          rightMargin = 0;
                        } else {
                          bubbleType = BubbleType.receiverBubble;
                          alignment = Alignment.topLeft;
                          backgroundColor =
                              Theme.of(context).colorScheme.onSecondary;
                          rightMargin = MediaQuery.of(context).size.width / 3;
                          leftMargin = 0;
                        }
                        return Column(
                          children: [
                            ChatBubble(
                              margin: EdgeInsets.only(top: 12.0, left: leftMargin, right: rightMargin),
                              clipper: ChatBubbleClipper5(type: bubbleType),
                              child: Text(selectedMessage.content),
                              alignment: alignment,
                              backGroundColor: backgroundColor,
                              shadowColor: backgroundColor,
                            ),
                            Align(
                                alignment: alignment,
                                child: Text(
                                  "${selectedMessage.timestamp.hour}:${selectedMessage.timestamp.minute}",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                                ))
                          ],
                        );
                      },
                    )),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 8.0, bottom: 20.0, top: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(label: Text("Сообщение")),
                )),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () async {
                    await sendMessage();
                    await getMessages();
                  },
                  icon: Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
