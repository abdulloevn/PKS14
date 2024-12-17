// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

//  dart run build_runner build --delete-conflicting-outputs

part 'chat_user.g.dart';
@JsonSerializable()
class ChatUser {
  ChatUser(this.email, this.uid, this.name, this.lastMessageContent);
  String email;
  String uid;
  String name;
  String lastMessageContent = "";
  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserToJson(this);
}