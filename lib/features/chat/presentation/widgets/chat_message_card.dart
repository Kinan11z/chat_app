import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/widgets/message_bubble.dart';
import '../../domain/entities/message_entity.dart';
import '../manager/chat_message/chat_message_bloc.dart';

class ChatMessageCard extends StatelessWidget {
  const ChatMessageCard(
      {super.key,
      required this.messageInfo,
      required this.roomId,
      required this.isSelected});
  final MessageEntity messageInfo;
  final String roomId;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final myId = getIt<SessionCubit>().state.user?.id ?? '';
    bool isMe = messageInfo.fromId == myId;
    return ChatMessageCardBody(
      isMe: isMe,
      messageInfo: messageInfo,
      roomId: roomId,
      isSelected: isSelected,
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
  final MessageEntity messageInfo;
  final String roomId;
  final bool isSelected;

  @override
  State<ChatMessageCardBody> createState() => _ChatMessageCardBodyState();
}

class _ChatMessageCardBodyState extends State<ChatMessageCardBody> {
  @override
  void initState() {
    super.initState();

    if (!widget.isMe &&
        widget.messageInfo.id.isNotEmpty &&
        widget.messageInfo.read.isEmpty) {
      context.read<ChatMessageBloc>().add(
            ReadMessageEvent(
              roomId: widget.roomId,
              messageId: widget.messageInfo.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      message: widget.messageInfo.message,
      type: widget.messageInfo.type,
      createdAt: widget.messageInfo.createdAt,
      isMe: widget.isMe,
      hasRead: widget.messageInfo.read.isNotEmpty,
      isSelected: widget.isSelected,
    );
  }
}
