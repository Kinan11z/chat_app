import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../chat/presentation/manager/chats/chats_cubit.dart';
import '../widgets/chat_card.dart';
import '../widgets/create_chat_bottom_sheet.dart';

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
        appBar: AppBar(
          title: Text('Chats'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showBottomSheet(
              context: context,
              elevation: 10,
              builder: (context) {
                return const CreateChatBottomSheet();
              },
            );
          },
          child: const Icon(Iconsax.message_add),
        ),
        body: BlocBuilder<ChatsCubit, ChatsState>(
          builder: (context, state) {
            if (state is ChatsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatsError) {
              return Center(child: Text(state.message));
            }
            if (state is ChatsLoaded) {
              if (state.rooms.isEmpty) {
                return const Center(child: Text('لا توجد محادثات'));
              }
              return ListView.builder(
                itemCount: state.rooms.length,
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  return ChatCard(item: room);
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
