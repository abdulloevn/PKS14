// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

//  dart run build_runner build --delete-conflicting-outputs

part 'message.g.dart';
@JsonSerializable()
class Message {
  Message(this.customerUID, this.isFromAdmin, this.content, this.timestamp);
  String customerUID;
  bool isFromAdmin;
  String content;
  DateTime timestamp;
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}