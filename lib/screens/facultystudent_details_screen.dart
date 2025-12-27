// facultystudent_details_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import child screens
import 'student/student_details_screen.dart';
import 'student/attendance_screen.dart';
import 'student/internal_marks_screen.dart';
import 'student/semester_marks_screen.dart';
import 'student/uploaddocuments_screen.dart';
import 'student/co_curr_act_screen.dart';

class FacultyStudentDetailsScreen extends StatefulWidget {
  final String studentId;
  const FacultyStudentDetailsScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  State<FacultyStudentDetailsScreen> createState() => _FacultyStudentDetailsScreenState();
}

class _FacultyStudentDetailsScreenState extends State<FacultyStudentDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _editingPersonal = false;
  bool _loading = false;

  Future<void> _updatePersonal() async {
    setState(() => _loading = true);
    try {
      await _firestore.collection('students').doc(widget.studentId).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student details updated')));
      setState(() => _editingPersonal = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openAttendance(String semester) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAttendanceScreen(
          semester: semester,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  void _openInternalMarks(String semester) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InternalMarksScreen(
          semester: semester,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  void _openSemesterMarks(String semester) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SemesterScreen(
          semesterName: semester,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  void _openCoCurricular() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoCurricularScreen(studentId: widget.studentId),
      ),
    );
  }

  void _openUploads(String semester) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadDocumentScreen(
          semesterName: semester,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  void _openStudentDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDetailsForm(studentId: widget.studentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile (Faculty)'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
  stream: _firestore.collection('students').doc(widget.studentId).snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Only show "not found" if we actually got a snapshot back but doc doesn't exist
    if (snapshot.hasData && !snapshot.data!.exists) {
      return const Center(child: Text('Student not found'));
    }

    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator()); // fallback loader
    }

    final data = snapshot.data!.data() as Map<String, dynamic>;
    if (!_editingPersonal) {
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
    }

    // ... rest of your UI
  



          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Text(
                        (data['name'] ?? '').toString().isNotEmpty ? data['name'][0] : '?',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['name'] ?? '(no name)'),
                          const SizedBox(height: 4),
                          Text('Dept: ${data['department'] ?? '-'}  | Year: ${data['year'] ?? '-'}'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick personal details editor (name/email/phone only)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Quick Edit: Name / Email / Phone',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _editingPersonal = !_editingPersonal),
                              child: Text(_editingPersonal ? 'Cancel' : 'Edit'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), enabled: _editingPersonal),
                        TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), enabled: _editingPersonal),
                        TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone'), enabled: _editingPersonal),
                        const SizedBox(height: 8),
                        if (_editingPersonal)
                          ElevatedButton(
                            onPressed: _loading ? null : _updatePersonal,
                            child: const Text('Save'),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Full sections
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Student Personal Details'),
                        subtitle: const Text('View / Edit complete profile'),
                        onTap: _openStudentDetails,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Attendance'),
                        subtitle: const Text('Add / Edit per semester'),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => ListView(
                              shrinkWrap: true,
                              children: List.generate(8, (i) {
                                final sem = 'Semester ${i + 1}';
                                return ListTile(
                                  title: Text(sem),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _openAttendance(sem);
                                  },
                                );
                              }),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text('Internal Marks'),
                        subtitle: const Text('Add / Edit internals'),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => ListView(
                              shrinkWrap: true,
                              children: List.generate(8, (i) {
                                final sem = 'Semester ${i + 1}';
                                return ListTile(
                                  title: Text(sem),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _openInternalMarks(sem);
                                  },
                                );
                              }),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calculate),
                        title: const Text('Semester Marks'),
                        subtitle: const Text('Add / Edit semester exam marks'),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => ListView(
                              shrinkWrap: true,
                              children: List.generate(8, (i) {
                                final sem = 'Semester ${i + 1}';
                                return ListTile(
                                  title: Text(sem),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _openSemesterMarks(sem);
                                  },
                                );
                              }),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: const Text('Co-curricular Activities'),
                        subtitle: const Text('Add / Edit activities'),
                        onTap: _openCoCurricular,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.upload_file),
                        title: const Text('Upload Documents'),
                        subtitle: const Text('View / Manage student docs'),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => ListView(
                              shrinkWrap: true,
                              children: List.generate(8, (i) {
                                final sem = 'Semester ${i + 1}';
                                return ListTile(
                                  title: Text(sem),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _openUploads(sem);
                                  },
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
