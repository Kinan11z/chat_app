import 'package:chat_app/features/group/data/models/chat_group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

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
    required String groupId,
    required String? type,
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
    required String groupId,
    required String? type,
  }) async {
    String messageId = const Uuid().v1();
    MessageModel messageInfo = MessageModel(
      id: messageId,
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      fromId: myUid,
      message: message,
      read: '',
      toId: '',
      type: type ?? 'text',
    );
    await firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .set(messageInfo.toJson());
    firebaseFirestore.collection('groups').doc(groupId).update(
      {
        'last_message': type ?? message,
        'last_message_time': DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
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
