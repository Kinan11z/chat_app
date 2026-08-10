import 'package:chat_app/features/chat/data/models/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .where(
                      'members',
                      arrayContains: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<ChatRoomModel> items = snapshot.data!.docs
                        .map(
                          (e) => ChatRoomModel.fromJson(e.data()),
                        )
                        .toList()
                      ..sort(
                        (a, b) => (b.lastMessageTime ?? '').compareTo(
                          a.lastMessageTime ?? '',
                        ),
                      );
                    return ListView.builder(
                      itemBuilder: (context, index) => ChatCard(
                        item: items[index],
                      ),
                      itemCount: items.length,
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
