import 'dart:typed_data';

import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/chat/data/models/chat_room_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/services/notification_services.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ChatRemoteDataSource {
  Future<void> createRoom({required String email});
  Future<void> sendMessage({
    required String message,
    required String roomId,
    required String? type,
    required UserEntity userInfo,
  });
  Future<void> sendImage({
    required String roomId,
    required Uint8List imageFile,
    required String fileExtension,
    required UserEntity userInfo,
  });
  Future<void> readMessage({
    required String roomId,
    required String messageId,
  });
  Future<void> deleteMessage({
    required String roomId,
    required List<String> messageIds,
  });
  Stream<List<ChatRoomModel>> getChats();
  Stream<List<MessageModel>> getMessages({required String roomId});
  Stream<List<UserModel>> getUsers({required List<String> ids});
}

class ChatRemoteDataSourceImp extends ChatRemoteDataSource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Future<void> createRoom({required String email}) async {
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
    required UserEntity userInfo,
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
    if (userInfo.pushToken != null && userInfo.pushToken!.isNotEmpty) {
      NotificationServices().sendNotification(
        body: message,
        title: FirebaseAuth.instance.currentUser!.displayName ?? '',
        deviceToken: userInfo.pushToken!,
      );
    }
  }

  @override
  Future<void> sendImage({
    required String roomId,
    required String fileExtension,
    required Uint8List imageFile,
    required UserEntity userInfo,
  }) async {
    final cleanRoomId = roomId.replaceAll(RegExp(r'[\[\], ]'), '');
    final filePath =
        '$cleanRoomId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await Supabase.instance.client.storage
        .from('images')
        .uploadBinary(filePath, imageFile);

    String imageUrl =
        Supabase.instance.client.storage.from('images').getPublicUrl(filePath);
    sendMessage(
      message: imageUrl,
      roomId: roomId,
      type: 'image',
      userInfo: userInfo,
    );
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

  @override
  Stream<List<ChatRoomModel>> getChats() {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    return firebaseFirestore
        .collection('rooms')
        .where('members', arrayContains: myUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<List<MessageModel>> getMessages({required String roomId}) {
    return firebaseFirestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<List<UserModel>> getUsers({required List<String> ids}) {
    return firebaseFirestore
        .collection('users')
        .where('id', whereIn: ids)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .toList());
  }
}
