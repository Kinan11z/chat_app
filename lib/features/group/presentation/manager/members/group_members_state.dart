part of 'group_members_cubit.dart';

sealed class GroupMembersState {}

final class GroupMembersInitial extends GroupMembersState {}

class GroupMembersLoading extends GroupMembersState {}

class GroupMembersLoaded extends GroupMembersState {
  final List<UserEntity> members;
  GroupMembersLoaded({required this.members});
}

class GroupMembersError extends GroupMembersState {
  final String message;
  GroupMembersError({required this.message});
}
