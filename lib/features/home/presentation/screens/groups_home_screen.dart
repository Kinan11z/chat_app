import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../group/presentation/manager/groups/groups_cubit.dart';
import '../../../group/presentation/screens/create_group_screen.dart';
import '../widgets/empty_state.dart';
import '../widgets/group_card.dart';
import '../widgets/home_action_button.dart';
import '../widgets/home_header.dart';
import '../widgets/list_skeleton.dart';

class GroupsHomeScreen extends StatelessWidget {
  const GroupsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GroupsCubit>(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                title: 'Groups',
                actions: [
                  HomeActionButton(
                    icon: Iconsax.add,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateGroupScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: BlocBuilder<GroupsCubit, GroupsState>(
                  builder: (context, state) {
                    if (state is GroupsLoading) {
                      return const ListSkeleton();
                    }
                    if (state is GroupsError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is GroupsLoaded) {
                      if (state.groups.isEmpty) {
                        return const EmptyState(
                          icon: Iconsax.people,
                          title: 'No groups yet',
                          subtitle:
                              'Tap the button below to create your first group',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 110),
                        itemCount: state.groups.length,
                        itemBuilder: (context, index) {
                          final group = state.groups[index];
                          return GroupCard(groupInfo: group);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
