import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CGPACalculationScreen extends StatelessWidget {
  const CGPACalculationScreen({super.key});

  // Convert grade string to grade points
  int gradeToPoint(String grade) {
    switch (grade.toUpperCase()) {
      case "O":
        return 10;
      case "A+":
        return 9;
      case "A":
        return 8;
      case "B+":
        return 7;
      case "B":
        return 6;
      case "C":
        return 5;
      default: // F / RA / absent
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("CGPA Calculation")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('semesterMarks')
            .where('studentId', isEqualTo: uid) // ✅ filter only logged-in student
            .snapshots(),
        builder: (context, snapshot) {
  if (snapshot.hasError) {
    // 🔴 Show Firestore error on screen
    return Center(
      child: Text(
        "Error: ${snapshot.error}",
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
  }

  final courses = snapshot.data!.docs;

  if (courses.isEmpty) {
    return const Center(child: Text("No semester marks found."));
  }

  // ✅ proceed with CGPA calculation using courses
  double totalPoints = 0;
  double totalCredits = 0;

  for (var course in courses) {
    final grade = course['grade'] ?? "";
    final credits = (course['credits'] as num).toDouble(); // safer than parsing
    final gp = gradeToPoint(grade);

    totalPoints += gp * credits;
    totalCredits += credits;
  }

  final cgpa = totalCredits > 0 ? (totalPoints / totalCredits) : 0;

  return Center(
    child: Card(
      margin: const EdgeInsets.all(20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "Overall CGPA: ${cgpa.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    ),
  );
}

      ),
    );
  }
}
