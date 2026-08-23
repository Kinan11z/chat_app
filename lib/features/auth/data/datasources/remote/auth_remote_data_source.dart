import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password);
  Future<void> resetPassword(String email);
  Future<void> updateActive(bool online);
  Future<void> createUser();
  Stream<User?> authStateChanges();
  Future<void> signOut();
  Future<void> updateDisplayName(String name);
}

class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Stream<User?> authStateChanges() => firebaseAuth.userChanges();
  @override
  Future<User> signIn(String email, String password) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  @override
  Future<User> signUp(String email, String password) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  @override
  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> createUser() async {
    final userModel = UserModel(
      id: firebaseAuth.currentUser?.uid ?? '',
      name: firebaseAuth.currentUser?.displayName ?? '',
      email: firebaseAuth.currentUser?.email ?? '',
      about: "Hello i'm new user",
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      lastActivated: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: '',
      pushToken: '',
      online: false,
      myUsers: [],
    );

    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser?.uid)
        .set(
          userModel.toJson(),
        );
  }

  @override
  Future<void> updateActive(bool online) async {
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser?.uid)
        .update({
      'online': online,
      'last_activated': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  @override
  Future<void> updateDisplayName(String name) async {
    await firebaseAuth.currentUser?.updateDisplayName(name);
  }

  @override
  Future<void> signOut() => firebaseAuth.signOut();
}
