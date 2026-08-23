import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../group/presentation/manager/groups/groups_cubit.dart';
import '../../../group/presentation/screens/create_group_screen.dart';
import '../widgets/group_card.dart';

class GroupsHomeScreen extends StatelessWidget {
  const GroupsHomeScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GroupsCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Groups'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateGroupScreen(),
              ),
            );
          },
          child: const Icon(Iconsax.message_add_1),
        ),
        body: BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, state) {
            if (state is GroupsLoading)
              return const Center(child: CircularProgressIndicator());
            if (state is GroupsError) return Center(child: Text(state.message));
            if (state is GroupsLoaded) {
              if (state.groups.isEmpty)
                return const Center(child: Text('لا توجد مجموعات'));
              return ListView.builder(
                itemCount: state.groups.length,
                itemBuilder: (context, index) {
                  final group = state.groups[index];
                  return GroupCard(groupInfo: group);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
