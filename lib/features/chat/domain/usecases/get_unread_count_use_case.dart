import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/usecases/usecase.dart';

class GetUnreadCountParams {
  final String roomId;

  GetUnreadCountParams({required this.roomId});
}

class GetUnreadCountStream extends StreamUseCase<int, GetUnreadCountParams> {
  final ChatRepository repository;

  GetUnreadCountStream({required this.repository});

  @override
  Stream<int> call(GetUnreadCountParams params) {
    return repository.getUnreadCount(roomId: params.roomId);
  }
}
