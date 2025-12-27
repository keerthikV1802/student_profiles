import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_app/screens/student/cgpa_calculation_screen.dart';
import 'package:new_app/screens/student/co_curr_act_screen.dart';
import 'package:new_app/screens/student/resumebuilder_screen.dart';
import 'package:new_app/screens/student/student_details_screen.dart';
import 'package:new_app/screens/student/attendance_screen.dart';
import 'package:new_app/screens/student/semester_marks_screen.dart';
import 'package:new_app/screens/student/student_leavehistory_screen.dart';
import 'package:new_app/screens/student/student_leaverequest_screen.dart';
import 'package:new_app/screens/student/uploaddocuments_screen.dart';
import '../../models/student_model.dart';
import 'package:new_app/screens/student/internal_marks_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class StudentHomeDrawer extends StatelessWidget {
  final Student? student;
  final VoidCallback onRefresh;
  final String uid; // callback to reload student data

  const StudentHomeDrawer({
    super.key,
    required this.student,
    required this.onRefresh,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.lightBlueAccent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: (student != null &&
                          student!.photo != null &&
                          student!.photo!.isNotEmpty)
                      ? MemoryImage(base64Decode(student!.photo!))
                      : const AssetImage("assets/default_avatar.png")
                          as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  student != null
                      ? "Welcome ${student!.name}"
                      : "Welcome Student",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ✅ Student Details
          _buildDrawerItem(
            context,
            title: "Student Personal Details",
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentDetailsForm(),
                ),
              ).then((value) {
                if (value == true) {
                  onRefresh(); // 🔥 refresh after returning
                }
              });
            },
          ),

          // ✅ Attendance
          ExpansionTile(
  leading: const Icon(Icons.calendar_today, color: Colors.blue),
  title: const Text("Attendance"),
  tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
  childrenPadding: const EdgeInsets.only(left: 32.0),
  children: List.generate(8, (index) {
    int sem = index + 1;
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: EdgeInsets.zero,
      title: Text("Semester $sem"),
      onTap: () {
        Navigator.pop(context);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddAttendanceScreen(semester: "Semester $sem", studentId: FirebaseAuth.instance.currentUser!.uid) // 🔥 pass studentId if faculty, else empty
            ),
          );
        
      },
    );
  }),
),


          // ✅ Semester Marks
          ExpansionTile(
            leading: const Icon(Icons.school, color: Colors.blue),
            title: const Text("Semester Marks"),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
            childrenPadding: const EdgeInsets.only(left: 32.0),
            children: List.generate(8, (index) {
              int sem = index + 1;
              return ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                contentPadding: EdgeInsets.zero,
                title: Text("Semester $sem"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SemesterScreen(
                        semesterName: "Semester $sem",
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          ExpansionTile(
  leading: const Icon(Icons.school, color: Colors.blue),
  title: const Text("Internal Marks"),
  tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
  childrenPadding: const EdgeInsets.only(left: 32.0),
  children: List.generate(8, (index) {
    int sem = index + 1;
    String semesterName = "Semester $sem"; // ✅ dynamic semester
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: EdgeInsets.zero,
      title: Text(semesterName),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InternalMarksScreen(semester: semesterName)
          ),
        );
      },
    );
  }),
),


          
          ExpansionTile(
  leading: const Icon(Icons.school, color: Colors.blue),
  title: const Text("Upload Documents"),
  tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
  childrenPadding: const EdgeInsets.only(left: 32.0),
  children: List.generate(8, (index) {
    int sem = index + 1;
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: EdgeInsets.zero,
      title: Text("Semester $sem"),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UploadDocumentScreen(
              semesterName: "Semester $sem",  // ✅ pass semester name here
            ),
          ),
        );
      },
    );
  }),
),
          _buildDrawerItem(
  context,
  title: "Co-curricular Activities",
  icon: Icons.star,
  onTap: () {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CoCurricularScreen(),
      ),
    );
  },
),
          _buildDrawerItem(
  context,
  title: "Resume Builder",
  icon: Icons.file_open_sharp,
  onTap: () {
    Navigator.pop(context); // close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResumeBuilderScreen(),
      ),
    );
  },
),
ListTile(
  leading: const Icon(Icons.calculate, color: Colors.blue),
  title: const Text("CGPA Calculation"),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CGPACalculationScreen()),
    );
  },
),
ListTile(
            leading: Icon(Icons.send),
            title: Text("Request Leave"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentLeaveRequestScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text("Leave History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentLeaveHistoryScreen(),
                ),
              );
            },
          ),

        ],
      ),
    );
  }


  /// ✅ Reusable Drawer Item
  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context); // close drawer first
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}