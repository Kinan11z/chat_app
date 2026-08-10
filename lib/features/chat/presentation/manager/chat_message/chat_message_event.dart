part of 'chat_message_bloc.dart';

@immutable
sealed class ChatMessageEvent {}

class SendMessageEvent extends ChatMessageEvent {
  final String uid;
  final String roomId;
  final String message;
  final String? type;

  SendMessageEvent({
    required this.uid,
    required this.roomId,
    required this.message,
    this.type,
  });
}

class SendImageEvent extends ChatMessageEvent {
  final String uid;
  final String roomId;
  final File fileImage;

  SendImageEvent({
    required this.uid,
    required this.roomId,
    required this.fileImage,
  });
}

class ReadMessageEvent extends ChatMessageEvent {
  final String roomId;
  final String messageId;

  ReadMessageEvent({
    required this.roomId,
    required this.messageId,
  });
}

class DeleteMessageEvent extends ChatMessageEvent {
  final String roomId;
  final List<String> messageIds;

  DeleteMessageEvent({
    required this.roomId,
    required this.messageIds,
  });
}
