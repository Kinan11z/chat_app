import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../core/utils/widgets/chat_composer.dart';
import '../../../home/presentation/widgets/fallback_avatar.dart';
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
              toolbarHeight: 72,
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
                child: Row(
                  children: [
                    FallbackAvatar(
                      name: widget.groupInfo.name,
                      imageUrl: widget.groupInfo.image,
                      radius: 19,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.groupInfo.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          BlocBuilder<GroupMembersCubit, GroupMembersState>(
                            builder: (context, membersState) {
                              if (membersState is! GroupMembersLoaded) {
                                return const SizedBox.shrink();
                              }
                              final myId = context
                                      .read<SessionCubit>()
                                      .state
                                      .user
                                      ?.id ??
                                  '';
                              final memberNames = membersState.members
                                  .where((member) => member.id != myId)
                                  .map((member) => member.name)
                                  .toList();
                              return Text(
                                memberNames.join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<GroupMembersCubit, GroupMembersState>(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
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
                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
                ),
                ChatComposer(
                  controller: messageController,
                  onSend: () {
                    if (messageController.text != '') {
                      context.read<ChatGroupMessageBloc>().add(
                            SendMessageGroupEvent(
                              message: messageController.text,
                              groupInfo: widget.groupInfo,
                            ),
                          );
                    }
                  },
                  onPickImage: () async {
                    File? image = await HelperFunctions.pickImage();
                    if (image == null) return;
                    final bytes = await image.readAsBytes();
                    if (!context.mounted) return;
                    context.read<ChatGroupMessageBloc>().add(
                          SendImageGroupEvent(
                            imageFile: bytes,
                            groupInfo: widget.groupInfo,
                            fileExtension: image.path.split('.').last,
                          ),
                        );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
