import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../core/constants/strings.dart';
import '../../../domain/entities/chat_group_entity.dart';
import '../../../domain/usecases/send_group_image_use_case.dart';
import '../../../domain/usecases/send_group_message_use_case.dart';

part 'chat_group_message_event.dart';
part 'chat_group_message_state.dart';

class ChatGroupMessageBloc
    extends Bloc<ChatGroupMessageEvent, ChatGroupMessageState> {
  final SendGroupMessageUseCase sendGroupMessageUseCase;
  final SendGroupImageUseCase sendGroupImageUseCase;

  ChatGroupMessageBloc({
    required this.sendGroupMessageUseCase,
    required this.sendGroupImageUseCase,
  }) : super(ChatGroupMessageInitial()) {
    on<SendMessageGroupEvent>(_sendGroupMessage);
    on<SendImageGroupEvent>(_sendGroupImage);
  }

  Future<void> _sendGroupMessage(
    SendMessageGroupEvent event,
    Emitter<ChatGroupMessageState> emit,
  ) async {
    emit(ChatGroupMessageLoadding());
    final result = await sendGroupMessageUseCase(
      SendGroupMessageParams(
        message: event.message,
        groupInfo: event.groupInfo,
        type: event.type,
      ),
    );
    result.fold(
      (failure) => emit(ChatGroupMessageError(message: failure.message)),
      (_) => emit(
          ChatGroupMessageSuccess(message: AppStrings.sendGroupMessageSuccess)),
    );
  }

  Future<void> _sendGroupImage(
    SendImageGroupEvent event,
    Emitter<ChatGroupMessageState> emit,
  ) async {
    emit(ChatGroupMessageLoadding());
    final result = await sendGroupImageUseCase(
      SendGroupImageParams(
        imageFile: event.imageFile,
        groupInfo: event.groupInfo,
        fileExtension: event.fileExtension,
      ),
    );
    result.fold(
      (failure) => emit(ChatGroupMessageError(message: failure.message)),
      (_) => emit(
          ChatGroupMessageSuccess(message: AppStrings.sendGroupImageSuccess)),
    );
  }
}
