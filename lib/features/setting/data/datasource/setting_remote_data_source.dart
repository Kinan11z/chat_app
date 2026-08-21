import 'dart:typed_data';

import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SettingsRemoteDataSource {
  Future<void> updateProfileImage({
    required Uint8List imageFile,
    required String fileExtension,
  });
  Future<void> updateProfileDetails({
    required String? name,
    required String? about,
    required Uint8List? imageFile,
    required String fileExtension,
  });
  Stream<UserModel> getCurrentUser();
}

class SettingsRemoteDataSourceImp extends SettingsRemoteDataSource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String get myUid => FirebaseAuth.instance.currentUser!.uid;
  @override
  Future<void> updateProfileImage({
    required Uint8List imageFile,
    required String fileExtension,
  }) async {
    final filePath = 'profiles/$myUid/$myUid.$fileExtension';

    await Supabase.instance.client.storage
        .from('images')
        .updateBinary(filePath, imageFile);

    String imageUrl =
        Supabase.instance.client.storage.from('images').getPublicUrl(filePath);
    imageUrl = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    await FirebaseFirestore.instance.collection('users').doc(myUid).update({
      'image_url': imageUrl,
    });
  }

  @override
  Future<void> updateProfileDetails({
    required String? name,
    required String? about,
    required Uint8List? imageFile,
    required String fileExtension,
  }) async {
    final edit = <String, dynamic>{};
    if (name != null) {
      edit['name'] = name;
    }
    if (about != null) {
      edit['about'] = about;
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .update(edit);
    if (imageFile != null) {
      await updateProfileImage(
        imageFile: imageFile,
        fileExtension: fileExtension,
      );
    }
  }

  @override
  Stream<UserModel> getCurrentUser() {
    return firebaseFirestore.collection('users').doc(myUid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromJson(doc.data()!) : UserModel(),
        );
  }
}
