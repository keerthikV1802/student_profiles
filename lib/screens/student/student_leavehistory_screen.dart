import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class StudentLeaveHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(title: Text("My Leave Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("students")
            .doc(user.uid)
            .collection("leave_requests")
            .orderBy("fromDate", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;
          if (requests.isEmpty) return Center(child: Text("No leave requests yet"));

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Faculty: ${req['facultyName']}"),
                  subtitle: Text(
                    "From: ${req['fromDate'].toDate().toString().split(" ")[0]}\n"
                    "To: ${req['toDate'].toDate().toString().split(" ")[0]}\n"
                    "Reason: ${req['reason']}",
                  ),
                  trailing: Chip(
                    label: Text(req['status']),
                    backgroundColor: req['status'] == "approved"
                        ? Colors.green
                        : req['status'] == "rejected"
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
