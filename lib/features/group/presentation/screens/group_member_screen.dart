import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../domain/entities/chat_group_entity.dart';
import '../manager/group/group_bloc.dart';
import '../manager/members/group_members_cubit.dart';

class GroupMemberScreen extends StatefulWidget {
  const GroupMemberScreen({super.key, required this.groupInfo});

  final ChatGroupEntity groupInfo;

  @override
  State<GroupMemberScreen> createState() => _GroupMemberScreenState();
}

class _GroupMemberScreenState extends State<GroupMemberScreen> {
  @override
  Widget build(BuildContext context) {
    final myId = getIt<SessionCubit>().state.user?.id ?? '';
    bool isAdmin = widget.groupInfo.admins.contains(myId);
    bool isSuperAdmin = widget.groupInfo.admins.first == myId;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<GroupBloc>()),
        BlocProvider(
          create: (context) =>
              getIt<GroupMembersCubit>(param1: widget.groupInfo.members),
        ),
      ],
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Group Member'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<GroupMembersCubit, GroupMembersState>(
                  builder: (context, membersState) {
                if (membersState is! GroupMembersLoaded) {
                  return Container();
                }
                final members = List.from(membersState.members)..sort((a, b) {
                  bool aIsAdmin = widget.groupInfo.admins.contains(a.id);
                  bool bIsAdmin = widget.groupInfo.admins.contains(b.id);
                  if (aIsAdmin && !bIsAdmin) return -1;
                  if (!aIsAdmin && bIsAdmin) return 1;
                  return 0;
                });
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    bool admin =
                        widget.groupInfo.admins.contains(members[index].id);
                    bool memberIsSuperAdmin =
                        widget.groupInfo.admins.first == members[index].id;

                    bool isCurrentUser = members[index].id == myId;
                    return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(members[index].name),
                        subtitle: Text(admin ? "Admin" : "Member"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isCurrentUser &&
                                (isSuperAdmin ||
                                    (isAdmin && !memberIsSuperAdmin))) ...[
                              IconButton(
                                onPressed: () {
                                  admin
                                      ? context.read<GroupBloc>().add(
                                            RemovePromoteEvent(
                                              memberId: members[index].id,
                                              groupId: widget.groupInfo.id,
                                            ),
                                          )
                                      : context.read<GroupBloc>().add(
                                            PromoteMemberEvent(
                                              memberId: members[index].id,
                                              groupId: widget.groupInfo.id,
                                            ),
                                          );
                                  setState(() {
                                    admin
                                        ? widget.groupInfo.admins
                                            .remove(members[index].id)
                                        : widget.groupInfo.admins
                                            .add(members[index].id);
                                  });
                                },
                                icon: Icon(
                                  admin
                                      ? Iconsax.user_remove
                                      : Iconsax.user_tick,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.read<GroupBloc>().add(
                                        RemoveMemberEvent(
                                          memberId: members[index].id,
                                          groupId: widget.groupInfo.id,
                                        ),
                                      );
                                  setState(() {
                                    widget.groupInfo.members
                                        .remove(members[index].id);
                                  });
                                },
                                icon: const Icon(Iconsax.trash),
                              ),
                            ],
                          ],
                        ));
                  },
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
