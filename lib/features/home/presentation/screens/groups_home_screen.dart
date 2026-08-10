import 'package:chat_app/features/group/data/models/chat_group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../group/presentation/screens/create_group_screen.dart';
import '../widgets/group_card.dart';

class GroupsHomeScreen extends StatelessWidget {
  const GroupsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .where(
                    'members',
                    arrayContains: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<ChatGroupModel> myGroups = snapshot.data!.docs
                      .map(
                        (e) => ChatGroupModel.fromJson(
                          e.data(),
                        ),
                      )
                      .toList()
                    ..sort(
                      (a, b) => b.lastMessage!.compareTo(a.lastMessage!),
                    );
                  return Expanded(
                    child: ListView.builder(
                      itemCount: myGroups.length,
                      itemBuilder: (context, index) => GroupCard(
                        groupInfo: myGroups[index],
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
