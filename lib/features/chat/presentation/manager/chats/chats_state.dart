part of 'chats_cubit.dart';

sealed class ChatsState {}

final class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  final List<ChatRoomEntity> rooms;
  ChatsLoaded({required this.rooms});
}

class ChatsError extends ChatsState {
  final String message;
  ChatsError({required this.message});
}
