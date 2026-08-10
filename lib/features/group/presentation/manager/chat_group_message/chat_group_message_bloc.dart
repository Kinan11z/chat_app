import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/datasource/group_remote_data_source.dart';
import '../../../data/repositories/group_repository_imp.dart';
import '../../../domain/usecases/send_group_message_use_case.dart';

part 'chat_group_message_event.dart';
part 'chat_group_message_state.dart';

class ChatGroupMessageBloc
    extends Bloc<ChatGroupMessageEvent, ChatGroupMessageState> {
  ChatGroupMessageBloc() : super(ChatGroupMessageInitial()) {
    on<SendMessageGroupEvent>(_sendGroupMessage);
  }
  Future<void> _sendGroupMessage(
      SendMessageGroupEvent event, Emitter<ChatGroupMessageState> emit) async {
    emit(ChatGroupMessageLoadding());
    try {
      final usecase = SendGroupMessageUseCase(
        repository: GroupRepositoryImp(
          remoteDataSource: GroupRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        groupId: event.groupId,
        message: event.message,
        type: event.type,
      );
      emit(ChatGroupMessageSuccess(message: 'Send Message Succsfully'));
    } catch (e) {
      emit(ChatGroupMessageError(message: e.toString()));
    }
  }
}
