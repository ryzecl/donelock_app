import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Future<User?> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": email,
        "createdAt": Timestamp.now(),
      });
    }

    return user;
  }

  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
