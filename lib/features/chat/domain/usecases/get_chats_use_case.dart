import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/chat_room_entity.dart';

class GetChatsStream extends StreamUseCase<List<ChatRoomEntity>, NoParams> {
  final ChatRepository repository;

  GetChatsStream({required this.repository});

  @override
  Stream<List<ChatRoomEntity>> call(NoParams params) {
    return repository.getChats();
  }
}
