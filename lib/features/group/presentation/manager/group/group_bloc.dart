import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/datasource/group_remote_data_source.dart';
import '../../../data/repositories/group_repository_imp.dart';
import '../../../domain/usecases/edit_group_use_case.dart';
import '../../../domain/usecases/group_use_case.dart';
import '../../../domain/usecases/promote_member_use_case.dart';
import '../../../domain/usecases/remove_member_use_case.dart';
import '../../../domain/usecases/remove_promote_use_case.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc() : super(GroupInitial()) {
    on<CreateGroupEvent>(_createGroup);
    on<EditGroupEvent>(_editGroup);
    on<RemoveMemberEvent>(_removeMember);
    on<RemovePromoteEvent>(_removePromote);
    on<PromoteMemberEvent>(_PromoteMember);
  }
  Future<void> _createGroup(
      CreateGroupEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoadding());
    try {
      final usecase = GroupUseCase(
        repository: GroupRepositoryImp(
          remoteDataSource: GroupRemoteDataSourceImp(),
        ),
      );
      await usecase.call(name: event.name, members: event.members);
      emit(GroupSuccess(message: 'Group Created Succsfully'));
    } catch (e) {
      emit(GroupError(message: e.toString()));
    }
  }

  Future<void> _editGroup(
      EditGroupEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoadding());
    try {
      final usecase = EditGroupUseCase(
        repository: GroupRepositoryImp(
          remoteDataSource: GroupRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        groupId: event.groupId,
        name: event.name,
        members: event.members,
      );
      emit(GroupSuccess(message: 'Group Edited Successfully'));
    } catch (e) {
      emit(GroupError(message: e.toString()));
    }
  }

  Future<void> _removeMember(
      RemoveMemberEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoadding());
    try {
      final usecase = RemoveMemberUseCase(
        repository: GroupRepositoryImp(
          remoteDataSource: GroupRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        memberId: event.memberId,
        groupId: event.groupId,
      );
      emit(GroupSuccess(message: 'Member Removed Successfully'));
    } catch (e) {
      emit(GroupError(message: e.toString()));
    }
  }

  Future<void> _removePromote(
      RemovePromoteEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoadding());
    try {
      final usecase = RemovePromoteUseCase(
        repository: GroupRepositoryImp(
          remoteDataSource: GroupRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        memberId: event.memberId,
        groupId: event.groupId,
      );
      emit(GroupSuccess(message: 'Member Removed Successfully'));
    } catch (e) {
      emit(GroupError(message: e.toString()));
    }
  }

  Future<void> _PromoteMember(
      PromoteMemberEvent event, Emitter<GroupState> emit) async {
    emit(GroupLoadding());
    try {
      final usecase = PromoteMemberUseCase(
        repository: GroupRepositoryImp(
          remoteDataSource: GroupRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        memberId: event.memberId,
        groupId: event.groupId,
      );
      emit(GroupSuccess(message: 'Member Promoted Successfully'));
    } catch (e) {
      emit(GroupError(message: e.toString()));
    }
  }
}
