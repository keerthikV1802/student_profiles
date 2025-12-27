import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/services/log_audit.dart';

class SemesterScreen extends StatefulWidget {
  final String semesterName;
  final String? studentId;

  const SemesterScreen({
    super.key,
    required this.semesterName,
    this.studentId,
  });

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  late final String targetUid;
  double calculatedGPA = 0.0;
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

  /// 🔹 Save new course
  Future<void> saveCourse(Map<String, dynamic> course) async {
    await FirebaseFirestore.instance
        .collection("students")
        .doc(targetUid)
        .collection("semesters")
        .doc(widget.semesterName)
        .collection("semesterMarks")
        .doc(course['code'])
        .set({
      "code": course["code"],
      "title": course["title"],
      "grade": course["grade"],
      "attempt": course["attempt"],
      "credits": int.tryParse(course["credits"].toString()) ?? 0,
      "timestamp": FieldValue.serverTimestamp(),
      "studentId": targetUid,
    });
  }

  /// 🔹 GPA calculation
  Future<void> calculateGPA() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("students")
        .doc(targetUid)
        .collection("semesters")
        .doc(widget.semesterName)
        .collection("semesterMarks")
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() => calculatedGPA = 0.0);
      return;
    }

    double totalPoints = 0;
    int totalCredits = 0;

    for (var doc in snapshot.docs) {
      final course = doc.data();
      final grade = course["grade"];
      final credits = int.tryParse(course["credits"].toString()) ?? 0;

      final points = _gradeToPoint(grade) * credits;
      totalPoints += points;
      totalCredits += credits;
    }

    setState(() {
      calculatedGPA = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    });
  }

  /// 🔹 Convert grade to numeric points
  double _gradeToPoint(String grade) {
    switch (grade.toUpperCase()) {
      case "O":
        return 10.0;
      case "A+":
        return 9.0;
      case "A":
        return 8.0;
      case "B+":
        return 7.0;
      case "B":
        return 6.0;
      case "C":
        return 5.0;
      default:
        return 0.0;
    }
  }

  /// 🔹 Add new course dialog
  void _showAddCourseDialog() {
    final codeController = TextEditingController();
    final titleController = TextEditingController();
    final creditsController = TextEditingController();

    String selectedGrade = "O";
    String selectedAttempt = "1";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Course"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "Course Code"),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Course Title"),
              ),
              TextField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Credits"),
              ),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                items: ["O", "A+", "A", "B+", "B", "C", "RA"]
                    .map((grade) =>
                        DropdownMenuItem(value: grade, child: Text(grade)))
                    .toList(),
                onChanged: (val) => selectedGrade = val!,
                decoration: const InputDecoration(labelText: "Grade"),
              ),
              DropdownButtonFormField<String>(
                value: selectedAttempt,
                items: ["1", "2", "3", "4"]
                    .map((attempt) =>
                        DropdownMenuItem(value: attempt, child: Text("Attempt $attempt")))
                    .toList(),
                onChanged: (val) => selectedAttempt = val!,
                decoration: const InputDecoration(labelText: "Attempt"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newCourse = {
                "code": codeController.text.trim(),
                "title": titleController.text.trim(),
                "grade": selectedGrade,
                "attempt": selectedAttempt,
                "credits": creditsController.text.trim(),
              };

              saveCourse(newCourse);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// 🔹 Edit course dialog (faculty/admin only)
  void _showEditCourseDialog(String docId, Map<String, dynamic> data) {
    final codeController = TextEditingController(text: data["code"]);
    final titleController = TextEditingController(text: data["title"]);
    final creditsController = TextEditingController(text: "${data["credits"]}");
    String selectedGrade = data["grade"] ?? "O";
    String selectedAttempt = data["attempt"] ?? "1";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Course"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "Course Code"),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Course Title"),
              ),
              TextField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Credits"),
              ),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                items: ["O", "A+", "A", "B+", "B", "C", "RA"]
                    .map((grade) =>
                        DropdownMenuItem(value: grade, child: Text(grade)))
                    .toList(),
                onChanged: (val) => selectedGrade = val!,
                decoration: const InputDecoration(labelText: "Grade"),
              ),
              DropdownButtonFormField<String>(
                value: selectedAttempt,
                items: ["1", "2", "3", "4"]
                    .map((attempt) =>
                        DropdownMenuItem(value: attempt, child: Text("Attempt $attempt")))
                    .toList(),
                onChanged: (val) => selectedAttempt = val!,
                decoration: const InputDecoration(labelText: "Attempt"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("students")
                  .doc(targetUid)
                  .collection("semesters")
                  .doc(widget.semesterName)
                  .collection("semesterMarks")
                  .doc(docId)
                  .update({
                "code": codeController.text.trim(),
                "title": titleController.text.trim(),
                "credits": int.tryParse(creditsController.text.trim()) ?? 0,
                "grade": selectedGrade,
                "attempt": selectedAttempt,
              });
              // 🔹 Fetch the student's readable details before logging
final studentDoc = await FirebaseFirestore.instance
    .collection("students")
    .doc(targetUid)
    .get();

final studentName = studentDoc.data()?["name"] ?? "Unknown Student";
final studentDept = studentDoc.data()?["department"] ?? "-";

await LogAuditService.logAudit(
  action: "Updated in Semester Grades",
  targetName: "$studentName ($studentDept) - ${titleController.text.trim()}",
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
    return Scaffold(
      appBar: AppBar(title: Text("Semester ${widget.semesterName}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Saved Courses:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("students")
                    .doc(targetUid)
                    .collection("semesters")
                    .doc(widget.semesterName)
                    .collection("semesterMarks")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No courses added yet"));
                  }

                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text("${data["code"]} - ${data["title"]}"),
                          subtitle: Text(
                            "Grade: ${data["grade"]} | Attempt: ${data["attempt"]} | Credits: ${data["credits"]}",
                          ),
                          onTap: () {
                            if (isFacultyOrAdmin) {
                              _showEditCourseDialog(docs[index].id, data);
                            }
                          },
                          trailing: isFacultyOrAdmin
                              ? const Icon(Icons.edit, color: Colors.blueAccent)
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showAddCourseDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Course"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: calculateGPA,
              icon: const Icon(Icons.calculate),
              label: const Text("Recalculate GPA"),
            ),
            const SizedBox(height: 12),
            Text("Generated GPA: ${calculatedGPA.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
