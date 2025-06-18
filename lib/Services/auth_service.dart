import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> createUserDocumentIfNeeded(User user) async {
  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await docRef.get();

  if (!doc.exists) {
    await docRef.set({
      'name': 'New User',
      'goal': 'Set your goal',
      'profileImageURL': null,
    });
  }
}
  // Utility to show flushbar
  void _showFlushbar(BuildContext context, String message, {Color? color}) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.BOTTOM,
      backgroundColor: color ?? Colors.black87,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    ).show(context);
  }

  // Sign up
 Future<User?> signUp(
  BuildContext context,
  String email,
  String password,
  String name,
  String goal,
) async {
  try {
    final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'goal': goal,
          'profileImageURL': null,
        });
      } catch (e) {if (context.mounted) {
        _showFlushbar(context, "Failed to save profile: $e", color: Colors.red);
        debugPrint("🔥 Firestore write error: $e");
        // Still return user, so app doesn't get stuck
      }}
if (context.mounted) {
      _showFlushbar(context, "Signup successful!", color: Colors.green);
    }}

    return user;
  } on FirebaseAuthException catch (e) {
    if (context.mounted) {_showFlushbar(context, e.message ?? "Signup failed", color: Colors.red);
    return null;
  }}
}



  // Log in
  Future<User?> signIn(BuildContext context, String email, String password) async {
  try {
    final UserCredential userCredential = await _auth
        .signInWithEmailAndPassword(email: email, password: password);

    final user = userCredential.user;
    if (user != null) {
      try {
  await createUserDocumentIfNeeded(user);
} catch (e) {
  debugPrint("⚠️ Failed to ensure Firestore doc exists: $e");
}if (context.mounted) {
      _showFlushbar(context, "Login successful!", color: Colors.green);
    }}

    return user;
  } on FirebaseAuthException catch (e) {
   if (context.mounted) {
    _showFlushbar(context, e.message ?? "Login failed", color: Colors.red);
    return null;
  }}
}


  // Log out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Current user
  User? get currentUser => _auth.currentUser;
}
