part of 'chat_group_message_bloc.dart';

@immutable
sealed class ChatGroupMessageEvent {}

class SendMessageGroupEvent extends ChatGroupMessageEvent {
  final String message;
  final String groupId;
  final String? type;
  SendMessageGroupEvent({
    required this.message,
    required this.groupId,
    this.type,
  });
}
