import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/features/chat/presentation/manager/chat_room/chat_room_bloc.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../auth/data/models/user_model.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final chatRoomBloc = ChatRoomBloc();
    List<String> roomId = [user.id!, FirebaseAuth.instance.currentUser!.uid]
      ..sort(
        (a, b) => a.compareTo(b),
      );
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user.imageUrl ?? ''),
          backgroundColor: Colors.grey,
          child: (user.imageUrl == '' || user.imageUrl!.isEmpty)
              ? Text(user.name!.characters.first)
              : null,
        ),
        title: Text(user.name ?? ''),
        subtitle: Text(user.about ?? ''),
        trailing: BlocConsumer<ChatRoomBloc, ChatRoomState>(
          bloc: chatRoomBloc,
          listener: (context, state) {
            if (state is ChatRoomSuccess) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userInfo: user,
                    roomId: roomId.toString(),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return IconButton(
              onPressed: () {
                chatRoomBloc.add(CreateChatRoomEvent(email: user.email!));
              },
              icon: state is ChatRoomLoadding
                  ? const CircularProgressIndicator()
                  : const Icon(Iconsax.message),
            );
          },
        ),
      ),
    );
  }
}
