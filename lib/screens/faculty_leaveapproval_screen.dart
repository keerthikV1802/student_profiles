import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultyLeaveApprovalScreen extends StatelessWidget {
  const FacultyLeaveApprovalScreen({super.key});

  Future<void> _respondToLeave(BuildContext context, String requestId, String studentId, String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final TextEditingController responseController = TextEditingController();

    // Show dialog to enter response
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(status == "approved" ? "Approve Leave" : "Reject Leave"),
          content: TextField(
            controller: responseController,
            decoration: InputDecoration(hintText: "Enter response/remarks"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, responseController.text),
              child: Text("Submit"),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      // 1️⃣ Update faculty side
      await FirebaseFirestore.instance
          .collection("faculty")
          .doc(user.uid)
          .collection("leave_requests")
          .doc(requestId)
          .update({
        "status": status,
        "response": result,
        "viewed": true,
        "respondedAt": FieldValue.serverTimestamp(),
      });

      // 2️⃣ Update student side (mirror copy)
      await FirebaseFirestore.instance
          .collection("students")
          .doc(studentId)
          .collection("leave_requests")
          .doc(requestId)
          .update({
        "status": status,
        "response": result,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Leave $status successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Leave Requests")),
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Leave Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("faculty")
            .doc(user.uid)
            .collection("leave_requests")
            .orderBy("requestedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;
          if (requests.isEmpty) return Center(child: Text("No leave requests"));

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final data = req.data() as Map<String, dynamic>;

              return Card(
  margin: EdgeInsets.all(8),
  child: FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection("students")
        .doc(data['studentId'])
        .get(),
    builder: (context, studentSnap) {
      String studentName = "Unknown";
      String year = "";
      if (studentSnap.hasData && studentSnap.data!.exists) {
        final stuData = studentSnap.data!.data() as Map<String, dynamic>;
        studentName = stuData['name'] ?? "Unknown";
        year = "Year: ${stuData['currentYear'] ?? ''}";
      }

      return ListTile(
        title: Text(studentName),
        subtitle: Text(
          "$year\n"
          "From: ${data['fromDate'].toDate().toString().split(" ")[0]}\n"
          "To: ${data['toDate'].toDate().toString().split(" ")[0]}\n"
          "Reason: ${data['reason']}\n"
          "Response: ${data['response']}",
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data['status'].toUpperCase(),
              style: TextStyle(
                color: data['status'] == "approved"
                    ? Colors.green
                    : data['status'] == "rejected"
                        ? Colors.red
                        : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (data['status'] == "pending") ...[
              SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => _respondToLeave(context, req.id, data['studentId'], "approved"),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => _respondToLeave(context, req.id, data['studentId'], "rejected"),
                  ),
                ],
              )
            ]
          ],
        ),
      );
    },
  ),
);

            },
          );
        },
      ),
    );
  }
}
