import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentService {
  final CollectionReference _studentCollection =
      FirebaseFirestore.instance.collection('students');

  /// ✅ Get Student by UID
  Future<Student?> getStudentById(String uid) async {
    try {
      final doc = await _studentCollection.doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return Student.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("❌ Error fetching student: $e");
      return null;
    }
  }

  /// ✅ Create or Update Student
  Future<void> saveStudent(String uid, Student student) async {
    try {
      await _studentCollection
          .doc(uid)
          .set(student.toMap(), SetOptions(merge: true));
      print("✅ Student saved for UID: $uid");
    } catch (e) {
      print("❌ Error saving student: $e");
      rethrow;
    }
  }

  /// (Optional) Delete Student
  Future<void> deleteStudent(String uid) async {
    try {
      await _studentCollection.doc(uid).delete();
      print("🗑️ Student deleted: $uid");
    } catch (e) {
      print("❌ Error deleting student: $e");
      rethrow;
    }
  }
}
