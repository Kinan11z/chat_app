import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/widgets/message_bubble.dart';
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
    return MessageBubble(
      message: messageInfo.message,
      type: messageInfo.type,
      createdAt: messageInfo.createdAt,
      isMe: isMe,
      hasRead: messageInfo.read.isNotEmpty,
      senderName: senderName,
      isSelected: isSelected,
    );
  }
}
