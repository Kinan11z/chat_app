part of 'unread_count_cubit.dart';

sealed class UnreadCountState {}

final class UnreadCountInitial extends UnreadCountState {}

class UnreadCountLoaded extends UnreadCountState {
  final int count;
  UnreadCountLoaded({required this.count});
}

class UnreadCountError extends UnreadCountState {
  final String message;
  UnreadCountError({required this.message});
}
