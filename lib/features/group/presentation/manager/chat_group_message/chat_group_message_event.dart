part of 'chat_group_message_bloc.dart';

@immutable
sealed class ChatGroupMessageEvent {}

class SendMessageGroupEvent extends ChatGroupMessageEvent {
  final String message;
  final ChatGroupModel groupInfo;
  final String? type;
  SendMessageGroupEvent({
    required this.message,
    required this.groupInfo,
    this.type,
  });
}

class SendImageGroupEvent extends ChatGroupMessageEvent {
  final File imageFile;
  final ChatGroupModel groupInfo;
  SendImageGroupEvent({
    required this.imageFile,
    required this.groupInfo,
  });
}
