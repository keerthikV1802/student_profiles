import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadDocumentScreen extends StatefulWidget {
  final String semesterName;
  final String? studentId; // ✅ optional param for faculty

  const UploadDocumentScreen({
    super.key,
    required this.semesterName,
    this.studentId,
  });

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descController = TextEditingController();

  late final String targetUid; // ✅ use studentId or current user

  @override
  void initState() {
    super.initState();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    targetUid = widget.studentId ?? currentUid; // ✅ fallback to own
  }

  Future<void> _uploadDoc() async {
    if (_titleController.text.isNotEmpty && _linkController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(targetUid) // ✅ use targetUid
          .collection('semesters')
          .doc(widget.semesterName)
          .collection('uploadedDocs')
          .add({
        'title': _titleController.text.trim(),
        'link': _linkController.text.trim(),
        'description': _descController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _linkController.clear();
      _descController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document uploaded successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Docs - ${widget.semesterName}")),
      body: Column(
        children: [
          TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title")),
          TextField(
              controller: _linkController,
              decoration: const InputDecoration(labelText: "Document Link")),
          TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description")),
          ElevatedButton(onPressed: _uploadDoc, child: const Text("Upload")),

          const Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .doc(targetUid) // ✅ use targetUid
                  .collection('semesters')
                  .doc(widget.semesterName)
                  .collection('uploadedDocs')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text("No documents uploaded yet."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return ListTile(
                      title: Text(doc['title']),
                      subtitle: Text(doc['description']),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () {
                          // TODO: Use url_launcher to open doc['link']
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
    );
  }
}
