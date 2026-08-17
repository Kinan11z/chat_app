import 'dart:io';

import 'package:chat_app/features/group/data/models/chat_group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/utils/helper_functions.dart';
import '../../data/models/group_message_model.dart';
import '../manager/chat_group_message/chat_group_message_bloc.dart';
import '../widgets/group_message_card.dart';
import 'edit_group_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.groupInfo});

  final ChatGroupModel groupInfo;
  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
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
      create: (context) => ChatGroupMessageBloc(),
      child: BlocConsumer<ChatGroupMessageBloc, ChatGroupMessageState>(
        listener: (context, state) {
          if (state is ChatGroupMessageSuccess) {
            messageController.clear();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditGroupScreen(
                        groupInfo: widget.groupInfo,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupInfo.name.toString(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('id', whereIn: widget.groupInfo.members)
                            .snapshots(),
                        builder: (context, snapshot) {
                          List<String> memberNames = [];
                          for (var element in snapshot.data?.docs ?? []) {
                            if (element['id'] !=
                                FirebaseAuth.instance.currentUser!.uid) {
                              memberNames.add(element['name']);
                            }
                          }

                          if (snapshot.hasData) {
                            return Text(
                              memberNames.join(', '),
                              style: Theme.of(context).textTheme.labelSmall,
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Iconsax.trash),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Iconsax.copy),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('groups')
                            .doc(widget.groupInfo.id)
                            .collection('messages')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<GroupMessageModel> groupMessages = snapshot
                                .data!.docs
                                .map(
                                  (e) => GroupMessageModel.fromJson(e.data()),
                                )
                                .toList()
                              ..sort(
                                (a, b) => b.createdAt!.compareTo(a.createdAt!),
                              );
                            return ListView.builder(
                              reverse: true,
                              itemCount: groupMessages.length,
                              itemBuilder: (context, index) {
                                return GroupMessageCard(
                                  messageInfo: groupMessages[index],
                                  isSelected: false,
                                );
                              },
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: TextField(
                            controller: messageController,
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
                                      File? image =
                                          await HelperFunctions.pickImage();
                                      if (image != null) {
                                        BlocProvider.of<ChatGroupMessageBloc>(
                                                context)
                                            .add(
                                          SendImageGroupEvent(
                                            imageFile: image,
                                            groupInfo: widget.groupInfo,
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
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {
                          BlocProvider.of<ChatGroupMessageBloc>(context).add(
                            SendMessageGroupEvent(
                              message: messageController.text,
                              groupInfo: widget.groupInfo,
                            ),
                          );
                        },
                        icon: Icon(Iconsax.send_1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
