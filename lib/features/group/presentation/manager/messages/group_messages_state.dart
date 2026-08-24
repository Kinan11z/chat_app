part of 'group_messages_cubit.dart';

sealed class GroupMessagesState {}

final class GroupMessagesInitial extends GroupMessagesState {}

class GroupMessagesLoading extends GroupMessagesState {}

class GroupMessagesLoaded extends GroupMessagesState {
  final List<GroupMessageEntity> messages;
  GroupMessagesLoaded({required this.messages});
}

class GroupMessagesError extends GroupMessagesState {
  final String message;
  GroupMessagesError({required this.message});
}
