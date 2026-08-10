import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ContactRemoteDataSource {
  Future<void> addContact(String email);
}

class ContactRemoteDataSourceImp extends ContactRemoteDataSource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String myUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Future<void> addContact(String email) async {
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
}
