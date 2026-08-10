import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SettingRemoteDataSource {
  Future<void> updateProfileImage({
    required File imageFile,
  });
  Future<void> updateProfileDetails({
    required String? name,
    required String? about,
    required File? imageFile,
  });
}

class SettingRemoteDataSourceImp extends SettingRemoteDataSource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Future<void> updateProfileImage({
    required File imageFile,
  }) async {
    try {
      String ext = imageFile.path.split('.').last.split('/').last.toLowerCase();
      final filePath = 'profiles/$myUid/$myUid.$ext';

      await Supabase.instance.client.storage
          .from('images')
          .update(filePath, imageFile);

      String imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(filePath);
      imageUrl = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      await FirebaseFirestore.instance.collection('users').doc(myUid).update({
        'image_url': imageUrl,
      });
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  @override
  Future<void> updateProfileDetails({
    required String? name,
    required String? about,
    required File? imageFile,
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
      await updateProfileImage(imageFile: imageFile);
    }
  }
}
