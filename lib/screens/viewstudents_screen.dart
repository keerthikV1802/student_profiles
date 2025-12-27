
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'facultystudent_details_screen.dart'; 

class ViewStudentsScreen extends StatefulWidget {
  const ViewStudentsScreen({Key? key}) : super(key: key);

  @override
  State<ViewStudentsScreen> createState() => _ViewStudentsScreenState();
}

class _ViewStudentsScreenState extends State<ViewStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'Name'; // Name | Register No | Year
  String? _role;
  String? _dept;
  bool _loading = false;
  List<QueryDocumentSnapshot> _results = [];

  @override
  void initState() {
    super.initState();
    _initUserMeta();
  }

  Future<void> _initUserMeta() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

  if (!mounted) return; // ✅ safeguard

  if (userDoc.exists) {
    setState(() {
      _role = userDoc.data()?['role'] as String? ?? '';
      _dept = userDoc.data()?['department'] as String? 
              ?? userDoc.data()?['dept'] as String?;
    });
  }
}


  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _results = [];
    });

    try {
      final base = FirebaseFirestore.instance.collection('students',);

      QuerySnapshot snap;

      if (_searchType == 'Name') {
        Query q = base.where('name', isEqualTo: query);
        if (_role == 'faculty' && _dept != null) q = q.where('department', isEqualTo: _dept);
        snap = await q.get();
      } else if (_searchType == 'Register No') {
        // try common register fields: uid or registerNo
        Query q1 = base.where('uid', isEqualTo: query);
        if (_role == 'faculty' && _dept != null) q1 = q1.where('department', isEqualTo: _dept);
        snap = await q1.get();
        if (snap.docs.isEmpty) {
          Query q2 = base.where('registerNo', isEqualTo: query);
          if (_role == 'faculty' && _dept != null) q2 = q2.where('department', isEqualTo: _dept);
          snap = await q2.get();
        }
      } else { // Year
        Query q = base.where('currentYear', isEqualTo: query);
        if (_role == 'faculty' && _dept != null) q = q.where('department', isEqualTo: _dept);
        snap = await q.get();
      }

      setState(() {
        _results = snap.docs;
      });
    } catch (e) {
      // handle permission errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildResultCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text((data['name'] ?? '').toString().isNotEmpty ? data['name'][0] : '?')),
        title: Text(data['name'] ?? '(no name)'),
        subtitle: Text('Dept: ${data['department'] ?? '-'}  | Year: ${data['currentYear'] ?? '-'}'),
        onTap: () {
          // Open faculty student details screen passing studentId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FacultyStudentDetailsScreen(studentId: doc.id),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _searchType,
                  items: ['Name', 'Register No', 'Year'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _searchType = v!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: 'Enter search query'),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.search), onPressed: _performSearch),
              ],
            ),

            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No results'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) => _buildResultCard(_results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
