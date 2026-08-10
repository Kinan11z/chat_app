part of 'group_bloc.dart';

@immutable
sealed class GroupState {}

final class GroupInitial extends GroupState {}

class GroupLoadding extends GroupState {}

final class GroupSuccess extends GroupState {
  final String message;

  GroupSuccess({required this.message});
}

final class GroupError extends GroupState {
  final String message;

  GroupError({required this.message});
}
