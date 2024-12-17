// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      json['customerUID'] as String,
      json['isFromAdmin'] as bool,
      json['content'] as String,
      DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'customerUID': instance.customerUID,
      'isFromAdmin': instance.isFromAdmin,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
    };
