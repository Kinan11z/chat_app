part of 'messages_cubit.dart';

sealed class MessagesState {}

final class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessageEntity> messages;
  MessagesLoaded({required this.messages});
}

class MessagesError extends MessagesState {
  final String message;
  MessagesError({required this.message});
}
