part of 'chat_message_bloc.dart';

@immutable
sealed class ChatMessageState {}

final class ChatMessageInitial extends ChatMessageState {}

class ChatMessageLoadding extends ChatMessageState {}

final class ChatMessageSuccess extends ChatMessageState {
  final String message;

  ChatMessageSuccess({required this.message});
}

final class ChatMessageError extends ChatMessageState {
  final String message;

  ChatMessageError({required this.message});
}
