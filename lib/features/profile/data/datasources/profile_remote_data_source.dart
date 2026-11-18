import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<ProfileRemoteData> getProfile() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();

    final data = snapshot.data();

    return ProfileRemoteData(
      id: user.uid,
      name: data?['name']?.toString() ?? '',
      email: data?['email']?.toString() ?? user.email ?? '',
    );
  }
}

class ProfileRemoteData {
  const ProfileRemoteData({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}
