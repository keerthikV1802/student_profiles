import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/screens/authentication/login_screen.dart';

import 'package:new_app/screens/student/studenthome_drawer.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final StudentService _studentService = StudentService();
  Student? _student; // store logged in student details
  bool _isLoading = true;
  

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final user = FirebaseAuth.instance.currentUser; // get logged-in user
      if (user != null) {
        final student = await _studentService.getStudentById(user.uid);
        setState(() {
          _student = student;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading student: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile Book"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      drawer: StudentHomeDrawer(student: _student, onRefresh: _loadStudentData, uid: '',),

      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _student != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Photo
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _student!.photo != null &&
                                _student!.photo!.isNotEmpty
                            ? MemoryImage(base64Decode((_student!.photo!)))
                            : const AssetImage("assets/default_avatar.png")
                                as ImageProvider,
                      ),
                      const SizedBox(height: 20),

                      // Name
                      Text(
                        _student!.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Register No
                      Text(
                        "Register No: ${_student!.registerNo}",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 5),

                      // Department
                      Text(
                        "Department: ${_student!.department}",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 5),

                      // ✅ Current Year (calculated from admissionYear)
                      Builder(
  builder: (_) {
    final admissionYear = _student!.admissionYear; // already an int
    final currentYear = DateTime.now().year - admissionYear + 1;

    return Text(
      "Year: $currentYear",
      style: const TextStyle(fontSize: 16),
    );
  },
),

                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "No student data found",
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      Text(
                        "Please fill details",
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
      ),
    );
  }
}
