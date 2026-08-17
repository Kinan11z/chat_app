import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/utils/helper_functions.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/chat/data/models/chat_room_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_format.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.item,
  });
  final ChatRoomModel item;
  @override
  Widget build(BuildContext context) {
    final List members = item.members!
        .where(
          (element) => element != FirebaseAuth.instance.currentUser!.uid,
        )
        .toList();
    String userId = members.isEmpty
        ? FirebaseAuth.instance.currentUser!.uid
        : members.first;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final UserModel userInfo = UserModel.fromJson(snapshot.data!.data()!);

          return Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      userInfo: userInfo,
                      roomId: item.id ?? '',
                    ),
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(userInfo.imageUrl ?? ''),
                backgroundColor: Colors.grey,
                child: (userInfo.imageUrl == '' || userInfo.imageUrl!.isEmpty)
                    ? Text(userInfo.name!.characters.first)
                    : null,
              ),
              title: Text(userInfo.name ?? ''),
              subtitle: Text(
                item.lastMessage == ''
                    ? userInfo.about ?? ''
                    : item.lastMessage ?? '',
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(item.id)
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  List<MessageModel> unreadMessages = snapshot.data?.docs
                          .map(
                            (e) => MessageModel.fromJson(e.data()),
                          )
                          .where(
                            (element) => element.read == '',
                          )
                          .where(
                            (element) =>
                                element.fromId !=
                                FirebaseAuth.instance.currentUser?.uid,
                          )
                          .toList() ??
                      [];
                  return unreadMessages.isNotEmpty
                      ? Badge(
                          label: Text(unreadMessages.length.toString()),
                        )
                      : Text(
                          AppDateTimeFormatter.dateAndTime(
                            item.lastMessageTime ?? '',
                          ),
                        );
                },
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
