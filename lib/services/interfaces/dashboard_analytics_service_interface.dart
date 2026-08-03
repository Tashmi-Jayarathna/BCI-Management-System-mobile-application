/// Interface for Dashboard statistics and analytics services.
abstract class IDashboardAnalyticsService {
  int get totalStudents;
  int get totalCourses;
  int get totalEnrollments;
  double get averageCoursesPerStudent;
  Map<String, int> getDepartmentStudentDistribution();
}
