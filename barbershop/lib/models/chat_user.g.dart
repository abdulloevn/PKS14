// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatUser _$ChatUserFromJson(Map<String, dynamic> json) => ChatUser(
      json['email'] as String,
      json['uid'] as String,
      json['name'] as String,
      json['lastMessageContent'] as String,
    );

Map<String, dynamic> _$ChatUserToJson(ChatUser instance) => <String, dynamic>{
      'email': instance.email,
      'uid': instance.uid,
      'name': instance.name,
      'lastMessageContent': instance.lastMessageContent,
    };
