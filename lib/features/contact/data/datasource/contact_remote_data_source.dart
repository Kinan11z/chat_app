import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stream_transform/stream_transform.dart';

abstract class ContactRemoteDataSource {
  Future<void> addContact({required String email});
  Stream<List<UserModel>> getContacts();
}

class ContactRemoteDataSourceImp extends ContactRemoteDataSource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Future<void> addContact({required String email}) async {
    QuerySnapshot userEmail = await firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (userEmail.docs.isNotEmpty) {
      final String userId = userEmail.docs.first.id;

      await firebaseFirestore.collection('users').doc(myUid).update(
        {
          'my_users': FieldValue.arrayUnion(
            [userId],
          ),
        },
      );
    }
  }

  @override
  Stream<List<UserModel>> getContacts() {
    return firebaseFirestore.collection('users').doc(myUid).snapshots()
        .switchMap((doc) {
          final ids = (doc.data()?['my_users'] as List? ?? []).cast<String>();
          if (ids.isEmpty) {
            return Stream.value(<UserModel>[]);
          }
          return firebaseFirestore
              .collection('users')
              .where('id', whereIn: ids)
              .snapshots()
              .map((snap) => snap.docs
                  .map((d) => UserModel.fromJson(d.data()))
                  .toList());
        });
  }
}
