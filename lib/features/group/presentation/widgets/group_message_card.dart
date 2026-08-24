import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../core/utils/photo_view.dart';
import '../../domain/entities/group_message_entity.dart';

class GroupMessageCard extends StatelessWidget {
  const GroupMessageCard({
    super.key,
    required this.messageInfo,
    required this.senderName,
    required this.isSelected,
  });
  final GroupMessageEntity messageInfo;
  final String senderName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final myId = getIt<SessionCubit>().state.user?.id ?? '';
    bool isMe = messageInfo.fromId == myId;
    return GroupMessageCardBody(
      isMe: isMe,
      messageInfo: messageInfo,
      senderName: senderName,
      isSelected: isSelected,
    );
  }
}

class GroupMessageCardBody extends StatelessWidget {
  const GroupMessageCardBody({
    super.key,
    required this.isMe,
    required this.messageInfo,
    required this.senderName,
    required this.isSelected,
  });

  final bool isMe;
  final GroupMessageEntity messageInfo;
  final String senderName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMe ? 12 : 0),
          bottomRight: Radius.circular(isMe ? 0 : 12),
        ),
        color: isSelected ? Colors.grey : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            color: isMe
                ? Theme.of(context).colorScheme.inversePrimary
                : Theme.of(context).colorScheme.inverseSurface,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    senderName,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isMe
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.surface,
                        ),
                  ),
                  messageInfo.type == 'image'
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoViewScreen(
                                    imageProvider:
                                        NetworkImage(messageInfo.message),
                                  ),
                                ),
                              ),
                              child: CachedNetworkImage(
                                height: 260,
                                width: MediaQuery.of(context).size.width * 0.6,
                                fit: BoxFit.cover,
                                imageUrl: messageInfo.message,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          messageInfo.message,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: isMe
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.surface,
                              ),
                        ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        HelperFunctions.localDateTime(messageInfo.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isMe
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.surface,
                            ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      isMe
                          ? Icon(
                              Iconsax.tick_circle,
                              color: messageInfo.read == ''
                                  ? Colors.grey
                                  : Colors.blueAccent,
                              size: 18,
                            )
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
