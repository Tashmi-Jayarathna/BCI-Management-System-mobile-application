import '../../models/course_model.dart';

/// Interface Segregation Principle (ISP): Granular read-only course contract.
abstract class ICourseReader {
  List<Course> getAllCourses();
  Course? getCourseById(String id);
  List<Course> getCoursesForDepartment(String department);
  int get totalCourses;
}

/// Interface Segregation Principle (ISP): Granular write-only course contract.
abstract class ICourseWriter {
  void addCourse(Course course);
  void updateCourse(Course course);
  void deleteCourse(String courseId);
}

/// Open/Closed & Dependency Inversion Principle: Combined Course Repository interface.
abstract class ICourseRepository implements ICourseReader, ICourseWriter {
  List<String> get availableDepartments;
}
