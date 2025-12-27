import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/screens/authentication/login_screen.dart';
import 'package:new_app/screens/audit_log_screen.dart'; // <-- import our audit log screen

class PrincipalHome extends StatelessWidget {
  const PrincipalHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Principal Dashboard"),
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
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.file_open_rounded),
              title: const Text("View Students"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/viewStudents');
              },
            ),

           
          ],
        ),
      ),

      // 👇 Instead of static text, we directly show logs in home body
      body: const AuditLogScreen(),
    );
  }
}
