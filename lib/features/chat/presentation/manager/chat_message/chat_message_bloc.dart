import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/datasource/chat_remote_data_source.dart';
import '../../../data/repositories/chat_repository_imp.dart';
import '../../../domain/usecases/delete_message_use_case.dart';
import '../../../domain/usecases/read_message_use_case.dart';
import '../../../domain/usecases/send_image_use_case.dart';
import '../../../domain/usecases/send_message_use_case.dart';

part 'chat_message_event.dart';
part 'chat_message_state.dart';

class ChatMessageBloc extends Bloc<ChatMessageEvent, ChatMessageState> {
  ChatMessageBloc() : super(ChatMessageInitial()) {
    on<SendMessageEvent>(_sendMessage);
    on<SendImageEvent>(_sendImage);
    on<ReadMessageEvent>(_readMessage);
    on<DeleteMessageEvent>(_deleteMessage);
  }
  Future<void> _sendMessage(
      SendMessageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatMessageLoadding());
    try {
      final usecase = SendMessageUseCase(
        repository: ChatRepositoryImp(
          remoteDataSource: ChatRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        message: event.message,
        roomId: event.roomId,
        uid: event.uid,
        type: event.type,
      );
      emit(ChatMessageSuccess(message: 'Send Message Succsfully'));
    } catch (e) {
      emit(ChatMessageError(message: e.toString()));
    }
  }

  Future<void> _sendImage(
      SendImageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatMessageLoadding());
    try {
      final usecase = SendImageUseCase(
        repository: ChatRepositoryImp(
          remoteDataSource: ChatRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        roomId: event.roomId,
        uid: event.uid,
        fileImage: event.fileImage,
      );
      emit(ChatMessageSuccess(message: 'Send Image Succsfully'));
    } catch (e) {
      emit(ChatMessageError(message: e.toString()));
    }
  }

  Future<void> _readMessage(
      ReadMessageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatMessageLoadding());
    try {
      final usecase = ReadMessageUseCase(
        repository: ChatRepositoryImp(
          remoteDataSource: ChatRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        roomId: event.roomId,
        messageId: event.messageId,
      );
      emit(ChatMessageSuccess(message: 'Read Image Succsfully'));
    } catch (e) {
      emit(ChatMessageError(message: e.toString()));
    }
  }

  Future<void> _deleteMessage(
      DeleteMessageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatMessageLoadding());
    try {
      final usecase = DeleteMessageUseCase(
        repository: ChatRepositoryImp(
          remoteDataSource: ChatRemoteDataSourceImp(),
        ),
      );
      await usecase.call(
        roomId: event.roomId,
        messageIds: event.messageIds,
      );
      emit(ChatMessageSuccess(message: 'Read Image Succsfully'));
    } catch (e) {
      emit(ChatMessageError(message: e.toString()));
    }
  }
}
