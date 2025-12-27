class Student {
  final String uid;
  final String name;
  final String registerNo;
  final String programme;
  final String dob;
  final String bloodGroup;
  final String fatherName;
  final String motherName;
  final int annualIncomeFather;
  final int annualIncomeMother;
  final String address;
  final String email;
  final String phone;
  final String? photo; // ✅ Nullable for optional profile photo
  final String department;
  final int admissionYear;

  Student({
    required this.uid,
    required this.name,
    required this.registerNo,
    required this.programme,
    required this.dob,
    required this.bloodGroup,
    required this.fatherName,
    required this.motherName,
    required this.annualIncomeFather,
    required this.annualIncomeMother,
    required this.address,
    required this.email,
    required this.phone,
    this.photo,
    required this.department,
    required this.admissionYear,
  });

  /// ✅ Convert Student → Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'registerNo': registerNo,
      'programme': programme,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'fatherName': fatherName,
      'motherName': motherName,
      'annualIncomeFather': annualIncomeFather,
      'annualIncomeMother': annualIncomeMother,
      'address': address,
      'email': email,
      'phone': phone,
      'photo': photo,
      'department': department,
      'admissionYear': admissionYear,  // ✅ fixed key
    };
  }

  /// ✅ Convert Map (Firestore) → Student object
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      registerNo: map['registerNo'] ?? '',
      programme: map['programme'] ?? '',
      dob: map['dob'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      fatherName: map['fatherName'] ?? '',
      motherName: map['motherName'] ?? '',
      annualIncomeFather: (map['annualIncomeFather'] ?? 0) is int
          ? (map['annualIncomeFather'] ?? 0)
          : int.tryParse(map['annualIncomeFather'].toString()) ?? 0,
      annualIncomeMother: (map['annualIncomeMother'] ?? 0) is int
          ? (map['annualIncomeMother'] ?? 0)
          : int.tryParse(map['annualIncomeMother'].toString()) ?? 0,
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photo: map['photo'], // ✅ stays nullable
      department: map['department'] ?? '',
      admissionYear: map['admissionYear'] ?? DateTime.now().year, // ✅ fixed
    );
  }
}
