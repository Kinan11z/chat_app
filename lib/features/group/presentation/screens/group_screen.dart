import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../domain/entities/chat_group_entity.dart';
import '../manager/chat_group_message/chat_group_message_bloc.dart';
import '../manager/members/group_members_cubit.dart';
import '../manager/messages/group_messages_cubit.dart';
import '../widgets/group_message_card.dart';
import 'edit_group_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.groupInfo});

  final ChatGroupEntity groupInfo;
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ChatGroupMessageBloc>()),
        BlocProvider(
          create: (context) =>
              getIt<GroupMessagesCubit>(param1: widget.groupInfo.id),
        ),
        BlocProvider(
          create: (context) =>
              getIt<GroupMembersCubit>(param1: widget.groupInfo.members),
        ),
      ],
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
                      widget.groupInfo.name,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    BlocBuilder<GroupMembersCubit, GroupMembersState>(
                      builder: (context, membersState) {
                        if (membersState is! GroupMembersLoaded) {
                          return Container();
                        }
                        final myId =
                            context.read<SessionCubit>().state.user?.id ?? '';
                        final memberNames = membersState.members
                            .where((member) => member.id != myId)
                            .map((member) => member.name)
                            .toList();
                        return Text(
                          memberNames.join(', '),
                          style: Theme.of(context).textTheme.labelSmall,
                        );
                      },
                    ),
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
                    child:
                        BlocBuilder<GroupMembersCubit, GroupMembersState>(
                      builder: (context, membersState) {
                        final senderNames =
                            membersState is GroupMembersLoaded
                                ? {
                                    for (final member
                                        in membersState.members)
                                      member.id: member.name,
                                  }
                                : const <String, String>{};
                        return BlocBuilder<GroupMessagesCubit,
                            GroupMessagesState>(
                          builder: (context, messagesState) {
                            if (messagesState is GroupMessagesLoaded) {
                              return ListView.builder(
                                reverse: true,
                                itemCount: messagesState.messages.length,
                                itemBuilder: (context, index) {
                                  final message =
                                      messagesState.messages[index];
                                  return GroupMessageCard(
                                    messageInfo: message,
                                    senderName:
                                        senderNames[message.fromId] ?? '',
                                    isSelected: false,
                                  );
                                },
                              );
                            }
                            return Container();
                          },
                        );
                      },
                    ),
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
                                        final bytes = await image.readAsBytes();
                                        context
                                            .read<ChatGroupMessageBloc>()
                                            .add(
                                              SendImageGroupEvent(
                                                imageFile: bytes,
                                                groupInfo: widget.groupInfo,
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
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {
                          if (messageController.text != '') {
                            BlocProvider.of<ChatGroupMessageBloc>(context).add(
                              SendMessageGroupEvent(
                                message: messageController.text,
                                groupInfo: widget.groupInfo,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Iconsax.send_1),
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
