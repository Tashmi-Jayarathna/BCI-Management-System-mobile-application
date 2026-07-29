import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../models/course_model.dart';

class BCIRepository extends ChangeNotifier {
  final List<Student> _students = [];
  final List<Course> _courses = [];

  BCIRepository() {
    _seedInitialData();
  }

  List<Student> get students => List.unmodifiable(_students);
  List<Course> get courses => List.unmodifiable(_courses);

  int get totalStudents => _students.length;
  int get totalCourses => _courses.length;
  int get totalEnrollments =>
      _students.fold(0, (sum, s) => sum + s.enrolledCourseIds.length);

  List<String> get availableDepartments => [
        'All',
        'Computer Science',
        'Business Administration',
        'Information Technology',
        'Data Science',
        'Software Engineering',
      ];

  // Seed Data
  void _seedInitialData() {
    _courses.addAll([
      Course(
        id: 'c1',
        courseCode: 'CS101',
        title: 'Introduction to Computer Science',
        credits: 4,
        department: 'Computer Science',
        instructor: 'Dr. Waruna',
        description: 'Foundations of computing, algorithms, and logic.',
      ),
      Course(
        id: 'c2',
        courseCode: 'BUS201',
        title: 'Principles of Management',
        credits: 3,
        department: 'Business Administration',
        instructor: 'Prof. Sujith',
        description: 'Core concepts in modern enterprise management.',
      ),
      Course(
        id: 'c3',
        courseCode: 'DS301',
        title: 'Data Structures & Algorithms',
        credits: 4,
        department: 'Data Science',
        instructor: 'Prof.Thushari',
        description: 'Advanced trees, graphs, sorting, and dynamic programming.',
      ),
      Course(
        id: 'c4',
        courseCode: 'SE401',
        title: 'Mobile App Architecture',
        credits: 3,
        department: 'Software Engineering',
        instructor: 'Dr.Susara',
        description: 'Cross-platform mobile design patterns and state management.',
      ),
      Course(
        id: 'c5',
        courseCode: 'IT105',
        title: 'Cybersecurity Fundamentals',
        credits: 3,
        department: 'Information Technology',
        instructor: 'Mr.Sohan',
        description: 'Network security, encryption, and threat vectors.',
      ),
    ]);

    _students.addAll([
      Student(
        id: 's1',
        studentId: 'BCI-2024-001',
        name: 'Hasanthi Sandeepani',
        email: 'Hasanthisandeepani@bci.edu',
        phone: '+1 (555) 234-5678',
        department: 'Computer Science',
        enrollmentYear: '2024',
        enrolledCourseIds: ['c1', 'c3', 'c4'],
      ),
      Student(
        id: 's2',
        studentId: 'BCI-2024-002',
        name: 'Senal Navod',
        email: 'senalnavod@bci.edu',
        phone: '+1 (555) 876-5432',
        department: 'Business Administration',
        enrollmentYear: '2024',
        enrolledCourseIds: ['c2'],
      ),
      Student(
        id: 's3',
        studentId: 'BCI-2025-003',
        name: 'Tharindu Dilshan',
        email: 'Tharindudilshan@bci.edu',
        phone: '+1 (555) 345-6789',
        department: 'Software Engineering',
        enrollmentYear: '2025',
        enrolledCourseIds: ['c1', 'c4'],
      ),
      Student(
        id: 's4',
        studentId: 'BCI-2025-004',
        name: 'Kavindu Hasinsa',
        email: 'Kavinduhasinsa@bci.edu',
        phone: '+1 (555) 987-6543',
        department: 'Data Science',
        enrollmentYear: '2025',
        enrolledCourseIds: ['c3', 'c5'],
      ),
    ]);
  }

  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Course? getCourseById(String id) {
    try {
      return _courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Course> getCoursesForStudent(String studentId) {
    final student = getStudentById(studentId);
    if (student == null) return [];
    return _courses.where((c) => student.enrolledCourseIds.contains(c.id)).toList();
  }

  List<Student> getStudentsForCourse(String courseId) {
    return _students.where((s) => s.enrolledCourseIds.contains(courseId)).toList();
  }

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void updateStudent(Student updatedStudent) {
    final index = _students.indexWhere((s) => s.id == updatedStudent.id);
    if (index != -1) {
      _students[index] = updatedStudent;
      notifyListeners();
    }
  }

  void deleteStudent(String studentId) {
    _students.removeWhere((s) => s.id == studentId);
    notifyListeners();
  }

  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(Course updatedCourse) {
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      notifyListeners();
    }
  }

  void deleteCourse(String courseId) {
    _courses.removeWhere((c) => c.id == courseId);
    for (var i = 0; i < _students.length; i++) {
      if (_students[i].enrolledCourseIds.contains(courseId)) {
        final updatedList = List<String>.from(_students[i].enrolledCourseIds)
          ..remove(courseId);
        _students[i] = _students[i].copyWith(enrolledCourseIds: updatedList);
      }
    }
    notifyListeners();
  }

  void enrolStudentInCourse(String studentId, String courseId) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final student = _students[index];
      if (!student.enrolledCourseIds.contains(courseId)) {
        final updatedList = List<String>.from(student.enrolledCourseIds)..add(courseId);
        _students[index] = student.copyWith(enrolledCourseIds: updatedList);
        notifyListeners();
      }
    }
  }

  void unEnrolStudentFromCourse(String studentId, String courseId) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final student = _students[index];
      if (student.enrolledCourseIds.contains(courseId)) {
        final updatedList = List<String>.from(student.enrolledCourseIds)..remove(courseId);
        _students[index] = student.copyWith(enrolledCourseIds: updatedList);
        notifyListeners();
      }
    }
  }

  void updateStudentEnrollments(String studentId, List<String> courseIds) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      _students[index] = _students[index].copyWith(enrolledCourseIds: courseIds);
      notifyListeners();
    }
  }

  List<Student> searchStudents(String query, String departmentFilter) {
    return _students.where((s) {
      final matchesQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.studentId.toLowerCase().contains(query.toLowerCase()) ||
          s.email.toLowerCase().contains(query.toLowerCase());
      final matchesDept = departmentFilter.isEmpty ||
          departmentFilter == 'All' ||
          s.department == departmentFilter;
      return matchesQuery && matchesDept;
    }).toList();
  }

  List<Course> searchCourses(String query, String departmentFilter) {
    return _courses.where((c) {
      final matchesQuery = query.isEmpty ||
          c.title.toLowerCase().contains(query.toLowerCase()) ||
          c.courseCode.toLowerCase().contains(query.toLowerCase()) ||
          c.instructor.toLowerCase().contains(query.toLowerCase());
      final matchesDept = departmentFilter.isEmpty ||
          departmentFilter == 'All' ||
          c.department == departmentFilter;
      return matchesQuery && matchesDept;
    }).toList();
  }

  Map<String, int> getDepartmentStudentCount() {
    final Map<String, int> counts = {};
    for (var s in _students) {
      counts[s.department] = (counts[s.department] ?? 0) + 1;
    }
    return counts;
  }
}
