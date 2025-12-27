import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_app/screens/edit_student_details_screen.dart';

class StudentDetailsForm extends StatefulWidget {
  final String? studentId;
  const StudentDetailsForm({super.key,this.studentId});

  @override
  State<StudentDetailsForm> createState() => _StudentDetailsFormState();
}

class _StudentDetailsFormState extends State<StudentDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  




  // controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _registerNoController = TextEditingController();
  final TextEditingController _programmeController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _annualIncomeFatherController = TextEditingController();
  final TextEditingController _annualIncomeMotherController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  bool _isLoading = true;
  bool _hasData = false;
  Map<String, dynamic>? _studentData;
  bool isFaculty = false;

  String? _base64Image; // <-- store image as base64

  late final String targetUid;
  @override
void initState() {
  super.initState();

  // check if logged-in user is faculty
  _checkRole();

  // decide whose profile to load
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  targetUid = widget.studentId ?? currentUid; // fallback to logged-in student

  // load student details
  _loadStudentDetails();
}


  Future<void> _loadStudentDetails() async {
    final doc = await _firestore.collection('students').doc(targetUid).get();
    if (doc.exists) {
      setState(() {
        _hasData = true;
        _studentData = doc.data();
        _base64Image = _studentData?['photo'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasData = false;
        _isLoading = false;
      });
    }
  }
  Future<void> _checkRole() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (userDoc.exists && userDoc['role'] == 'faculty') {
    setState(() {
      isFaculty = true;
    });
  }
}


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes); // convert to base64
      });
    }
  }

  Future<void> _submitDetails() async {
    if (_base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a profile photo")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final admissionYear = DateTime.now().year; // ✅ auto set
        final currentYear = DateTime.now().year - admissionYear + 1;

        await _firestore.collection('students').doc(targetUid).set({
          "uid": targetUid,
          "name": _nameController.text.trim(),
          "registerNo": _registerNoController.text.trim(),
          "programme": _programmeController.text.trim(),
          "dob": _dobController.text.trim(),
          "bloodGroup": _bloodGroupController.text.trim(),
          "fatherName": _fatherNameController.text.trim(),
          "motherName": _motherNameController.text.trim(),
          "annualIncomeFather": int.tryParse(_annualIncomeFatherController.text.trim()) ?? 0,
          "annualIncomeMother": int.tryParse(_annualIncomeMotherController.text.trim()) ?? 0,
          "address": _addressController.text.trim(),
          "email": _auth.currentUser?.email,
          "phone": _phoneController.text.trim(),
          "photo": _base64Image, 
          "department": _departmentController.text.trim(),
          "admissionYear": admissionYear, // ✅ store admission year
          "currentYear": currentYear,
        });

        setState(() {
          _hasData = true;
          _studentData = {
            "uid": targetUid,
            "name": _nameController.text.trim(),
            "registerNo": _registerNoController.text.trim(),
            "programme": _programmeController.text.trim(),
            "dob": _dobController.text.trim(),
            "bloodGroup": _bloodGroupController.text.trim(),
            "fatherName": _fatherNameController.text.trim(),
            "motherName": _motherNameController.text.trim(),
            "annualIncomeFather": int.tryParse(_annualIncomeFatherController.text.trim()) ?? 0,
            "annualIncomeMother": int.tryParse(_annualIncomeMotherController.text.trim()) ?? 0,
            "address": _addressController.text.trim(),
            "email": _auth.currentUser?.email,
            "phone": _phoneController.text.trim(),
            "photo": _base64Image,
            "department": _departmentController.text.trim(),
            "admissionYear": admissionYear,
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Details saved successfully")),
        );
        if (widget.studentId != null) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Personal Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _hasData
            ? _buildReadOnlyDetails()
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // profile photo picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _base64Image != null
                            ? MemoryImage(base64Decode(_base64Image!))
                            : null,
                        child: _base64Image == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                    if (_base64Image == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Profile photo is required",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, "Full Name"),
                    _buildTextField(_registerNoController, "Register No"),
                    _buildTextField(_programmeController, "Programme"),
                    _buildTextField(_dobController, "Date of Birth"),
                    _buildTextField(_bloodGroupController, "Blood Group"),
                    _buildTextField(_fatherNameController, "Father Name"),
                    _buildTextField(_motherNameController, "Mother Name"),
                    _buildTextField(_annualIncomeFatherController, "Annual Income Father", isNumber: true),
                    _buildTextField(_annualIncomeMotherController, "Annual Income Mother", isNumber: true),
                    _buildTextField(_addressController, "Address"),
                    _buildTextField(_phoneController, "Phone"),
                    _buildTextField(_departmentController, "Department"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitDetails,
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
    );
  }

  Widget _buildReadOnlyDetails() {
    final admissionYear = _studentData?['admissionYear'] ?? DateTime.now().year;
    final currentYear = DateTime.now().year - admissionYear + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _studentData?['photo'] != null
              ? MemoryImage(base64Decode(_studentData!['photo']))
              : null,
          child: _studentData?['photo'] == null
              ? const Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${_studentData?['name'] ?? ''}"),
              Text("Register No: ${_studentData?['registerNo'] ?? ''}"),
              Text("Programme: ${_studentData?['programme'] ?? ''}"),
              Text("DOB: ${_studentData?['dob'] ?? ''}"),
              Text("Blood Group: ${_studentData?['bloodGroup'] ?? ''}"),
              Text("Father Name: ${_studentData?['fatherName'] ?? ''}"),
              Text("Mother Name: ${_studentData?['motherName'] ?? ''}"),
              Text("Annual Income Father: ${_studentData?['annualIncomeFather'] ?? ''}"),
              Text("Annual Income Mother: ${_studentData?['annualIncomeMother'] ?? ''}"),
              Text("Address: ${_studentData?['address'] ?? ''}"),
              Text("Email: ${_studentData?['email'] ?? ''}"),
              Text("Phone: ${_studentData?['phone'] ?? ''}"),
              Text("Department: ${_studentData?['department'] ?? ''}"),
              Text("Admission Year: $admissionYear"),
              Text("Current Year:$currentYear"), // ✅ auto calculated
              const SizedBox(height: 20),
              const Text(
                "Note: You cannot edit your details. Contact faculty to update.",
                style: TextStyle(color: Colors.red, fontSize: 14),
              
              ),
              if (isFaculty) 
  ElevatedButton(
    onPressed: () async {
      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditStudentDetailsScreen(
            studentId: targetUid,
            existingData: _studentData!,
          ),
        ),
      );
      if (updated == true) {
        _loadStudentDetails(); // refresh data after editing
      }
    },
    child: const Text("Edit Student Details"),
  ),

            ],
          ),
        ),
      ],
    );
  }
}
