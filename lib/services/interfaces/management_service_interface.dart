import '../../models/student_model.dart';
import '../../models/course_model.dart';

/// Interface for coordinated student/course management operations.
abstract class IManagementService {
  void addStudent(Student student);
  void updateStudent(Student student);
  void deleteStudent(String studentId);

  void addCourse(Course course);
  void updateCourse(Course course);
  void deleteCourse(String courseId);

  void enrolStudentInCourse(String studentId, String courseId);
  void unEnrolStudentFromCourse(String studentId, String courseId);
  void updateStudentEnrollments(String studentId, List<String> courseIds);
}
