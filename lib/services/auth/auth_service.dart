import 'package:cahaya_mulya_abadi/error/server_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instance of auth & firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      // sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info it doesn't exist
      /* _firestore.collection('Users').doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
      ); */

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw const ServerException('Akun Tidak Ditemukan, Coba Lagi.');
      } else if (e.code == 'wrong-password') {
        throw const ServerException('Password Salah, Coba Lagi.');
      } else {
        throw ServerException(e.message ?? '');
      }
    }
  }

  // get current user profile
  Stream<Map<String, dynamic>> getUserProfile() {
    /* final currentUser = _auth.currentUser;

    final res = _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data()!;

        // You can then retrieve the value from the Map like this:
        var name = data['role'];
      }
    }); */

    try {
      return _firestore.collection('Users').snapshots().map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.data()['uid'] == _auth.currentUser!.uid)
            .map((doc) => doc.data())
            .single;
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /* Future<String> getUserRole2() async {
    final currentUser = _auth.currentUser;
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(currentUser!.uid).get();

    // return the user role
    Map<String, dynamic> data = docSnapshot.data()!;
    return data['role'];
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserRole3() {
    return _firestore.collection('Users').doc(_auth.currentUser!.uid).get();
  }

  Stream<DocumentSnapshot> getUserRole4() {
    return _firestore
        .collection('Users')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  } */

  // sign out
  Future<void> signout() async {
    return await _auth.signOut();
  }
}
