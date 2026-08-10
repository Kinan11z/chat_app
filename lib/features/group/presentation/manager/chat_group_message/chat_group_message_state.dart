part of 'chat_group_message_bloc.dart';

@immutable
sealed class ChatGroupMessageState {}

final class ChatGroupMessageInitial extends ChatGroupMessageState {}

class ChatGroupMessageLoadding extends ChatGroupMessageState {}

final class ChatGroupMessageSuccess extends ChatGroupMessageState {
  final String message;

  ChatGroupMessageSuccess({required this.message});
}

final class ChatGroupMessageError extends ChatGroupMessageState {
  final String message;

  ChatGroupMessageError({required this.message});
}
