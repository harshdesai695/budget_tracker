import 'package:budget_tracker/Services/FireBase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInMethods {
  signoutgoogle(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  signInGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      UserCredential result =
          await FireBaseMethods.auth.signInWithCredential(authCredential);
      User? user = result.user;

      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) 
          .get();
          
      if (!snapshot.exists) {
        await FireBaseMethods().addUserdata(
          email: user.email ?? '', 
          username: user.displayName ?? 'New User', 
          profileUrl: user.photoURL ?? '', 
        );
        
        await FireBaseMethods().addDefaultCategories();
      }
    }
  }
}