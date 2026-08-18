import 'package:chat_app/core/di/injection.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/entities/chat_group_entity.dart';
import '../manager/group/group_bloc.dart';

class GroupMemberScreen extends StatefulWidget {
  const GroupMemberScreen({super.key, required this.groupInfo});

  final ChatGroupEntity groupInfo;

  @override
  State<GroupMemberScreen> createState() => _GroupMemberScreenState();
}

class _GroupMemberScreenState extends State<GroupMemberScreen> {
  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.groupInfo.admins!
        .contains(FirebaseAuth.instance.currentUser!.uid);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    bool isSuperAdmin = widget.groupInfo.admins!.first == currentUserId;

    List<UserModel> members = [];
    return BlocProvider(
      create: (context) => getIt<GroupBloc>(),
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
              title: Text('Group Member'),
            ),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('id', whereIn: widget.groupInfo.members)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      members = snapshot.data!.docs
                          .map((e) => UserModel.fromJson(e.data()))
                          .toList()
                        ..sort((a, b) {
                          bool aIsAdmin =
                              widget.groupInfo.admins!.contains(a.id);
                          bool bIsAdmin =
                              widget.groupInfo.admins!.contains(b.id);
                          if (aIsAdmin && !bIsAdmin) return -1;
                          if (!aIsAdmin && bIsAdmin) return 1;
                          return 0;
                        });
                      return ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          bool admin = widget.groupInfo.admins!
                              .contains(members[index].id);
                          bool memberIsSuperAdmin =
                              widget.groupInfo.admins!.first ==
                                  members[index].id;

                          bool isCurrentUser =
                              members[index].id == currentUserId;
                          return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(members[index].name.toString()),
                              subtitle: Text(admin ? "Admin" : "Member"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isCurrentUser &&
                                      (isSuperAdmin ||
                                          (isAdmin &&
                                              !memberIsSuperAdmin))) ...[
                                    IconButton(
                                      onPressed: () {
                                        admin
                                            ? context.read<GroupBloc>().add(
                                                  RemovePromoteEvent(
                                                    memberId:
                                                        members[index].id!,
                                                    groupId:
                                                        widget.groupInfo.id!,
                                                  ),
                                                )
                                            : context.read<GroupBloc>().add(
                                                  PromoteMemberEvent(
                                                    memberId:
                                                        members[index].id!,
                                                    groupId:
                                                        widget.groupInfo.id!,
                                                  ),
                                                );
                                        setState(() {
                                          admin
                                              ? widget.groupInfo.admins!
                                                  .remove(members[index].id!)
                                              : widget.groupInfo.admins!
                                                  .add(members[index].id!);
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
                                                memberId: members[index].id!,
                                                groupId: widget.groupInfo.id!,
                                              ),
                                            );
                                        setState(() {
                                          widget.groupInfo.members!
                                              .remove(members[index].id!);
                                        });
                                      },
                                      icon: const Icon(Iconsax.trash),
                                    ),
                                  ],
                                ],
                              ));
                        },
                      );
                    } else
                      return Container();
                  }),
            ),
          );
        },
      ),
    );
  }
}
