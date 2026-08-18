import 'dart:typed_data';

import 'package:chat_app/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_group_entity.dart';
import '../repositories/group_repository.dart';

class SendGroupImageParams {
  final Uint8List imageFile;
  final ChatGroupEntity groupInfo;
  final String fileExtension;

  SendGroupImageParams({
    required this.imageFile,
    required this.groupInfo,
    required this.fileExtension,
  });
}

class SendGroupImageUseCase extends UseCase<void, SendGroupImageParams> {
  final GroupRepository repository;

  SendGroupImageUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SendGroupImageParams params) async {
    return await repository.sendImage(
      imageFile: params.imageFile,
      groupInfo: params.groupInfo,
      fileExtension: params.fileExtension,
    );
  }
}
