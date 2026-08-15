import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../models/course_model.dart';
import 'interfaces/management_service_interface.dart';
import 'interfaces/student_repository_interface.dart';
import 'interfaces/course_repository_interface.dart';
import 'interfaces/enrollment_service_interface.dart';
import 'interfaces/dashboard_analytics_service_interface.dart';
import 'implementations/in_memory_student_repository.dart';
import 'implementations/in_memory_course_repository.dart';
import 'implementations/enrollment_service.dart';
import 'implementations/dashboard_analytics_service.dart';
import 'strategies/search_filter_strategy.dart';

/// Facade Pattern & Backward Compatibility Layer:
/// Implements ChangeNotifier and delegates all responsibilities to focused SOLID services
/// (IStudentRepository, ICourseRepository, IEnrollmentService, IDashboardAnalyticsService).
class BCIRepository extends ChangeNotifier implements IManagementService {
  late final IStudentRepository _studentRepo;
  late final ICourseRepository _courseRepo;
  late final IEnrollmentService _enrollmentService;
  late final IDashboardAnalyticsService _analyticsService;

  final StudentSearchStrategy _studentSearchStrategy = StudentSearchStrategy();
  final CourseSearchStrategy _courseSearchStrategy = CourseSearchStrategy();

  BCIRepository({
    IStudentRepository? studentRepo,
    ICourseRepository? courseRepo,
    IEnrollmentService? enrollmentService,
  }) {
    _studentRepo = studentRepo ?? InMemoryStudentRepository();
    _courseRepo = courseRepo ?? InMemoryCourseRepository();
    _enrollmentService =
        enrollmentService ??
        EnrollmentService(studentRepo: _studentRepo, courseRepo: _courseRepo);
    _analyticsService = DashboardAnalyticsService(
      studentRepo: _studentRepo,
      courseRepo: _courseRepo,
      enrollmentService: _enrollmentService,
    );
  }

  // Accessors for underlying services
  IStudentRepository get studentRepository => _studentRepo;
  ICourseRepository get courseRepository => _courseRepo;
  IEnrollmentService get enrollmentService => _enrollmentService;
  IDashboardAnalyticsService get analyticsService => _analyticsService;

  // Delegated Properties
  List<Student> get students => _studentRepo.getAllStudents();
  List<Course> get courses => _courseRepo.getAllCourses();

  int get totalStudents => _analyticsService.totalStudents;
  int get totalCourses => _analyticsService.totalCourses;
  int get totalEnrollments => _analyticsService.totalEnrollments;

  List<String> get availableDepartments => _studentRepo.availableDepartments;

  // Delegated Operations
  Student? getStudentById(String id) => _studentRepo.getStudentById(id);
  Course? getCourseById(String id) => _courseRepo.getCourseById(id);

  List<Course> getCoursesForStudent(String studentId) =>
      _enrollmentService.getCoursesForStudent(studentId);

  List<Student> getStudentsForCourse(String courseId) =>
      _enrollmentService.getStudentsForCourse(courseId);

  @override
  void addStudent(Student student) {
    _studentRepo.addStudent(student);
    notifyListeners();
  }

  @override
  void updateStudent(Student updatedStudent) {
    _studentRepo.updateStudent(updatedStudent);
    notifyListeners();
  }

  @override
  void deleteStudent(String studentId) {
    _studentRepo.deleteStudent(studentId);
    notifyListeners();
  }

  @override
  void addCourse(Course course) {
    _courseRepo.addCourse(course);
    notifyListeners();
  }

  @override
  void updateCourse(Course updatedCourse) {
    _courseRepo.updateCourse(updatedCourse);
    notifyListeners();
  }

  @override
  void deleteCourse(String courseId) {
    _courseRepo.deleteCourse(courseId);
    _enrollmentService.handleCourseDeleted(courseId);
    notifyListeners();
  }

  @override
  void enrolStudentInCourse(String studentId, String courseId) {
    _enrollmentService.enrolStudentInCourse(studentId, courseId);
    notifyListeners();
  }

  @override
  void unEnrolStudentFromCourse(String studentId, String courseId) {
    _enrollmentService.unEnrolStudentFromCourse(studentId, courseId);
    notifyListeners();
  }

  @override
  void updateStudentEnrollments(String studentId, List<String> courseIds) {
    _enrollmentService.updateStudentEnrollments(studentId, courseIds);
    notifyListeners();
  }

  List<Student> searchStudents(String query, String departmentFilter) {
    return _studentSearchStrategy.filter(
      _studentRepo.getAllStudents(),
      query,
      departmentFilter,
    );
  }

  List<Course> searchCourses(String query, String departmentFilter) {
    return _courseSearchStrategy.filter(
      _courseRepo.getAllCourses(),
      query,
      departmentFilter,
    );
  }

  Map<String, int> getDepartmentStudentCount() {
    return _analyticsService.getDepartmentStudentDistribution();
  }
}
