import 'dart:io';

import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/chat/data/models/chat_room_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/services/notification_services.dart';

abstract class ChatRemoteDataSource {
  Future<void> createRoom(String email);
  Future<void> sendMessage({
    required String message,
    required String roomId,
    required String? type,
    required UserModel userInfo,
  });
  Future<void> sendImage({
    required String roomId,
    required File imageFile,
    required UserModel userInfo,
  });
  Future<void> readMessage({
    required String roomId,
    required String messageId,
  });
  Future<void> deleteMessage({
    required String roomId,
    required List<String> messageIds,
  });
}

class ChatRemoteDataSourceImp extends ChatRemoteDataSource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Future<void> createRoom(String email) async {
    QuerySnapshot userEmail = await firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (userEmail.docs.isNotEmpty) {
      //  final String userId = userEmail.docs[0]['id'];
      final String userId = userEmail.docs.first.id;
      List<String> members = [myUid, userId]..sort(
          (a, b) => a.compareTo(b),
        );
      QuerySnapshot roomExist = await firebaseFirestore
          .collection('rooms')
          .where('members', isEqualTo: members)
          .get();
      if (roomExist.docs.isEmpty) {
        ChatRoomModel chatRoom = ChatRoomModel(
          id: members.toString(),
          lastMessage: '',
          lastMessageTime: DateTime.now().millisecondsSinceEpoch.toString(),
          members: members,
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        await firebaseFirestore
            .collection('rooms')
            .doc(members.toString())
            .set(chatRoom.toJson());
      }
    }
  }

  @override
  Future<void> sendMessage({
    required String message,
    required String roomId,
    required String? type,
    required UserModel userInfo,
  }) async {
    String messageId = const Uuid().v1();
    MessageModel messageInfo = MessageModel(
      id: messageId,
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      fromId: myUid,
      toId: userInfo.id,
      message: message,
      read: '',
      type: type ?? 'text',
    );
    await firebaseFirestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .set(messageInfo.toJson());
    await firebaseFirestore.collection('rooms').doc(roomId).update(
      {
        'last_message': type ?? message,
        'last_message_time': DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
    NotificationServices().sendNotification(
      body: message,
      title: FirebaseAuth.instance.currentUser!.displayName ?? '',
      deviceToken: userInfo.pushToken!,
    );
  }

  @override
  Future<void> sendImage({
    required String roomId,
    required File imageFile,
    required UserModel userInfo,
  }) async {
    try {
      String ext = imageFile.path.split('.').last.split('/').last.toLowerCase();
      final cleanRoomId = roomId.replaceAll(RegExp(r'[\[\], ]'), '');
      final filePath =
          '$cleanRoomId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await Supabase.instance.client.storage
          .from('images')
          .upload(filePath, imageFile);

      String imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(filePath);
      sendMessage(
        message: imageUrl,
        roomId: roomId,
        type: 'image',
        userInfo: userInfo,
      );
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  @override
  Future<void> readMessage(
      {required String roomId, required String messageId}) async {
    await firebaseFirestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update(
      {
        'read': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  @override
  Future<void> deleteMessage(
      {required String roomId, required List<String> messageIds}) async {
    for (var element in messageIds) {
      await firebaseFirestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(element)
          .delete();
    }
  }
}
