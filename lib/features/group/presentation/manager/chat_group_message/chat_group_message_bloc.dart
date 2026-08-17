import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/datasource/group_remote_data_source.dart';
import '../../../data/models/chat_group_model.dart';
import '../../../data/repositories/group_repository_imp.dart';
import '../../../domain/usecases/send_group_image_use_case.dart';
import '../../../domain/usecases/send_group_message_use_case.dart';

part 'chat_group_message_event.dart';
part 'chat_group_message_state.dart';

class ChatGroupMessageBloc
    extends Bloc<ChatGroupMessageEvent, ChatGroupMessageState> {
  ChatGroupMessageBloc() : super(ChatGroupMessageInitial()) {
    on<SendMessageGroupEvent>(_sendGroupMessage);
    on<SendImageGroupEvent>(_sendGroupImage);
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
        groupInfo: event.groupInfo,
        message: event.message,
        type: event.type,
      );
      emit(ChatGroupMessageSuccess(message: 'Send Message Succsfully'));
    } catch (e) {
      emit(ChatGroupMessageError(message: e.toString()));
    }
  }

  Future<void> _sendGroupImage(
      SendImageGroupEvent event, Emitter<ChatGroupMessageState> emit) async {
    emit(ChatGroupMessageLoadding());
    try {
      final usecase = SendGroupImageUseCase(
        repository: GroupRepositoryImp(
          remoteDataSource: GroupRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        groupInfo: event.groupInfo,
        imageFile: event.imageFile,
      );
      emit(ChatGroupMessageSuccess(message: 'Send Image Succsfully'));
    } catch (e) {
      emit(ChatGroupMessageError(message: e.toString()));
    }
  }
}
