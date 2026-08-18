import 'dart:io';

import 'package:chat_app/core/utils/helper_functions.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/date_format.dart';
import '../manager/chat_message/chat_message_bloc.dart';
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
    return BlocProvider(
      create: (context) => getIt<ChatMessageBloc>(),
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
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.widget.userInfo.id)
                  .snapshots(),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data?.data()?['online'] == true
                      ? 'Online'
                      : 'Last seen ${AppDateTimeFormatter.dateAndTime(widget.widget.userInfo.lastActivated!)} at ${AppDateTimeFormatter.timeDate(widget.widget.userInfo.lastActivated!)}',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: snapshot.data?.data()?['online'] == true
                            ? Colors.green
                            : Colors.grey,
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
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(widget.widget.roomId)
                      .collection('messages')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<MessageModel> messages = snapshot.data!.docs
                          .map(
                            (e) => MessageModel.fromJson(e.data()),
                          )
                          .toList()
                        ..sort(
                          (a, b) => b.createdAt!.compareTo(a.createdAt!),
                        );
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
                                                .add(messages[index].id!);
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
                                                    messages[index].message!)
                                            : null;
                                        print(copyMessages);
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
                                              .add(messages[index].id!);

                                      messages[index].type == 'text'
                                          ? copyMessages.contains(
                                                  messages[index].message)
                                              ? copyMessages.remove(
                                                  messages[index].message)
                                              : copyMessages
                                                  .add(messages[index].message!)
                                          : null;
                                    });
                                  },
                                  child: ChatMessageCard(
                                    messageInfo: messages[index],
                                    roomId: widget.widget.roomId,
                                    isSelected: selectedMessages
                                        .contains(messages[index].id),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: () {
                                  context.read<ChatMessageBloc>().add(
                                        SendMessageEvent(
                                          roomId: widget.widget.roomId,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "👋",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium,
                                        ),
                                        SizedBox(
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
                                          roomId: widget.widget.roomId,
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
                              roomId: widget.widget.roomId,
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
