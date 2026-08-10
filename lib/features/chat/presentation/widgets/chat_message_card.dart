import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/utils/helper_functions.dart';
import '../../data/models/message_model.dart';
import '../manager/chat_message/chat_message_bloc.dart';

class ChatMessageCard extends StatelessWidget {
  const ChatMessageCard(
      {super.key,
      required this.messageInfo,
      required this.roomId,
      required this.isSelected});
  final MessageModel messageInfo;
  final String roomId;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    bool isMe = messageInfo.fromId == FirebaseAuth.instance.currentUser?.uid;
    return BlocProvider(
      create: (context) => ChatMessageBloc(),
      child: ChatMessageCardBody(
        isMe: isMe,
        messageInfo: messageInfo,
        roomId: roomId,
        isSelected: isSelected,
      ),
    );
  }
}

class ChatMessageCardBody extends StatefulWidget {
  const ChatMessageCardBody({
    super.key,
    required this.isMe,
    required this.messageInfo,
    required this.roomId,
    required this.isSelected,
  });

  final bool isMe;
  final MessageModel messageInfo;
  final String roomId;
  final bool isSelected;

  @override
  State<ChatMessageCardBody> createState() => _ChatMessageCardBodyState();
}

class _ChatMessageCardBodyState extends State<ChatMessageCardBody> {
  @override
  void initState() {
    super.initState();

    if (widget.messageInfo.toId == FirebaseAuth.instance.currentUser!.uid) {
      context.read<ChatMessageBloc>().add(
            ReadMessageEvent(
              roomId: widget.roomId,
              messageId: widget.messageInfo.id!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(widget.isMe ? 12 : 0),
          bottomRight: Radius.circular(widget.isMe ? 0 : 12),
        ),
        color: widget.isSelected ? Colors.grey : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(widget.isMe ? 16 : 0),
                bottomRight: Radius.circular(widget.isMe ? 0 : 16),
              ),
            ),
            color: widget.isMe
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
                  widget.messageInfo.type == 'image'
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.messageInfo.message ?? '',
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          widget.messageInfo.message ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: widget.isMe
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.surface,
                              ),
                        ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        HelperFunctions.localDateTime(
                            widget.messageInfo.createdAt ?? ''),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: widget.isMe
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.surface,
                            ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      widget.isMe
                          ? Icon(
                              Iconsax.tick_circle,
                              color: widget.messageInfo.read == ''
                                  ? Colors.grey
                                  : Colors.blueAccent,
                              size: 18,
                            )
                          : SizedBox(),
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
