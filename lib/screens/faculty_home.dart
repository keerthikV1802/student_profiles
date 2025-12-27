import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/screens/audit_log_screen.dart';
import 'package:new_app/screens/authentication/login_screen.dart';
import 'package:new_app/screens/faculty_leaveapproval_screen.dart';
import 'package:new_app/screens/faculty_profile_screen.dart';

class FacultyDashboardScreen extends StatelessWidget {
  const FacultyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Dashboard"),
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

      // ✅ Drawer added here
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                "Faculty Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),

            
            ListTile(
  leading: Icon(Icons.person),
  title: Text("Profile"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FacultyProfileScreen()),
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
            leading: Icon(Icons.mail),
            title: Text("Leave Requests"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FacultyLeaveApprovalScreen()),
              );
            }
            )


            // 🔹 you can add more items later here (Profile, Settings, etc.)
          ],
        ),
      ),

     body: const AuditLogScreen(),
    );
  }
}
