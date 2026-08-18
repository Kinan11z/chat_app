import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:meta/meta.dart';

import '../../../../../core/constants/strings.dart';

import '../../../domain/usecases/delete_message_use_case.dart';
import '../../../domain/usecases/read_message_use_case.dart';
import '../../../domain/usecases/send_image_use_case.dart';
import '../../../domain/usecases/send_message_use_case.dart';

part 'chat_message_event.dart';
part 'chat_message_state.dart';

class ChatMessageBloc extends Bloc<ChatMessageEvent, ChatMessageState> {
  final SendMessageUseCase sendMessageUseCase;
  final SendImageUseCase sendImageUseCase;
  final ReadMessageUseCase readMessageUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  ChatMessageBloc({
    required this.sendMessageUseCase,
    required this.sendImageUseCase,
    required this.readMessageUseCase,
    required this.deleteMessageUseCase,
  }) : super(ChatMessageInitial()) {
    on<SendMessageEvent>(_sendMessage);
    on<SendImageEvent>(_sendImage);
    on<ReadMessageEvent>(_readMessage);
    on<DeleteMessageEvent>(_deleteMessage);
  }
  Future<void> _sendMessage(
      SendMessageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatMessageLoadding());
    final result = await sendMessageUseCase(SendChatMessageParams(
      message: event.message,
      roomId: event.roomId,
      type: event.type,
      userInfo: event.userInfo,
    ));
    result.fold(
      (failure) => emit(ChatMessageError(message: failure.message)),
      (_) => emit(ChatMessageSuccess(message: AppStrings.sendMessageSuccess)),
    );
  }

  Future<void> _sendImage(
      SendImageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatMessageLoadding());
    final result = await sendImageUseCase(SendChatImageParams(
      roomId: event.roomId,
      fileImage: event.fileImage,
      fileExtension: event.fileExtension,
      userInfo: event.userInfo,
    ));
    result.fold(
      (failure) => emit(ChatMessageError(message: failure.message)),
      (_) => emit(ChatMessageSuccess(message: AppStrings.sendImageSuccess)),
    );
  }

  Future<void> _readMessage(
      ReadMessageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatMessageLoadding());
    final result = await readMessageUseCase(ReadChatMessageParams(
      roomId: event.roomId,
      messageId: event.messageId,
    ));
    result.fold(
      (failure) => emit(ChatMessageError(message: failure.message)),
      (_) => emit(ChatMessageSuccess(message: AppStrings.readMessageSuccess)),
    );
  }

  Future<void> _deleteMessage(
      DeleteMessageEvent event, Emitter<ChatMessageState> emit) async {
    emit(ChatMessageLoadding());
    final result = await deleteMessageUseCase(DeleteChatMessageParams(
      roomId: event.roomId,
      messageIds: event.messageIds,
    ));
    result.fold(
      (failure) => emit(ChatMessageError(message: failure.message)),
      (_) => emit(ChatMessageSuccess(message: AppStrings.deleteMessageSuccess)),
    );
  }
}
