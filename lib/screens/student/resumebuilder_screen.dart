import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_app/screens/student_home.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> studentData = {};
  Map<String, dynamic> coCurricularData = {};
  bool isLoading = true;
  int selectedTemplate = 0; // track which template user selected

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (user == null) return;

    final studentSnap = await FirebaseFirestore.instance
        .collection('students')
        .doc(user!.uid)
        .get();

    final coCurricularSnap = await FirebaseFirestore.instance
        .collection('students')
        .doc(user!.uid)
        .collection('coCurricular')
        .doc('details')
        .get();

    setState(() {
      studentData = studentSnap.data() ?? {};
      coCurricularData = coCurricularSnap.data() ?? {};
      isLoading = false;
    });
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // Choose template
    if (selectedTemplate == 0) {
      pdf.addPage(pw.Page(
        build: (context) => _template1(),
      ));
    } else if (selectedTemplate == 1) {
      pdf.addPage(pw.Page(
        build: (context) => _template2(),
      ));
    } else {
      pdf.addPage(pw.Page(
        build: (context) => _template3(),
      ));
    }

    return pdf.save();
  }

  // Template 1: Modern with real student + co-curricular data
pw.Widget _template1() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Name & Register No
      pw.Text(studentData['name'] ?? 'Student Name',
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 5),
      pw.Text("Register No: ${studentData['registerNo'] ?? ''}"),
      pw.Text("Department: ${studentData['department'] ?? ''}"),
      pw.Text("Year: ${studentData['year'] ?? ''}"),
      pw.SizedBox(height: 15),

      // Education Section
      pw.Text("Education",
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey)),
      pw.SizedBox(height: 5),
      if (coCurricularData['education'] != null)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
                "${coCurricularData['education']['degree'] ?? ''} - ${coCurricularData['education']['institution'] ?? ''}"),
            pw.Text(
                "Year: ${coCurricularData['education']['yearOfPassing'] ?? ''} | CGPA: ${coCurricularData['education']['cgpa'] ?? ''}"),
          ],
        )
      else
        pw.Text("No education details added"),
      pw.SizedBox(height: 15),

      // Co-Curricular Activities
      pw.Text("Co-Curricular Activities",
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey)),
      pw.SizedBox(height: 5),

      _buildListSection("Seminars / Workshops", coCurricularData['seminars']),
      _buildListSection("Papers Presented", coCurricularData['papers']),
      _buildListSection("Projects Done", coCurricularData['projects']),
      _buildListSection("Industrial Visits", coCurricularData['industrialVisits']),
      _buildListSection("Industrial Training", coCurricularData['industrialTraining']),
      _buildListSection("Software Studied", coCurricularData['softwareStudied']),
      _buildListSection("Technical Symposia", coCurricularData['technicalSymposia']),
      _buildListSection("Other Achievements", coCurricularData['otherAchievements']),

      pw.SizedBox(height: 15),

      // Certificates
      pw.Text("Certificates",
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey)),
      pw.SizedBox(height: 5),
      if ((coCurricularData['certificates'] as List<dynamic>?)?.isNotEmpty ?? false)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: (coCurricularData['certificates'] as List<dynamic>)
              .map((c) {
            final cert = Map<String, dynamic>.from(c as Map);
            return pw.Text("- ${cert['title']} (${cert['url']})");
          }).toList(),
        )
      else
        pw.Text("No certificates added"),
    ],
  );
}

// Helper function to render list sections
pw.Widget _buildListSection(String title, dynamic list) {
  final items = (list as List<dynamic>?) ?? [];
  if (items.isEmpty) {
    return pw.Text("- No $title");
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map<pw.Widget>((e) => pw.Text("• $e")).toList(),
      ),
      pw.SizedBox(height: 8),
    ],
  );
}


