class Student {
  final String id;
  final String studentId;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String enrollmentYear;
  final List<String> enrolledCourseIds;

  Student({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.enrollmentYear,
    List<String>? enrolledCourseIds,
  }) : enrolledCourseIds = enrolledCourseIds ?? [];

  Student copyWith({
    String? id,
    String? studentId,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? enrollmentYear,
    List<String>? enrolledCourseIds,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      enrolledCourseIds: enrolledCourseIds ?? List.from(this.enrolledCourseIds),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'enrollmentYear': enrollmentYear,
      'enrolledCourseIds': enrolledCourseIds,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      enrollmentYear: map['enrollmentYear'] ?? '',
      enrolledCourseIds: List<String>.from(map['enrolledCourseIds'] ?? []),
    );
  }
}
