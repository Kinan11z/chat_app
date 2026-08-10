part of 'chat_room_bloc.dart';

@immutable
sealed class ChatRoomState {}

final class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoadding extends ChatRoomState {}

final class ChatRoomSuccess extends ChatRoomState {
  final String message;

  ChatRoomSuccess({required this.message});
}

final class ChatRoomError extends ChatRoomState {
  final String message;

  ChatRoomError({required this.message});
}
