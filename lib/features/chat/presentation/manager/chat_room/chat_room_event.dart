part of 'chat_room_bloc.dart';

@immutable
sealed class ChatRoomEvent {}

class CreateChatRoomEvent extends ChatRoomEvent {
  final String email;

  CreateChatRoomEvent({required this.email});
}
