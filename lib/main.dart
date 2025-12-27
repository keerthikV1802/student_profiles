import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new_app/screens/authentication/login_screen.dart';
import 'package:new_app/screens/faculty_home.dart';
import 'package:new_app/screens/viewstudents_screen.dart';  // 👈 import your screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Profile Book',
      theme: ThemeData(primarySwatch: Colors.blue),

      // first screen
      home: const LoginScreen(),

      // ✅ add routes here
      routes: {
        '/login': (context) => const LoginScreen(),
        '/facultyHome': (context) => const FacultyDashboardScreen(),
        '/viewStudents': (context) => const ViewStudentsScreen(),
      },
    );
  }
}
