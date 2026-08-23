part of 'groups_cubit.dart';

sealed class GroupsState {}

final class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<ChatGroupEntity> groups;
  GroupsLoaded({required this.groups});
}

class GroupsError extends GroupsState {
  final String message;
  GroupsError({required this.message});
}
