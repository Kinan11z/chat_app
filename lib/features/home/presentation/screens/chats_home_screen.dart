import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../chat/presentation/manager/chats/chats_cubit.dart';
import '../widgets/chat_card.dart';
import '../widgets/create_chat_bottom_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_action_button.dart';
import '../widgets/home_header.dart';
import '../widgets/list_skeleton.dart';

class ChatsHomeScreen extends StatefulWidget {
  const ChatsHomeScreen({super.key});

  @override
  State<ChatsHomeScreen> createState() => _ChatsHomeScreenState();
}

class _ChatsHomeScreenState extends State<ChatsHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatsCubit>(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                title: 'Chats',
                actions: [
                  HomeActionButton(
                    icon: Iconsax.add,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const CreateChatBottomSheet(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: BlocBuilder<ChatsCubit, ChatsState>(
                  builder: (context, state) {
                    if (state is ChatsLoading) {
                      return const ListSkeleton();
                    }
                    if (state is ChatsError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ChatsLoaded) {
                      if (state.rooms.isEmpty) {
                        return const EmptyState(
                          icon: Iconsax.messages_2,
                          title: 'No chats yet',
                          subtitle:
                              'Start a conversation by tapping the button below',
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 110),
                        itemCount: state.rooms.length,
                        itemBuilder: (context, index) {
                          final room = state.rooms[index];
                          return ChatCard(item: room);
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
