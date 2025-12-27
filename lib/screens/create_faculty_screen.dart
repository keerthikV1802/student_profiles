import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CreateFacultyScreen extends StatefulWidget {
  const CreateFacultyScreen({super.key});

  @override
  State<CreateFacultyScreen> createState() => _CreateFacultyScreenState();
}

class _CreateFacultyScreenState extends State<CreateFacultyScreen> {
  final _auth = AuthService();
  String email = "", password = "", name = "", dept = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Faculty")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create Faculty Account",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
                decoration: const InputDecoration(labelText: "Faculty Name"),
                onChanged: (v) => name = v),
            TextField(
                decoration: const InputDecoration(labelText: "Email"),
                onChanged: (v) => email = v),
            TextField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onChanged: (v) => password = v),
            TextField(
                decoration: const InputDecoration(labelText: "Department"),
                onChanged: (v) => dept = v),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _auth.createFacultyAccount(
                    email: email, password: password, name: name, dept: dept);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Faculty Created Successfully")));
                Navigator.pop(context); // ✅ go back to AdminHome after success
              },
              child: const Text("Create Faculty"),
            ),
          ],
        ),
      ),
    );
  }
}
