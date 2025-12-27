class Attendance {
  final String subject;
  final int totalClasses;
  final int attendedClasses;

  Attendance({
    required this.subject,
    required this.totalClasses,
    required this.attendedClasses,
  });

  Map<String, dynamic> toMap() {
    return {
      "subject": subject,
      "totalClasses": totalClasses,
      "attendedClasses": attendedClasses,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      subject: map["subject"],
      totalClasses: map["totalClasses"],
      attendedClasses: map["attendedClasses"],
    );
  }
}
