import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../auth/domain/entities/user_entity.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.widget.userInfo.name,
              style: Theme.of(context).textTheme.labelLarge,
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
                return Text(
                  online ? 'Online' : lastSeen,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: online ? Colors.green : Colors.grey,
                      ),
                );
              },
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<MessagesCubit, MessagesState>(
                  builder: (context, state) {
                if (state is MessagesLoaded) {
                  final List<MessageEntity> messages = state.messages;
                  return messages.isNotEmpty
                      ? ListView.builder(
                          reverse: true,
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
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
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
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      "Say Assalamu Alaikum",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                }
                return Container();
              }),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: TextField(
                      controller: widget.messageController,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        suffixIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Iconsax.emoji_happy),
                            ),
                            IconButton(
                              onPressed: () async {
                                File? image = await HelperFunctions.pickImage();
                                if (image != null) {
                                  final bytes = await image.readAsBytes();

                                  context.read<ChatMessageBloc>().add(
                                        SendImageEvent(
                                          userInfo: widget.widget.userInfo,
                                          roomId: widget.roomId,
                                          fileImage: bytes,
                                          fileExtension:
                                              image.path.split('.').last,
                                        ),
                                      );
                                }
                              },
                              icon: const Icon(Iconsax.camera),
                            ),
                          ],
                        ),
                        border: InputBorder.none,
                        hintText: "Message",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
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
                  icon: const Icon(Iconsax.send_1),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
