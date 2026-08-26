import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../core/utils/widgets/chat_composer.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/presentation/widgets/fallback_avatar.dart';
import '../../domain/entities/message_entity.dart';
import '../manager/chat_message/chat_message_bloc.dart';
import '../manager/messages/messages_cubit.dart';
import '../manager/users/users_cubit.dart';
import '../widgets/chat_message_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.userInfo, required this.roomId});

  final UserEntity userInfo;
  final String roomId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController messageController;
  @override
  void initState() {
    super.initState();

    messageController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ChatMessageBloc>()),
        BlocProvider(
          create: (context) =>
              getIt<MessagesCubit>(param1: widget.roomId),
        ),
        BlocProvider(
          create: (context) =>
              getIt<UsersCubit>(param1: [widget.userInfo.id]),
        ),
      ],
      child: ChatScreenBody(
        widget: widget,
        messageController: messageController,
        roomId: widget.roomId,
      ),
    );
  }
}

class ChatScreenBody extends StatefulWidget {
  const ChatScreenBody({
    super.key,
    required this.widget,
    required this.messageController,
    required this.roomId,
  });

  final ChatScreen widget;
  final TextEditingController messageController;
  final String roomId;

  @override
  State<ChatScreenBody> createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<ChatScreenBody> {
  List<String> selectedMessages = [];
  List<String> copyMessages = [];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(
          children: [
            FallbackAvatar(
              name: widget.widget.userInfo.name,
              imageUrl: widget.widget.userInfo.imageUrl,
              radius: 19,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.widget.userInfo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  BlocBuilder<UsersCubit, UsersState>(
                    builder: (context, state) {
                      if (state is! UsersLoaded || state.users.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final peer = state.users.first;
                      final online = peer.online;
                      final lastActivated = peer.lastActivated ?? '';
                      final lastSeen = lastActivated.isEmpty
                          ? ''
                          : 'Last seen ${AppDateTimeFormatter.dateAndTime(lastActivated)} at ${AppDateTimeFormatter.timeDate(lastActivated)}';
                      return Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  online ? Colors.greenAccent.shade400 : null,
                            ),
                          ),
                          if (online) const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              online ? 'Online' : lastSeen,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: online
                                    ? Colors.greenAccent.shade400
                                    : scheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (selectedMessages.isNotEmpty) ...[
            IconButton(
              onPressed: () {
                context.read<ChatMessageBloc>().add(
                      DeleteMessageEvent(
                        roomId: widget.roomId,
                        messageIds: List.from(selectedMessages),
                      ),
                    );
                setState(() => selectedMessages.clear());
                setState(() => copyMessages.clear());
              },
              icon: const Icon(Iconsax.trash),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text: copyMessages.join('\n'),
                  ),
                );
                setState(() => selectedMessages.clear());
                setState(() => copyMessages.clear());
              },
              icon: const Icon(Iconsax.copy),
            ),
          ]
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessagesCubit, MessagesState>(
                builder: (context, state) {
              if (state is MessagesLoaded) {
                final List<MessageEntity> messages = state.messages;
                return messages.isNotEmpty
                    ? ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (selectedMessages.isNotEmpty) {
                                setState(() {
                                  selectedMessages
                                          .contains(messages[index].id)
                                      ? selectedMessages
                                          .remove(messages[index].id)
                                      : selectedMessages
                                          .add(messages[index].id);
                                });
                              }
                              if (copyMessages.isNotEmpty) {
                                setState(() {
                                  messages[index].type == 'text'
                                      ? copyMessages.contains(
                                              messages[index].message)
                                          ? copyMessages.remove(
                                              messages[index].message)
                                          : copyMessages.add(
                                              messages[index].message)
                                      : null;
                                });
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                selectedMessages
                                        .contains(messages[index].id)
                                    ? selectedMessages
                                        .remove(messages[index].id)
                                    : selectedMessages
                                        .add(messages[index].id);

                                messages[index].type == 'text'
                                    ? copyMessages
                                            .contains(messages[index].message)
                                        ? copyMessages.remove(
                                            messages[index].message)
                                        : copyMessages
                                            .add(messages[index].message)
                                    : null;
                              });
                            },
                            child: ChatMessageCard(
                              messageInfo: messages[index],
                              roomId: widget.roomId,
                              isSelected:
                                  selectedMessages.contains(messages[index].id),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: GestureDetector(
                          onTap: () {
                            context.read<ChatMessageBloc>().add(
                                  SendMessageEvent(
                                    roomId: widget.roomId,
                                    message: 'Assalamu Alaikum 👋',
                                    userInfo: widget.widget.userInfo,
                                  ),
                                );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 26),
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: scheme.primary.withOpacity(0.18),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "👋",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  "Say Assalamu Alaikum",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
              }
              return const SizedBox.shrink();
            }),
          ),
          ChatComposer(
            controller: widget.messageController,
            onSend: () {
              if (widget.messageController.text != '') {
                context.read<ChatMessageBloc>().add(
                      SendMessageEvent(
                        userInfo: widget.widget.userInfo,
                        roomId: widget.roomId,
                        message: widget.messageController.text,
                      ),
                    );
                widget.messageController.text = '';
              }
            },
            onPickImage: () async {
              File? image = await HelperFunctions.pickImage();
              if (image == null) return;
              final bytes = await image.readAsBytes();
              if (!context.mounted) return;
              context.read<ChatMessageBloc>().add(
                    SendImageEvent(
                      userInfo: widget.widget.userInfo,
                      roomId: widget.roomId,
                      fileImage: bytes,
                      fileExtension: image.path.split('.').last,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}
