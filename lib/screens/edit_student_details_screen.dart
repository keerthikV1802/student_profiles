import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_app/services/log_audit.dart'; 

class EditStudentDetailsScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> existingData;

  const EditStudentDetailsScreen({
    super.key,
    required this.studentId,
    required this.existingData,
  });

  @override
  State<EditStudentDetailsScreen> createState() => _EditStudentDetailsScreenState();
}

class _EditStudentDetailsScreenState extends State<EditStudentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _registerNoController;
  late TextEditingController _programmeController;
  late TextEditingController _dobController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;
  late TextEditingController _annualIncomeFatherController;
  late TextEditingController _annualIncomeMotherController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingData['name'] ?? "");
    _registerNoController = TextEditingController(text: widget.existingData['registerNo'] ?? "");
    _programmeController = TextEditingController(text: widget.existingData['programme'] ?? "");
    _dobController = TextEditingController(text: widget.existingData['dob'] ?? "");
    _bloodGroupController = TextEditingController(text: widget.existingData['bloodGroup'] ?? "");
    _fatherNameController = TextEditingController(text: widget.existingData['fatherName'] ?? "");
    _motherNameController = TextEditingController(text: widget.existingData['motherName'] ?? "");
    _annualIncomeFatherController = TextEditingController(text: "${widget.existingData['annualIncomeFather'] ?? 0}");
    _annualIncomeMotherController = TextEditingController(text: "${widget.existingData['annualIncomeMother'] ?? 0}");
    _addressController = TextEditingController(text: widget.existingData['address'] ?? "");
    _phoneController = TextEditingController(text: widget.existingData['phone'] ?? "");
    _departmentController = TextEditingController(text: widget.existingData['department'] ?? "");
  }

  Future<void> _saveChanges() async {
  if (_formKey.currentState!.validate()) {
    await FirebaseFirestore.instance
        .collection("students")
        .doc(widget.studentId)
        .update({
      "name": _nameController.text.trim(),
      "registerNo": _registerNoController.text.trim(),
      "programme": _programmeController.text.trim(),
      "dob": _dobController.text.trim(),
      "bloodGroup": _bloodGroupController.text.trim(),
      "fatherName": _fatherNameController.text.trim(),
      "motherName": _motherNameController.text.trim(),
      "annualIncomeFather":
          int.tryParse(_annualIncomeFatherController.text.trim()) ?? 0,
      "annualIncomeMother":
          int.tryParse(_annualIncomeMotherController.text.trim()) ?? 0,
      "address": _addressController.text.trim(),
      "phone": _phoneController.text.trim(),
      "department": _departmentController.text.trim(),
    });

    // ✅ Call audit log after update
    // ✅ Log after update
await LogAuditService.logAudit(
  action: "updated student",
  targetName: "${_nameController.text.trim()} (${_departmentController.text.trim()})",
);

    Navigator.pop(context, true);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Student Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
      ),
    );
  }
}
