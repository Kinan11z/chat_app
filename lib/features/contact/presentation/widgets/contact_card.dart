import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../chat/presentation/manager/chat_room/chat_room_bloc.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../home/presentation/widgets/fallback_avatar.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final chatRoomBloc = getIt<ChatRoomBloc>();
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.55);
    final myId = getIt<SessionCubit>().state.user?.id ?? '';
    List<String> roomId = [user.id, myId]
      ..sort(
        (a, b) => a.compareTo(b),
      );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        onTap: () {
          chatRoomBloc.add(CreateChatRoomEvent(email: user.email));
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        leading: FallbackAvatar(
          name: user.name,
          imageUrl: user.imageUrl,
        ),
        title: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Text(
          user.about ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: muted),
        ),
        trailing: BlocConsumer<ChatRoomBloc, ChatRoomState>(
          bloc: chatRoomBloc,
          listener: (context, state) {
            if (state is ChatRoomSuccess) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userInfo: user,
                    roomId: roomId.toString(),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final loading = state is ChatRoomLoadding;
            return Material(
              color: scheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap:
                    loading ? null : () => chatRoomBloc.add(CreateChatRoomEvent(email: user.email)),
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: loading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            strokeCap: StrokeCap.round,
                            color: scheme.primary,
                          ),
                        )
                      : Icon(Iconsax.message, size: 22, color: scheme.primary),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
