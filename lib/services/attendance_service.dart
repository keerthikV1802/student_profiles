import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 🔥 Add or Update Attendance
  Future<void> addAttendance(String semester, Attendance attendance) async {
    final uid = _auth.currentUser!.uid;
    await _db
        .collection("students")
        .doc(uid)
        .collection("attendance")
        .doc(semester)
        .collection("subjects")
        .doc(attendance.subject)
        .set(attendance.toMap());
  }

  // 🔥 Fetch Attendance for a Semester
  Future<List<Attendance>> getAttendance(String semester) async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await _db
        .collection("students")
        .doc(uid)
        .collection("attendance")
        .doc(semester)
        .collection("subjects")
        .get();

    return snapshot.docs.map((doc) => Attendance.fromMap(doc.data())).toList();
  }
}
