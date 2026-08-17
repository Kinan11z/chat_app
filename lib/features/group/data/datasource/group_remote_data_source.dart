import 'dart:io';

import 'package:chat_app/features/group/data/models/chat_group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/services/notification_services.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../chat/data/models/message_model.dart';

abstract class GroupRemoteDataSource {
  Future createGroup({
    required String name,
    required List members,
  });
  Future editGroup({
    required String groupId,
    required String name,
    required List members,
  });
  Future sendGroupMessage({
    required String message,
    required ChatGroupModel groupInfo,
    required String? type,
  });
  Future<void> sendImage({
    required File imageFile,
    required ChatGroupModel groupInfo,
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
}

class GroupRemoteDataSourceImp extends GroupRemoteDataSource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;
  final String dateNow = DateTime.now().millisecondsSinceEpoch.toString();
  @override
  Future createGroup({required String name, required List members}) async {
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
    required ChatGroupModel groupInfo,
  }) async {
    List members = groupInfo.members ?? [];
    members.remove(myUid);
    List<UserModel> users = [];

    firebaseFirestore
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
    required File imageFile,
    required ChatGroupModel groupInfo,
  }) async {
    try {
      String ext = imageFile.path.split('.').last.split('/').last.toLowerCase();
      final cleanGroupId = groupInfo.id?.replaceAll(RegExp(r'[\[\], ]'), '');
      final filePath =
          '$cleanGroupId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await Supabase.instance.client.storage
          .from('images')
          .upload(filePath, imageFile);

      String imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(filePath);
      sendGroupMessage(
        message: imageUrl,
        groupInfo: groupInfo,
        type: 'image',
      );
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  @override
  Future editGroup({
    required String groupId,
    required String name,
    required List members,
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
}
