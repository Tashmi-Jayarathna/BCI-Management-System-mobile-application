import '../interfaces/student_repository_interface.dart';
import '../interfaces/course_repository_interface.dart';
import '../interfaces/enrollment_service_interface.dart';
import '../interfaces/dashboard_analytics_service_interface.dart';

/// Single Responsibility Principle: Analytics calculation for Dashboard.
class DashboardAnalyticsService implements IDashboardAnalyticsService {
  final IStudentRepository _studentRepo;
  final ICourseRepository _courseRepo;
  final IEnrollmentService _enrollmentService;

  DashboardAnalyticsService({
    required IStudentRepository studentRepo,
    required ICourseRepository courseRepo,
    required IEnrollmentService enrollmentService,
  })  : _studentRepo = studentRepo,
        _courseRepo = courseRepo,
        _enrollmentService = enrollmentService;

  @override
  int get totalStudents => _studentRepo.totalStudents;

  @override
  int get totalCourses => _courseRepo.totalCourses;

  @override
  int get totalEnrollments => _enrollmentService.totalEnrollments;

  @override
  double get averageCoursesPerStudent {
    final count = totalStudents;
    return count > 0 ? (totalEnrollments / count) : 0.0;
  }

  @override
  Map<String, int> getDepartmentStudentDistribution() {
    final Map<String, int> distribution = {};
    for (final s in _studentRepo.getAllStudents()) {
      distribution[s.department] = (distribution[s.department] ?? 0) + 1;
    }
    return distribution;
  }
}
