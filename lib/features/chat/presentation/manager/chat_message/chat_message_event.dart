part of 'chat_message_bloc.dart';

@immutable
sealed class ChatMessageEvent {}

class SendMessageEvent extends ChatMessageEvent {
  final String roomId;
  final String message;
  final String? type;
  final UserEntity userInfo;

  SendMessageEvent({
    required this.roomId,
    required this.message,
    required this.userInfo,
    this.type,
  });
}

class SendImageEvent extends ChatMessageEvent {
  final String roomId;
  final Uint8List fileImage;
  final String fileExtension;
  final UserEntity userInfo;

  SendImageEvent({
    required this.roomId,
    required this.fileImage,
    required this.fileExtension,
    required this.userInfo,
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
