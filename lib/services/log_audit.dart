import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogAuditService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Log any action in Firestore
  static Future<void> logAudit({
    required String action,       // e.g. "update", "create", "delete"
    required String targetName,   // e.g. "Student: Keerthik (CSE - 3rd Year)"
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // get actor details from users collection
      final userDoc =
          await _firestore.collection("users").doc(user.uid).get();

      final actorName = userDoc.data()?["name"] ?? user.email ?? "Unknown";
      final role = userDoc.data()?["role"] ?? "unknown"; // faculty/admin/principal
      final dept = userDoc.data()?["department"] ??
          userDoc.data()?["dept"] ??
          "-";

      // add to audit_logs collection
      await _firestore.collection("audit_logs").add({
        "actorName": actorName,             // who
        "designation": role,                // Faculty/Admin/Principal
        "dept": dept,                       // department
        "action": action,                   // create/update/delete
        "target": targetName,               // target of action
        "timestamp": FieldValue.serverTimestamp(), // when
      });
    } catch (e) {
      print("Audit log failed: $e");
    }
  }
}