// Template 2: Classic
// Template 2: Classic Resume Layout
pw.Widget _template2() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      // Header
      pw.Text(studentData['name'] ?? 'Student Name',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 5),
      pw.Text("Register No: ${studentData['registerNo'] ?? ''}"),
      pw.Text("Department: ${studentData['department'] ?? ''}"),
      pw.Text("Year: ${studentData['year'] ?? ''}"),
      pw.Divider(),

      // Education
      pw.Text("Education",
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black)),
      if (coCurricularData['education'] != null) ...[
        pw.Text("${coCurricularData['education']['degree'] ?? ''}"),
        pw.Text("${coCurricularData['education']['institution'] ?? ''}"),
        pw.Text(
            "Year: ${coCurricularData['education']['yearOfPassing'] ?? ''} | CGPA: ${coCurricularData['education']['cgpa'] ?? ''}"),
      ] else
        pw.Text("No education details added"),
      pw.SizedBox(height: 12),

      // Activities (all in a single block)
      pw.Text("Activities",
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black)),
      pw.SizedBox(height: 5),
      _buildListSection("Seminars / Workshops", coCurricularData['seminars']),
      _buildListSection("Papers Presented", coCurricularData['papers']),
      _buildListSection("Projects Done", coCurricularData['projects']),
      _buildListSection("Industrial Visits", coCurricularData['industrialVisits']),
      _buildListSection("Industrial Training", coCurricularData['industrialTraining']),
      _buildListSection("Software Studied", coCurricularData['softwareStudied']),
      _buildListSection("Technical Symposia", coCurricularData['technicalSymposia']),
      _buildListSection("Other Achievements", coCurricularData['otherAchievements']),
      pw.SizedBox(height: 12),

      // Certificates
      pw.Text("Certificates",
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black)),
      if ((coCurricularData['certificates'] as List<dynamic>?)?.isNotEmpty ??
          false)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: (coCurricularData['certificates'] as List<dynamic>)
              .map((c) {
            final cert = Map<String, dynamic>.from(c as Map);
            return pw.Text("- ${cert['title']} (${cert['url']})");
          }).toList(),
        )
      else
        pw.Text("No certificates added"),
    ],
  );
}


// Template 3: Minimal
// Template 3: Minimal Resume with header bar
pw.Widget _template3() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Header with background color
      pw.Container(
        width: double.infinity,
        color: PdfColors.blueGrey800,
        padding: const pw.EdgeInsets.all(12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(studentData['name'] ?? 'Student Name',
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text("Register No: ${studentData['registerNo'] ?? ''}",
                style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
            pw.Text(
                "Department: ${studentData['department'] ?? ''} | Year: ${studentData['year'] ?? ''}",
                style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
          ],
        ),
      ),

      pw.SizedBox(height: 15),

      // Education Section
      pw.Text("Education",
          style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800)),
      pw.SizedBox(height: 5),
      if (coCurricularData['education'] != null)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(coCurricularData['education']['degree'] ?? ''),
            pw.Text(coCurricularData['education']['institution'] ?? ''),
            pw.Text(
                "Year: ${coCurricularData['education']['yearOfPassing'] ?? ''} | CGPA: ${coCurricularData['education']['cgpa'] ?? ''}"),
          ],
        )
      else
        pw.Text("No education details added"),
      pw.SizedBox(height: 12),

      // Co-Curricular (compact)
      pw.Text("Activities",
          style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800)),
      pw.SizedBox(height: 5),
      _buildListSection("Seminars", coCurricularData['seminars']),
      _buildListSection("Papers", coCurricularData['papers']),
      _buildListSection("Projects", coCurricularData['projects']),
      _buildListSection("Visits", coCurricularData['industrialVisits']),
      _buildListSection("Training", coCurricularData['industrialTraining']),
      _buildListSection("Software", coCurricularData['softwareStudied']),
      _buildListSection("Symposia", coCurricularData['technicalSymposia']),
      _buildListSection("Achievements", coCurricularData['otherAchievements']),

      pw.SizedBox(height: 12),

      // Certificates Section
      pw.Text("Certificates",
          style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800)),
      pw.SizedBox(height: 5),
      if ((coCurricularData['certificates'] as List<dynamic>?)?.isNotEmpty ??
          false)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: (coCurricularData['certificates'] as List<dynamic>)
              .map((c) {
            final cert = Map<String, dynamic>.from(c as Map);
            return pw.Text("- ${cert['title']} (${cert['url']})");
          }).toList(),
        )
      else
        pw.Text("No certificates added"),
    ],
  );
}



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Resume Builder"),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StudentHomeScreen(), // fallback
      ),
    );
  }
},



        ),
      ),
      body: Column(
  children: [
    // Template selector row
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text("Template 1"),
          selected: selectedTemplate == 0,
          onSelected: (_) => setState(() => selectedTemplate = 0),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text("Template 2"),
          selected: selectedTemplate == 1,
          onSelected: (_) => setState(() => selectedTemplate = 1),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text("Template 3"),
          selected: selectedTemplate == 2,
          onSelected: (_) => setState(() => selectedTemplate = 2),
        ),
      ],
    ),

    const SizedBox(height: 20),

    // ✅ Expanded makes PdfPreview take available height
    Expanded(
      child: PdfPreview(
        build: (format) => _buildPdf(format),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: false,
        allowSharing: false,
        actions: [], // removes bottom bar
      ),
    ),

    // ✅ Button at bottom
    Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          final pdfBytes = await _buildPdf(PdfPageFormat.a4);
          await Printing.sharePdf(bytes: pdfBytes, filename: 'resume.pdf');
        },
        icon: const Icon(Icons.download),
        label: const Text("Download Resume"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48), // full width
        ),
      ),
    ),
  ],
),

    );
  }
}
