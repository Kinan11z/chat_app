import 'package:cached_network_image/cached_network_image.dart';
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

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.item,
  });
  final ChatRoomEntity item;
  @override
  Widget build(BuildContext context) {
    final myId = getIt<SessionCubit>().state.user?.id ?? '';
    final List<String> members =
        item.members.where((element) => element != myId).toList();
    String userId = members.isEmpty ? myId : members.first;
    return BlocProvider(
      create: (context) => getIt<UsersCubit>(param1: [userId]),
      child: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) {
          if (state is! UsersLoaded || state.users.isEmpty) {
            return Container();
          }
          final UserEntity userInfo = state.users.first;

          return BlocProvider(
            create: (context) => getIt<UnreadCountCubit>(param1: item.id),
            child: BlocBuilder<UnreadCountCubit, UnreadCountState>(
              builder: (context, unreadState) {
                final unreadCount =
                    unreadState is UnreadCountLoaded ? unreadState.count : 0;
                return Card(
                  child: ListTile(
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
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          (userInfo.imageUrl?.isNotEmpty ?? false)
                              ? CachedNetworkImageProvider(userInfo.imageUrl!)
                              : null,
                      child: (userInfo.imageUrl?.isEmpty ?? true)
                          ? Text(userInfo.name.characters.first)
                          : null,
                    ),
                    title: Text(userInfo.name),
                    subtitle: Text(
                      item.lastMessage == ''
                          ? userInfo.about ?? ''
                          : item.lastMessage,
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: unreadCount > 0
                        ? Badge(label: Text(unreadCount.toString()))
                        : Text(
                            item.lastMessageTime.isEmpty
                                ? ''
                                : AppDateTimeFormatter.dateAndTime(
                                    item.lastMessageTime,
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
