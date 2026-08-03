import '../../models/student_model.dart';
import '../../models/course_model.dart';

/// Single Responsibility & Interface Segregation: Manages student-course relationships.
abstract class IEnrollmentService {
  int get totalEnrollments;
  List<Course> getCoursesForStudent(String studentId);
  List<Student> getStudentsForCourse(String courseId);
  void enrolStudentInCourse(String studentId, String courseId);
  void unEnrolStudentFromCourse(String studentId, String courseId);
  void updateStudentEnrollments(String studentId, List<String> courseIds);
  void handleCourseDeleted(String courseId);
}
