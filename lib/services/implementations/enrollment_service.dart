import '../../models/student_model.dart';
import '../../models/course_model.dart';
import '../interfaces/student_repository_interface.dart';
import '../interfaces/course_repository_interface.dart';
import '../interfaces/enrollment_service_interface.dart';

/// Single Responsibility & Dependency Inversion Principle: Enrollment Business Logic Service.
class EnrollmentService implements IEnrollmentService {
  final IStudentRepository _studentRepo;
  final ICourseRepository _courseRepo;

  EnrollmentService({
    required this._studentRepo,
    required this._courseRepo,
  });

  @override
  int get totalEnrollments => _studentRepo
      .getAllStudents()
      .fold(0, (sum, s) => sum + s.enrolledCourseIds.length);

  @override
  List<Course> getCoursesForStudent(String studentId) {
    final student = _studentRepo.getStudentById(studentId);
    if (student == null) return [];
    return _courseRepo
        .getAllCourses()
        .where((c) => student.enrolledCourseIds.contains(c.id))
        .toList();
  }

  @override
  List<Student> getStudentsForCourse(String courseId) {
    return _studentRepo
        .getAllStudents()
        .where((s) => s.enrolledCourseIds.contains(courseId))
        .toList();
  }

  @override
  void enrolStudentInCourse(String studentId, String courseId) {
    final student = _studentRepo.getStudentById(studentId);
    if (student != null && !student.enrolledCourseIds.contains(courseId)) {
      final updatedList = List<String>.from(student.enrolledCourseIds)..add(courseId);
      _studentRepo.updateStudent(student.copyWith(enrolledCourseIds: updatedList));
    }
  }

  @override
  void unEnrolStudentFromCourse(String studentId, String courseId) {
    final student = _studentRepo.getStudentById(studentId);
    if (student != null && student.enrolledCourseIds.contains(courseId)) {
      final updatedList = List<String>.from(student.enrolledCourseIds)..remove(courseId);
      _studentRepo.updateStudent(student.copyWith(enrolledCourseIds: updatedList));
    }
  }

  @override
  void updateStudentEnrollments(String studentId, List<String> courseIds) {
    final student = _studentRepo.getStudentById(studentId);
    if (student != null) {
      _studentRepo.updateStudent(student.copyWith(enrolledCourseIds: courseIds));
    }
  }

  @override
  void handleCourseDeleted(String courseId) {
    for (final student in _studentRepo.getAllStudents()) {
      if (student.enrolledCourseIds.contains(courseId)) {
        final updatedList = List<String>.from(student.enrolledCourseIds)
          ..remove(courseId);
        _studentRepo.updateStudent(student.copyWith(enrolledCourseIds: updatedList));
      }
    }
  }
}
