import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/screens/admin_profile_screen.dart';
import 'package:new_app/screens/audit_log_screen.dart';
import 'package:new_app/screens/authentication/login_screen.dart';
import 'create_faculty_screen.dart'; // ✅ new file for Create Faculty

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin (HOD) Dashboard"),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                "Admin Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_4),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  AdminProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_open_rounded),
              title: const Text("View Students"),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.pushNamed(context, '/viewStudents');
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Create Faculty"),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateFacultyScreen()),
                );
              },
            ),
            
          ],
        ),
      ),
    
      body:const AuditLogScreen(),
    );
  }
}
