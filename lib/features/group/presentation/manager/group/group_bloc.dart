import 'package:bloc/bloc.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:meta/meta.dart';

import '../../../domain/usecases/create_group_use_case.dart';
import '../../../domain/usecases/edit_group_use_case.dart';
import '../../../domain/usecases/promote_member_use_case.dart';
import '../../../domain/usecases/remove_member_use_case.dart';
import '../../../domain/usecases/remove_promote_use_case.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final CreateGroupUseCase createGroupUseCase;
  final EditGroupUseCase editGroupUseCase;
  final RemoveMemberUseCase removeMemberUseCase;
  final RemovePromoteUseCase removePromoteUseCase;
  final PromoteMemberUseCase promoteMemberUseCase;

  GroupBloc({
    required this.createGroupUseCase,
    required this.editGroupUseCase,
    required this.removeMemberUseCase,
    required this.removePromoteUseCase,
    required this.promoteMemberUseCase,
  }) : super(GroupInitial()) {
    on<CreateGroupEvent>(_createGroup);
    on<EditGroupEvent>(_editGroup);
    on<RemoveMemberEvent>(_removeMember);
    on<RemovePromoteEvent>(_removePromote);
    on<PromoteMemberEvent>(_promoteMember);
  }

  Future<void> _createGroup(
    CreateGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoadding());
    final result = await createGroupUseCase(
      CreateGroupParams(
        name: event.name,
        members: event.members,
      ),
    );
    result.fold(
      (failure) => emit(GroupError(message: failure.message)),
      (_) => emit(GroupSuccess(message: AppStrings.createGroupSuccess)),
    );
  }

  Future<void> _editGroup(
    EditGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoadding());
    final result = await editGroupUseCase(
      EditGroupParams(
        groupId: event.groupId,
        name: event.name,
        members: event.members,
      ),
    );
    result.fold(
      (failure) => emit(GroupError(message: failure.message)),
      (_) => emit(GroupSuccess(message: AppStrings.editGroupSuccess)),
    );
  }

  Future<void> _removeMember(
    RemoveMemberEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoadding());
    final result = await removeMemberUseCase(
      RemoveMemberParams(
        groupId: event.groupId,
        memberId: event.memberId,
      ),
    );
    result.fold(
      (failure) => emit(GroupError(message: failure.message)),
      (_) => emit(GroupSuccess(message: AppStrings.removeMemberSuccess)),
    );
  }

  Future<void> _removePromote(
    RemovePromoteEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoadding());
    final result = await removePromoteUseCase(
      RemovePromoteParams(
        groupId: event.groupId,
        memberId: event.memberId,
      ),
    );
    result.fold(
      (failure) => emit(GroupError(message: failure.message)),
      (_) => emit(GroupSuccess(message: AppStrings.removePromoteSuccess)),
    );
  }

  Future<void> _promoteMember(
    PromoteMemberEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoadding());
    final result = await promoteMemberUseCase(
      PromoteMemberParams(
        groupId: event.groupId,
        memberId: event.memberId,
      ),
    );
    result.fold(
      (failure) => emit(GroupError(message: failure.message)),
      (_) => emit(GroupSuccess(message: AppStrings.promoteMemberSuccess)),
    );
  }
}
