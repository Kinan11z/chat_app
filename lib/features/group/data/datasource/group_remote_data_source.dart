import 'dart:typed_data';

import 'package:chat_app/features/group/data/models/chat_group_model.dart';
import 'package:chat_app/features/group/data/models/group_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/services/notification_services.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../chat/data/models/message_model.dart';
import '../../domain/entities/chat_group_entity.dart';

abstract class GroupRemoteDataSource {
  Future createGroup({
    required String name,
    required List<String> members,
  });
  Future editGroup({
    required String groupId,
    required String name,
    required List<String> members,
  });
  Future sendGroupMessage({
    required String message,
    required ChatGroupEntity groupInfo,
    required String? type,
  });
  Future<void> sendImage({
    required Uint8List imageFile,
    required ChatGroupEntity groupInfo,
    required String fileExtension,
  });
  Future removeMember({
    required String memberId,
    required String groupId,
  });
  Future promoteMember({
    required String memberId,
    required String groupId,
  });
  Future removePromote({
    required String memberId,
    required String groupId,
  });
  Stream<List<ChatGroupModel>> getGroups();
  Stream<List<GroupMessageModel>> getGroupMessages({required String groupId});
  Stream<List<UserModel>> getUsers({required List<String> ids});
}

class GroupRemoteDataSourceImp extends GroupRemoteDataSource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;
  final String dateNow = DateTime.now().millisecondsSinceEpoch.toString();
  @override
  Future createGroup(
      {required String name, required List<String> members}) async {
    final String groupId = const Uuid().v1();
    members.add(myUid);
    ChatGroupModel groupInfo = ChatGroupModel(
      id: groupId,
      admins: [myUid],
      name: name,
      members: members,
      image: '',
      lastMessage: '',
      lastMessageTime: dateNow,
      createdAt: dateNow,
    );
    await firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .set(groupInfo.toJson());
  }

  @override
  Future<void> sendGroupMessage({
    required String message,
    required String? type,
    required ChatGroupEntity groupInfo,
  }) async {
    List members = groupInfo.members ?? [];
    members.remove(myUid);
    List<UserModel> users = [];

    await firebaseFirestore
        .collection('users')
        .where('id', whereIn: members)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => users.add(UserModel.fromJson(doc.data())))
          .toList();
    });
    String messageId = const Uuid().v1();
    MessageModel messageInfo = MessageModel(
      id: groupInfo.id,
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      fromId: myUid,
      message: message,
      read: '',
      toId: '',
      type: type ?? 'text',
    );
    await firebaseFirestore
        .collection('groups')
        .doc(groupInfo.id)
        .collection('messages')
        .doc(messageId)
        .set(messageInfo.toJson());
    await firebaseFirestore.collection('groups').doc(groupInfo.id).update(
      {
        'last_message': type ?? message,
        'last_message_time': DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
    for (var element in users) {
      if (element.pushToken != null) {
        NotificationServices().sendNotification(
          body: '${element.name}: $message',
          title: groupInfo.name ?? '',
          deviceToken: element.pushToken!,
        );
      }
    }
  }

  @override
  Future<void> sendImage({
    required Uint8List imageFile,
    required ChatGroupEntity groupInfo,
    required String fileExtension,
  }) async {
    final cleanGroupId = groupInfo.id.replaceAll(RegExp(r'[\[\], ]'), '');
    final filePath =
        '$cleanGroupId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await Supabase.instance.client.storage
        .from('images')
        .uploadBinary(filePath, imageFile);

    String imageUrl =
        Supabase.instance.client.storage.from('images').getPublicUrl(filePath);
    sendGroupMessage(
      message: imageUrl,
      groupInfo: groupInfo,
      type: 'image',
    );
  }

  @override
  Future editGroup({
    required String groupId,
    required String name,
    required List<String> members,
  }) async {
    await firebaseFirestore.collection('groups').doc(groupId).update({
      'name': name,
      'members': FieldValue.arrayUnion(members),
    });
  }

  @override
  Future removeMember(
      {required String memberId, required String groupId}) async {
    await firebaseFirestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([memberId]),
    });
  }

  @override
  Future promoteMember(
      {required String memberId, required String groupId}) async {
    await firebaseFirestore.collection('groups').doc(groupId).update({
      'admins_id': FieldValue.arrayUnion([memberId]),
    });
  }

  @override
  Future removePromote(
      {required String memberId, required String groupId}) async {
    await firebaseFirestore.collection('groups').doc(groupId).update({
      'admins_id': FieldValue.arrayRemove([memberId]),
    });
  }

  @override
  Stream<List<ChatGroupModel>> getGroups() {
    return firebaseFirestore
        .collection('groups')
        .where('members', arrayContains: myUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatGroupModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Stream<List<GroupMessageModel>> getGroupMessages({required String groupId}) {
    return firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupMessageModel.fromJson(doc.data()))
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
