class Course {
  final String id;
  final String courseCode;
  final String title;
  final int credits;
  final String department;
  final String instructor;
  final String description;

  Course({
    required this.id,
    required this.courseCode,
    required this.title,
    required this.credits,
    required this.department,
    required this.instructor,
    required this.description,
  });

  Course copyWith({
    String? id,
    String? courseCode,
    String? title,
    int? credits,
    String? department,
    String? instructor,
    String? description,
  }) {
    return Course(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      title: title ?? this.title,
      credits: credits ?? this.credits,
      department: department ?? this.department,
      instructor: instructor ?? this.instructor,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseCode': courseCode,
      'title': title,
      'credits': credits,
      'department': department,
      'instructor': instructor,
      'description': description,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      courseCode: map['courseCode'] ?? '',
      title: map['title'] ?? '',
      credits: map['credits'] as int? ?? 3,
      department: map['department'] ?? '',
      instructor: map['instructor'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
