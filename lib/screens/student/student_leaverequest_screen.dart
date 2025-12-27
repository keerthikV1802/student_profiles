import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentLeaveRequestScreen extends StatefulWidget {
  @override
  _StudentLeaveRequestScreenState createState() => _StudentLeaveRequestScreenState();
}

class _StudentLeaveRequestScreenState extends State<StudentLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();

  String? selectedFacultyId;
  String? selectedFacultyName;

  DateTime? fromDate;
  DateTime? toDate;

  Future<void> submitLeave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || fromDate == null || toDate == null || selectedFacultyId == null) return;

    // 1. Add to faculty sub-collection
    final leaveDoc = await FirebaseFirestore.instance
        .collection("faculty")
        .doc(selectedFacultyId)
        .collection("leave_requests")
        .add({
      "studentId": user.uid,
      "studentName": user.displayName ?? "Unknown",
      "fromDate": fromDate,
      "toDate": toDate,
      "reason": reasonController.text,
      "status": "pending",
      "response": "",
      "viewed": false,
      "requestedAt": FieldValue.serverTimestamp(),
    });

    // 2. Add to student sub-collection (for tracking)
    await FirebaseFirestore.instance
        .collection("students")
        .doc(user.uid)
        .collection("leave_requests")
        .doc(leaveDoc.id)
        .set({
      "facultyId": selectedFacultyId,
      "facultyName": selectedFacultyName,
      "fromDate": fromDate,
      "toDate": toDate,
      "reason": reasonController.text,
      "status": "pending",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Leave request submitted!")),
    );
    Navigator.pop(context);
  }

  Future<void> pickDate(bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Leave")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Faculty dropdown
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("faculty").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final faculties = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: selectedFacultyId,
                    hint: Text("Select Faculty"),
                    onChanged: (val) {
                      setState(() {
                        selectedFacultyId = val;
                        selectedFacultyName = faculties.firstWhere((f) => f.id == val)['name'];
                      });
                    },
                    items: faculties.map((doc) {
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 10),

              // Dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => pickDate(true),
                    child: Text(fromDate == null ? "Select From Date" : fromDate.toString().split(" ")[0]),
                  ),
                  TextButton(
                    onPressed: () => pickDate(false),
                    child: Text(toDate == null ? "Select To Date" : toDate.toString().split(" ")[0]),
                  ),
                ],
              ),

              // Reason
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(labelText: "Reason"),
                validator: (val) => val!.isEmpty ? "Enter reason" : null,
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitLeave,
                child: Text("Submit Request"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
