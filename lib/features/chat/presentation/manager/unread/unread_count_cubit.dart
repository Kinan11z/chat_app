import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/strings.dart';
import '../../../domain/usecases/get_unread_count_use_case.dart';

part 'unread_count_state.dart';

class UnreadCountCubit extends Cubit<UnreadCountState> {
  final GetUnreadCountStream getUnreadCountStream;
  final String roomId;
  late final StreamSubscription _sub;

  UnreadCountCubit({required this.getUnreadCountStream, required this.roomId})
      : super(UnreadCountInitial()) {
    _sub =
        getUnreadCountStream(GetUnreadCountParams(roomId: roomId)).listen(
      (count) => emit(UnreadCountLoaded(count: count)),
      onError: (_) =>
          emit(UnreadCountError(message: AppStrings.somethingWentWrong)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
