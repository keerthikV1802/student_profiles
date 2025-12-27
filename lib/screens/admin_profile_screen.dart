import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfileScreen extends StatefulWidget {
  @override
  _FacultyProfileScreenState createState() => _FacultyProfileScreenState();
}

class _FacultyProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final deptController = TextEditingController();
  final designationController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection("hod")
      .doc(user.uid)
      .get();

  if (doc.exists) {
    final data = doc.data()!;
    nameController.text = data["name"] ?? "";
    phoneController.text = data["phone"] ?? "";
    deptController.text = data["department"] ?? "";
    designationController.text = data["designation"] ?? "";
  }

  if (mounted) setState(() => isLoading = false);
}

Future<void> saveProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance.collection("hod").doc(user.uid).set({
    "name": nameController.text,
    "email": user.email,
    "phone": phoneController.text,
    "department": deptController.text,
    "designation": designationController.text,
  }, SetOptions(merge: true));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Profile saved successfully")),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Full Name"),
                      validator: (val) => val!.isEmpty ? "Enter name" : null,
                    ),
                    TextFormField(
                      controller: deptController,
                      decoration: InputDecoration(labelText: "Department"),
                    ),
                    TextFormField(
                      controller: designationController,
                      decoration: InputDecoration(labelText: "Designation"),
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: "Phone Number"),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveProfile,
                      child: Text("Save Profile"),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
