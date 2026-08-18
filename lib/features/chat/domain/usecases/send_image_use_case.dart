import 'dart:typed_data';

import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';

class SendChatImageParams {
  final String roomId;
  final Uint8List fileImage;
  final String fileExtension;
  final UserEntity userInfo;

  const SendChatImageParams({
    required this.roomId,
    required this.fileImage,
    required this.fileExtension,
    required this.userInfo,
  });
}

class SendImageUseCase extends UseCase<void, SendChatImageParams> {
  final ChatRepository repository;

  SendImageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendChatImageParams params) async {
    return await repository.sendImage(
      roomId: params.roomId,
      imageFile: params.fileImage,
      fileExtension: params.fileExtension,
      userInfo: params.userInfo,
    );
  }
}
