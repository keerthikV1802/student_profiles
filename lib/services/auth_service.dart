import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/student_home.dart';
import '../screens/faculty_home.dart';
import '../screens/admin_home.dart';
import '../screens/principal_home.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // ----------------- STUDENT SIGNUP -----------------
  Future<User?> signupStudent({
    required String email,
    required String password,
    required String name,
    required String dept,
    required String year,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection("users").doc(userCred.user!.uid).set({
      "uid": userCred.user!.uid,
      "email": email,
      "role": "student",
      "dept": dept,
      "year": year,
      "name": name,
    });

    return userCred.user;
  }

  // ----------------- FACULTY CREATION (by Admin) -----------------
  Future<void> createFacultyAccount({
    required String email,
    required String password,
    required String name,
    required String dept,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection("users").doc(userCred.user!.uid).set({
      "uid": userCred.user!.uid,
      "email": email,
      "role": "faculty",
      "dept": dept,
      "name": name,
    });
  }

  // ----------------- LOGIN (old logic style) -----------------
  Future<User?> login(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  // ----------------- LOGIN WITH ROLE CHECK (new style) -----------------
  Future<void> loginUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;

      if (user != null) {
        final userDoc = await _db.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          final role = userDoc["role"];

          if (role == "student") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentHomeScreen())
            );
          } else if (role == "faculty") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FacultyDashboardScreen()),
            );
          } else if (role == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHome()),
            );
          } else if (role == "principal") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PrincipalHome()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user record found in Firestore")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  // ----------------- LOGOUT -----------------
  Future<void> logout() async {
    await _auth.signOut();
  }
}
