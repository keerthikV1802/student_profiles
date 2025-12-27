import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/screens/student_home.dart';
import 'package:new_app/services/log_audit.dart';

class InternalMarksScreen extends StatefulWidget {
  final String semester;
  final String? studentId;

  const InternalMarksScreen({
    super.key,
    required this.semester,
    this.studentId,
  });

  @override
  State<InternalMarksScreen> createState() => _InternalMarksScreenState();
}

class _InternalMarksScreenState extends State<InternalMarksScreen> {
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  late final String targetUid;

  String selectedExam = "Exam 1";
  final List<String> exams = ["Exam 1", "Exam 2", "Exam 3"];

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
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final role = userDoc['role'];
      if (role == 'faculty' || role == 'admin') {
        setState(() => isFacultyOrAdmin = true);
      }
    }
  }

  void _addCourse() {
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final marksController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Add New Course"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: codeController,
            decoration: const InputDecoration(labelText: "Course Code"),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Course Name"),
          ),
          TextField(
            controller: marksController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Marks"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final docRef = _firestore
                .collection("students")
                .doc(targetUid)
                .collection("semesters")
                .doc(widget.semester)
                .collection("internalMarks")
                .doc(selectedExam)
                .collection("courses")
                .doc(); // auto ID

            await docRef.set({
              "courseCode": codeController.text.trim(),
              "courseName": nameController.text.trim(),
              "marks": int.tryParse(marksController.text.trim()) ?? 0,
              "saved": true,
            });

            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}


  Future<void> _saveCourse(
      String courseId, Map<String, dynamic> data) async {
    final docRef = _firestore
        .collection("students")
        .doc(targetUid)
        .collection("semesters")
        .doc(widget.semester)
        .collection("internalMarks")
        .doc(selectedExam)
        .collection("courses")
        .doc(courseId);

    data["saved"] = true;
    await docRef.set(data, SetOptions(merge: true));
  }

  Future<void> _showEditDialog(
      String courseId, Map<String, dynamic> data) async {
    final codeController =
        TextEditingController(text: data["courseCode"] ?? "");
    final nameController =
        TextEditingController(text: data["courseName"] ?? "");
    final marksController =
        TextEditingController(text: "${data["marks"] ?? 0}");

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Course"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: "Course Code"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Course Name"),
            ),
            TextField(
              controller: marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Marks"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _firestore
                  .collection("students")
                  .doc(targetUid)
                  .collection("semesters")
                  .doc(widget.semester)
                  .collection("internalMarks")
                  .doc(selectedExam)
                  .collection("courses")
                  .doc(courseId)
                  .update({
                "courseCode": codeController.text.trim(),
                "courseName": nameController.text.trim(),
                "marks": int.tryParse(marksController.text.trim()) ?? 0,
              });
              // 🔹 Fetch the student's readable details before logging
final studentDoc = await FirebaseFirestore.instance
    .collection("students")
    .doc(targetUid)
    .get();

final studentName = studentDoc.data()?["name"] ?? "Unknown Student";
final studentDept = studentDoc.data()?["department"] ?? "-";

await LogAuditService.logAudit(
  action: "Updated internalMarks",
  targetName: "$studentName ($studentDept) - ${nameController.text.trim()}",
);

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursesRef = _firestore
        .collection("students")
        .doc(targetUid)
        .collection("semesters")
        .doc(widget.semester)
        .collection("internalMarks")
        .doc(selectedExam)
        .collection("courses");

    return Scaffold(
      appBar: AppBar(
        title: Text("Internal Marks - ${widget.semester}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentHomeScreen(),
                ),
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: selectedExam,
              decoration: const InputDecoration(
                labelText: "Select Exam",
                border: OutlineInputBorder(),
              ),
              items: exams
                  .map((exam) =>
                      DropdownMenuItem(value: exam, child: Text(exam)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedExam = value!);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: coursesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading courses"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courses = snapshot.data!.docs;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...courses.map((doc) {
                      final data =
                          Map<String, dynamic>.from(doc.data() as Map);
                      final courseId = doc.id;
                      final isSaved = data["saved"] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(
                              "${data["courseCode"] ?? ""} - ${data["courseName"] ?? ""}"),
                          subtitle: Text("Marks: ${data["marks"] ?? 0}"),
                          onTap: () {
                            if (isFacultyOrAdmin) {
                              _showEditDialog(courseId, data);
                            }
                          },
                          trailing: !isSaved
                              ? ElevatedButton.icon(
                                  onPressed: () {
                                    _saveCourse(courseId, data);
                                  },
                                  icon: const Icon(Icons.save),
                                  label: const Text("Save"),
                                )
                              : isFacultyOrAdmin
                                  ? const Icon(Icons.edit,
                                      color: Colors.blueAccent)
                                  : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _addCourse,
                      icon: const Icon(Icons.add),
                      label: const Text("Add New Course"),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
