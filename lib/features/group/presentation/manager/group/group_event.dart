part of 'group_bloc.dart';

@immutable
sealed class GroupEvent {}

class CreateGroupEvent extends GroupEvent {
  final String name;
  final List<String> members;

  CreateGroupEvent({
    required this.name,
    required this.members,
  });
}

class EditGroupEvent extends GroupEvent {
  final String groupId;
  final String name;
  final List<String> members;

  EditGroupEvent({
    required this.groupId,
    required this.name,
    required this.members,
  });
}

class RemoveMemberEvent extends GroupEvent {
  final String memberId;
  final String groupId;

  RemoveMemberEvent({
    required this.groupId,
    required this.memberId,
  });
}

class RemovePromoteEvent extends GroupEvent {
  final String memberId;
  final String groupId;

  RemovePromoteEvent({
    required this.groupId,
    required this.memberId,
  });
}

class PromoteMemberEvent extends GroupEvent {
  final String memberId;
  final String groupId;

  PromoteMemberEvent({
    required this.groupId,
    required this.memberId,
  });
}
