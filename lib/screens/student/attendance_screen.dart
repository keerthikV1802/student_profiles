import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/services/log_audit.dart';

class AddAttendanceScreen extends StatefulWidget {
  final String semester;
  
  final String? studentId;
  const AddAttendanceScreen({super.key, required this.semester,this.studentId});

  @override
  State<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _totalController = TextEditingController();
  final _attendedController = TextEditingController();

  
  late final String targetUid;
  bool isFacultyOrAdmin = false;

@override
void initState() {
  super.initState();
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  targetUid = widget.studentId ?? currentUid;
  _checkRole();
 

}

Future<void> _checkRole() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (userDoc.exists) {
    final role = userDoc['role'];
    if (role == 'faculty' || role == 'admin') {
      setState(() => isFacultyOrAdmin = true);
    }
  }
}




  Future<void> _showEditDialog(String docId, Map<String, dynamic> data) async {
  final subjectController = TextEditingController(text: data["subject"]);
  final totalController = TextEditingController(text: "${data["totalClasses"]}");
  final attendedController = TextEditingController(text: "${data["attendedClasses"]}");

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Attendance"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: subjectController, decoration: const InputDecoration(labelText: "Subject")),
          TextField(controller: totalController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Total Classes")),
          TextField(controller: attendedController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Attended Classes")),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection("students")
                .doc(targetUid)
                .collection("semesters")
                .doc(widget.semester)
                .collection("attendance")
                .doc(docId)
                .update({
              "subject": subjectController.text.trim(),
              "totalClasses": int.tryParse(totalController.text.trim()) ?? 0,
              "attendedClasses": int.tryParse(attendedController.text.trim()) ?? 0,
            });
            // 🔹 Fetch the student's readable details before logging
final studentDoc = await FirebaseFirestore.instance
    .collection("students")
    .doc(targetUid)
    .get();

final studentName = studentDoc.data()?["name"] ?? "Unknown Student";
final studentDept = studentDoc.data()?["department"] ?? "-";

await LogAuditService.logAudit(
  action: "updated attendance",
  targetName: "$studentName ($studentDept) - ${subjectController.text.trim()}",
);

            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
  
}

  Future<void> _saveAttendance() async {
  if (_formKey.currentState!.validate()) {
    
    final subject = _subjectController.text.trim();

    // If faculty is logged in, you must pass the student's UID to this screen
    // For students, just use their own uid
    

    await FirebaseFirestore.instance
        .collection("students")
        .doc(targetUid)
        .collection("semesters")
        .doc(widget.semester)
        .collection("attendance")
        .doc(subject)
        .set({
      "subject": subject,
      "totalClasses": int.tryParse(_totalController.text.trim()) ?? 0,
      "attendedClasses": int.tryParse(_attendedController.text.trim()) ?? 0,
      "timestamp": FieldValue.serverTimestamp(),
    });

    _subjectController.clear();
    _totalController.clear();
    _attendedController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attendance saved successfully")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(title: Text("Attendance - ${widget.semester}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(labelText: "Subject"),
                    validator: (val) =>
                        val!.isEmpty ? "Enter subject name" : null,
                  ),
                  TextFormField(
                    controller: _totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Total Classes"),
                    validator: (val) =>
                        val!.isEmpty ? "Enter total classes" : null,
                  ),
                  TextFormField(
                    controller: _attendedController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Attended Classes"),
                    validator: (val) =>
                        val!.isEmpty ? "Enter attended classes" : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _saveAttendance,
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("students")
                    .doc(targetUid)
                    .collection("semesters")
                    .doc(widget.semester)
                    .collection("attendance")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No attendance records yet"));
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
  margin: const EdgeInsets.symmetric(vertical: 6),
  child: ListTile(
    title: Text(data["subject"] ?? ""),
    subtitle: Text(
      "Attended: ${data["attendedClasses"]} / ${data["totalClasses"]}",
    ),
    onTap: () {
  if (isFacultyOrAdmin) {
    _showEditDialog(docs[index].id, data);
  }
},

  ),
);

                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
