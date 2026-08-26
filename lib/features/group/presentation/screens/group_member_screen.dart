import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../home/presentation/widgets/fallback_avatar.dart';
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
    final scheme = Theme.of(context).colorScheme;
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
              title: const Text('Group Members'),
            ),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: BlocBuilder<GroupMembersCubit, GroupMembersState>(
                  builder: (context, membersState) {
                if (membersState is! GroupMembersLoaded) {
                  return const SizedBox.shrink();
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          FallbackAvatar(
                            name: members[index].name,
                            imageUrl: members[index].imageUrl,
                            radius: 21,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        members[index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (isCurrentUser) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '(You)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: scheme.onSurface
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                _RoleChip(
                                  label: memberIsSuperAdmin
                                      ? 'Owner'
                                      : admin
                                          ? 'Admin'
                                          : 'Member',
                                  highlighted: admin,
                                ),
                              ],
                            ),
                          ),
                          if (!isCurrentUser &&
                              (isSuperAdmin ||
                                  (isAdmin && !memberIsSuperAdmin))) ...[
                            _MemberActionButton(
                              icon: admin
                                  ? Iconsax.user_remove
                                  : Iconsax.user_tick,
                              color: Colors.orange,
                              onTap: () {
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
                            ),
                            const SizedBox(width: 8),
                            _MemberActionButton(
                              icon: Iconsax.trash,
                              color: scheme.error,
                              onTap: () {
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
                            ),
                          ],
                        ],
                      ),
                    );
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

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, this.highlighted = false});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? Colors.orange : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: highlighted ? Colors.orange.shade700 : Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _MemberActionButton extends StatelessWidget {
  const _MemberActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }
}
