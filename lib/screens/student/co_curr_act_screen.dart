import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/screens/student_home.dart';

class CoCurricularScreen extends StatefulWidget {
  final String? studentId; // ✅ NEW optional param

  const CoCurricularScreen({super.key, this.studentId});

  @override
  State<CoCurricularScreen> createState() => _CoCurricularScreenState();
}

class _CoCurricularScreenState extends State<CoCurricularScreen> {
  final _firestore = FirebaseFirestore.instance;
  
  late final String targetUid; // ✅ Will hold studentId or own uid

  // controllers
  final _seminarController = TextEditingController();
  final _paperController = TextEditingController();
  final _quizController = TextEditingController();
  final _projectController = TextEditingController();
  final _visitController = TextEditingController();
  final _trainingController = TextEditingController();
  final _softwareController = TextEditingController();
  final _sympoController = TextEditingController();
  final _otherController = TextEditingController();

  final _degreeController = TextEditingController();
  final _institutionController = TextEditingController();
  final _yearController = TextEditingController();
  final _cgpaController = TextEditingController();

  final _certTitleController = TextEditingController();
  final _certLinkController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
  targetUid = widget.studentId ?? currentUid; // ✅ fallback to self
  }

  DocumentReference<Map<String, dynamic>> get _docRef {
    return _firestore
        .collection('students')
        .doc(targetUid) // ✅ use targetUid
        .collection('coCurricular')
        .doc('details');
  }

  // Add list item
  Future<void> _addListItem(
    String field,
    String value, {
    required TextEditingController controller,
  }) async {
    if (value.trim().isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await _docRef.set(
        {field: FieldValue.arrayUnion([value])},
        SetOptions(merge: true),
      );
      controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Remove list item
  Future<void> _removeListItem(String field, dynamic value) async {
    try {
      await _docRef.set(
        {field: FieldValue.arrayRemove([value])},
        SetOptions(merge: true),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove failed: $e')),
      );
    }
  }

  // Save education
  Future<void> _saveEducation() async {
    final degree = _degreeController.text.trim();
    final institution = _institutionController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final cgpa = double.tryParse(_cgpaController.text.trim());

    final education = <String, dynamic>{
      if (degree.isNotEmpty) 'degree': degree,
      if (institution.isNotEmpty) 'institution': institution,
      if (year != null) 'yearOfPassing': year,
      if (cgpa != null) 'cgpa': cgpa,
    };

    setState(() => _isSaving = true);
    try {
      await _docRef.set({'education': education}, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Education saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Add certificate
  Future<void> _addCertificate() async {
    final title = _certTitleController.text.trim();
    final url = _certLinkController.text.trim();
    if (title.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter title and link')),
      );
      return;
    }

    final certMap = {"title": title, "url": url};

    setState(() => _isSaving = true);
    try {
      await _docRef.set(
        {"certificates": FieldValue.arrayUnion([certMap])},
        SetOptions(merge: true),
      );
      _certTitleController.clear();
      _certLinkController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _removeCertificate(Map<String, dynamic> cert) async {
    try {
      await _docRef.set(
        {"certificates": FieldValue.arrayRemove([cert])},
        SetOptions(merge: true),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remove failed: $e')),
      );
    }
  }

  Widget _sectionCard({
    required String title,
    required TextEditingController controller,
    required String fieldKey,
    required Map<String, dynamic> docData,
  }) {
    final List existing = (docData[fieldKey] as List<dynamic>?) ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'Enter $title'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _addListItem(fieldKey, controller.text,
                          controller: controller),
                  child: const Text('Add'),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (existing.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: existing.map<Widget>((e) {
                  return Chip(
                    label: Text(e.toString()),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeListItem(fieldKey, e),
                  );
                }).toList(),
              )
            else
              const Text('No items added',
                  style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Co-Curricular Activities"),
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _docRef.snapshots(),
        builder: (context, snapshot) {
          final docData = snapshot.data?.data() ?? {};
          final certificates = (docData['certificates'] as List<dynamic>?) ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _sectionCard(
                    title: "Seminars / Workshops",
                    controller: _seminarController,
                    fieldKey: "seminars",
                    docData: docData),
                _sectionCard(
                    title: "Papers Presented",
                    controller: _paperController,
                    fieldKey: "papers",
                    docData: docData),
                _sectionCard(
                    title: "Quiz Competitions",
                    controller: _quizController,
                    fieldKey: "quizCompetitions",
                    docData: docData),
                _sectionCard(
                    title: "Projects Done",
                    controller: _projectController,
                    fieldKey: "projects",
                    docData: docData),
                _sectionCard(
                    title: "Industrial Visits",
                    controller: _visitController,
                    fieldKey: "industrialVisits",
                    docData: docData),
                _sectionCard(
                    title: "Industrial Training",
                    controller: _trainingController,
                    fieldKey: "industrialTraining",
                    docData: docData),
                _sectionCard(
                    title: "Software Studied",
                    controller: _softwareController,
                    fieldKey: "softwareStudied",
                    docData: docData),
                _sectionCard(
                    title: "Technical Symposia",
                    controller: _sympoController,
                    fieldKey: "technicalSymposia",
                    docData: docData),
                _sectionCard(
                    title: "Other Achievements",
                    controller: _otherController,
                    fieldKey: "otherAchievements",
                    docData: docData),

                // Education
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Education",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextField(
                          controller: _degreeController,
                          decoration:
                              const InputDecoration(labelText: "Degree / Course"),
                        ),
                        TextField(
                          controller: _institutionController,
                          decoration: const InputDecoration(
                              labelText: "Institution / College"),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _yearController,
                                decoration: const InputDecoration(
                                    labelText: "Year of Passing"),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _cgpaController,
                                decoration:
                                    const InputDecoration(labelText: "CGPA / %"),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveEducation,
                          child: const Text("Save Education"),
                        )
                      ],
                    ),
                  ),
                ),

                // Certificates
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Certificates (Drive/OneDrive Links)",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextField(
                          controller: _certTitleController,
                          decoration: const InputDecoration(
                              labelText: "Certificate Title"),
                        ),
                        TextField(
                          controller: _certLinkController,
                          decoration:
                              const InputDecoration(labelText: "Paste Link"),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _addCertificate,
                          child: const Text("Add Certificate"),
                        ),
                        const SizedBox(height: 8),
                        if (certificates.isNotEmpty)
                          Column(
                            children: certificates.map<Widget>((c) {
                              final cert = Map<String, dynamic>.from(c as Map);
                              return ListTile(
                                title: Text(cert['title'] ?? "Certificate"),
                                subtitle: Text(cert['url'] ?? ""),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeCertificate(cert),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text("No certificates added",
                              style: TextStyle(color: Colors.black54)),
                      ],
                    ),
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
