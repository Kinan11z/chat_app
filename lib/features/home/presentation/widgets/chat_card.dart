import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/date_format.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../chat/domain/entities/chat_room_entity.dart';
import '../../../chat/presentation/manager/unread/unread_count_cubit.dart';
import '../../../chat/presentation/manager/users/users_cubit.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import 'fallback_avatar.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.item,
  });
  final ChatRoomEntity item;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.55);
    final myId = getIt<SessionCubit>().state.user?.id ?? '';
    final List<String> members =
        item.members.where((element) => element != myId).toList();
    String userId = members.isEmpty ? myId : members.first;
    return BlocProvider(
      create: (context) => getIt<UsersCubit>(param1: [userId]),
      child: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) {
          if (state is! UsersLoaded || state.users.isEmpty) {
            return const SizedBox.shrink();
          }
          final UserEntity userInfo = state.users.first;

          return BlocProvider(
            create: (context) => getIt<UnreadCountCubit>(param1: item.id),
            child: BlocBuilder<UnreadCountCubit, UnreadCountState>(
              builder: (context, unreadState) {
                final unreadCount =
                    unreadState is UnreadCountLoaded ? unreadState.count : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              userInfo: userInfo,
                              roomId: item.id,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        child: Row(
                          children: [
                            FallbackAvatar(
                              name: userInfo.name,
                              imageUrl: userInfo.imageUrl,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userInfo.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.lastMessage == ''
                                        ? userInfo.about ?? ''
                                        : item.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13, color: muted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (item.lastMessageTime.isNotEmpty)
                                  Text(
                                    AppDateTimeFormatter.dateAndTime(
                                      item.lastMessageTime,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: muted,
                                    ),
                                  ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 22,
                                    ),
                                    child: Text(
                                      unreadCount > 99
                                          ? '99+'
                                          : unreadCount.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: scheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
